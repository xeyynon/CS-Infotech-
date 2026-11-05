# plan_drawer_features.md — plan of action for the drawer and bell features

Branch: `feature/drawer-and-reminders` (from `main` at `InBul04`). Chosen by the user on 2026-11-05 from four candidate feature sets; the other three (language switching, the skipped Figma-conflicting UX items, auto-dial) stay in [tasks.md](tasks.md) for a later branch.

## Why these

In the task video the drawer lists Gamification, Send Logs, Cancel Subscription, Share App, and the dashboard has a bell. In the app today each of those only shows "not part of this test build" or does something thinner than its name (Share App opens a web page). A reviewer who taps them sees an unfinished app.

## Rules for every feature

1. **Real data only** (R-06, R-02). Everything shown is derived from the list data and the outcomes logged on this phone. Nothing is invented to look busy.
2. **Say what it is not.** The test server stores no outcomes and has no cancel/password endpoint; screens say so in one plain sentence instead of pretending.
3. **Same design language**: paper background, display headings, mono figures, dot-and-word status, 48 dp targets, light and dark.
4. **Testable without a phone**: logic lives in pure functions with unit tests; each screen gets light and dark snapshots; the platform (share sheet, mail) is behind `launcherProvider` so tests stub it.

## The five features

| # | Feature | Where it appears | What it does | Data source |
|---|---|---|---|---|
| F1 | **Your progress** (Gamification) | Drawer → Gamification, `/progress` | Level from share of the list reached, a progress bar to the next level, outcomes logged by type, five badges (first outcome, five outcomes, halfway, clean sweep, positive vibes) | `ListDetails` + logged outcomes |
| F2 | **Reminders** | Bell on the dashboard (with a count badge), `/reminders` | Scheduled calls grouped Overdue / Today / Upcoming, oldest first; one tap dials and then asks for the outcome; a logged call leaves the list | Records with `rescheduledAt`; the clock |
| F3 | **Send logs** | Drawer → Send Logs, sheet | Shows exactly the report that would be sent (app version, platform, data source, list and counts, outcome totals; **no names or phone numbers**), then **Email to support** (support@getcalley.com) or **Copy** | App state |
| F4 | **Share App** | Drawer → Share App | System share sheet with a short message and the download link | `Links.download` |
| F5 | **Cancel subscription** | Drawer → Cancel Subscription, sheet | Explains that plans are managed outside the app, with **Manage on Google Play**, **Contact support**, and **Keep my plan** (the default, first button) | Links |

Not built, on purpose: Change Password and Forgot Password (the API has no endpoint, so the existing honest dialogs stay).

## Work breakdown

1. `call_actions.dart`: extract "dial, then log the outcome (with Undo)" so the queue, the reminders and the dashboard phone tab share one path.
2. Pure logic + unit tests: `progress_stats.dart`, `reminders.dart`, `log_report.dart`.
3. Screens: progress, reminders, send-logs sheet, cancel sheet; share through `Launcher.share`.
4. Wire: two routes, drawer items, bell badge.
5. Snapshots: progress (empty and active), reminders, send logs, cancel, drawer, bell badge; light and dark.
6. Docs: README, tasks, decisions, this plan's checklist.
7. Release: `build-1003` on the branch; merge to `main` when approved.

## Done means

- [x] Each of F1–F5 reachable from the screen named above and working with the demo account.
- [x] `flutter analyze` 0 issues; `flutter test` 107 passed, with unit tests for the three pure modules and behavior tests for share, mail and reminders.
- [x] Snapshots reviewed in both themes, no overflow at 390×844.
- [x] No contact name or phone number leaves the phone through Send Logs.
- [x] Documented in the README feature table and `MD/tasks.md`.
