#!/usr/bin/env node
// Build and InBul bookkeeping. See MD/version_control.md.
//
//   node scripts/changelog.mjs --next-internal
//   node scripts/changelog.mjs --next-build
//   node scripts/changelog.mjs --pending "<title>" "<summary>" --why ".." --verified ".." --next ".."
//   node scripts/changelog.mjs --tag
//   node scripts/changelog.mjs --regen
//
// Tags are the source of truth for numbers: build-N (user-visible) and
// InBulNN (internal). CHANGELOG.md is generated; never edit it by hand.

import { execSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const BUILDS_DIR = join(ROOT, 'MD', 'builds');
const CHANGELOG = join(ROOT, 'CHANGELOG.md');
const FIRST_BUILD = 1000;

const git = (args) => execSync(`git ${args}`, { cwd: ROOT, encoding: 'utf8' }).trim();

function tags() {
  const out = git('tag --list');
  return out ? out.split('\n').map((t) => t.trim()).filter(Boolean) : [];
}

function nextBuild() {
  const nums = tags().map((t) => /^build-(\d+)$/.exec(t)).filter(Boolean).map((m) => Number(m[1]));
  const pendingFiles = existsSync(BUILDS_DIR)
    ? readdirSync(BUILDS_DIR).map((f) => /^build-(\d+)\.md$/.exec(f)).filter(Boolean).map((m) => Number(m[1]))
    : [];
  const highest = Math.max(FIRST_BUILD - 1, ...nums, ...pendingFiles.filter((n) => !nums.includes(n)).map((n) => n - 1));
  // A report that exists with no tag yet IS the pending build; reuse its number.
  const untagged = pendingFiles.filter((n) => !nums.includes(n));
  if (untagged.length) return Math.max(...untagged);
  return highest + 1;
}

function nextInternal() {
  const nums = tags().map((t) => /^InBul(\d+)$/.exec(t)).filter(Boolean).map((m) => Number(m[1]));
  return `InBul${String(Math.max(0, ...nums) + 1).padStart(2, '0')}`;
}

function reportPath(n) {
  return join(BUILDS_DIR, `build-${n}.md`);
}

function parseReport(n) {
  const text = readFileSync(reportPath(n), 'utf8');
  const title = /^# Build \d+: (.+)$/m.exec(text)?.[1]?.trim() ?? '';
  const date = /^Date: (.+)$/m.exec(text)?.[1]?.trim() ?? '';
  const summary = /^## What changed\s*\n+([\s\S]*?)\n+## /m.exec(text)?.[1]?.trim() ?? '';
  return { n, title, date, summary };
}

function stagedFiles() {
  const out = git('diff --cached --name-only');
  return out ? out.split('\n').filter(Boolean) : [];
}

function writeReport(n, { title, summary, why, verified, next }) {
  mkdirSync(BUILDS_DIR, { recursive: true });
  const path = reportPath(n);
  const date = new Date().toISOString().slice(0, 10);
  // B-47: a re-run with a new title or summary rebuilds the hand-written
  // part; a re-run with the same title keeps any edits made to the report.
  let manual;
  if (existsSync(path)) {
    const old = readFileSync(path, 'utf8');
    const kept = /<!-- manual:start -->([\s\S]*?)<!-- manual:end -->/.exec(old)?.[1]?.trim();
    const keptTitle = kept && /^# Build \d+: (.+)$/m.exec(kept)?.[1]?.trim();
    if (kept && keptTitle === title) {
      manual = kept;
    } else if (kept) {
      console.warn(`replacing the report for build-${n}: title was "${keptTitle}"`);
    }
  }
  if (!manual) {
    manual = [
      `# Build ${n}: ${title}`,
      '',
      `Date: ${date}`,
      '',
      '## What changed',
      '',
      summary,
      '',
      '## Why',
      '',
      why || '—',
      '',
      '## How it was checked',
      '',
      verified || '—',
      '',
      '## Next improvement',
      '',
      next || '—',
    ].join('\n');
  }
  const files = stagedFiles();
  const body = [
    '<!-- manual:start -->',
    manual,
    '<!-- manual:end -->',
    '',
    '## Files changed',
    '',
    files.length ? files.map((f) => `- \`${f}\``).join('\n') : '- (no files staged when the report was written)',
    '',
  ].join('\n');
  writeFileSync(path, body);
  return path;
}

// The build number lives in three places that must agree: the git tag
// `build-N`, the `+N` in pubspec.yaml (Android versionCode / iOS build
// number) and lib/core/build_info.dart (shown in the app). --pending writes
// the last two so they cannot drift from the first.
function stampBuild(n) {
  const pub = join(ROOT, 'calley_app', 'pubspec.yaml');
  if (existsSync(pub)) {
    const t = readFileSync(pub, 'utf8');
    writeFileSync(pub, t.replace(/^version:\s*([\d.]+)\+\d+/m, `version: $1+${n}`));
  }
  const dart = join(ROOT, 'calley_app', 'lib', 'core', 'build_info.dart');
  writeFileSync(
    dart,
    `// Written by scripts/changelog.mjs --pending. Do not edit by hand.
//
// The project's build number. It is also the "+N" in pubspec.yaml (Android
// versionCode, iOS build number) and the git tag \`build-N\`, so an installed
// app, an APK file and a commit can always be matched.
const int kBuildNumber = ${n};
`,
  );
}

function regenChangelog() {
  if (!existsSync(BUILDS_DIR)) return;
  const reports = readdirSync(BUILDS_DIR)
    .map((f) => /^build-(\d+)\.md$/.exec(f))
    .filter(Boolean)
    .map((m) => parseReport(Number(m[1])))
    .sort((a, b) => b.n - a.n);
  const lines = [
    '# Changelog',
    '',
    'Generated by `scripts/changelog.mjs` from `MD/builds/`. Do not edit by hand.',
    'Newest first. Internal changes (`InBulNN` tags) carry no entry.',
    '',
  ];
  // No "pending" marker: the changelog is written before the commit that
  // --tag pins, and --tag must not touch files.
  for (const r of reports) {
    lines.push(`## Build ${r.n} — ${r.title}`, '', `${r.date}`, '', r.summary, '', `Report: [MD/builds/build-${r.n}.md](MD/builds/build-${r.n}.md)`, '');
  }
  writeFileSync(CHANGELOG, lines.join('\n'));
}

function tagHead() {
  const head = git('rev-parse HEAD');
  const title = git('log -1 --pretty=%s');
  const existing = git(`tag --points-at ${head}`);
  if (existing) throw new Error(`HEAD is already tagged: ${existing}`);
  if (/\(Build \d+\)/.test(title)) throw new Error('Commit titles must not carry "(Build N)"; the tag does.');

  const inbul = /^(InBul\d{2}):/.exec(title);
  if (inbul) {
    if (tags().includes(inbul[1])) throw new Error(`${inbul[1]} is already used.`);
    git(`tag ${inbul[1]} ${head}`);
    console.log(`tagged ${inbul[1]}`);
    return;
  }
  const n = nextBuild();
  const path = reportPath(n);
  if (!existsSync(path)) throw new Error(`No report for build-${n}. Run --pending first, or title the commit "InBulNN: ...".`);
  const { title: reportTitle } = parseReport(n);
  if (reportTitle !== title) throw new Error(`Commit title "${title}" does not match report title "${reportTitle}".`);
  git(`tag build-${n} ${head}`);
  console.log(`tagged build-${n}`);
}

function opt(args, name) {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : undefined;
}

const args = process.argv.slice(2);
try {
  if (args.includes('--next-internal')) {
    console.log(nextInternal());
  } else if (args.includes('--next-build')) {
    console.log(nextBuild());
  } else if (args.includes('--pending')) {
    const i = args.indexOf('--pending');
    const title = args[i + 1];
    const summary = args[i + 2];
    if (!title || !summary) throw new Error('--pending needs "<title>" "<summary>"');
    const n = nextBuild();
    const path = writeReport(n, { title, summary, why: opt(args, '--why'), verified: opt(args, '--verified'), next: opt(args, '--next') });
    stampBuild(n);
    regenChangelog();
    console.log(`wrote ${path}, CHANGELOG.md, pubspec +${n} and build_info.dart for build-${n}`);
  } else if (args.includes('--tag')) {
    tagHead();
  } else if (args.includes('--regen')) {
    regenChangelog();
    console.log('CHANGELOG.md regenerated');
  } else {
    console.log('usage: --next-internal | --next-build | --pending "<title>" "<summary>" [--why ..] [--verified ..] [--next ..] | --tag | --regen');
  }
} catch (e) {
  console.error(e.message);
  process.exit(1);
}
