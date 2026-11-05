# MD — project documentation index

Documentation for the **Calley Flutter machine test** (C S Tech Infosolutions Pvt. Ltd.).
Modeled on the doc layout from the previous project. Files marked *(template)* are empty
scaffolds to be filled as work progresses.

## Core reference

- [calley_MASTER.md](calley_MASTER.md) — master reference for the whole project. When documents disagree, trust the code first and this file second.
- [prd.md](prd.md) — product requirements and what "done" means.
- [intent.md](intent.md) — why this project exists: the test, the evaluator, the design principles.
- [rules.md](rules.md) — the project rulebook; constraints on how things are built.
- [decisions.md](decisions.md) — log of key decisions and their reasons (DEC-001 onwards).
- [tasks.md](tasks.md) — living task tracker.
- [video_requirements.md](video_requirements.md) — the task video step by step against the app (all steps met).
- [frontendcalley.md](frontendcalley.md) — **how the frontend was designed and built**, written to be reused: principles, HCI rules, design system, component kit, accessibility traps, testing tricks, audit process, build order, checklist.
- [plan_drawer_features.md](plan_drawer_features.md) — plan and checklist for the drawer and bell features (branch `feature/drawer-and-reminders`).
- [bugs.md](bugs.md) — verified bug register from the 2026-11-05 audit (47 confirmed, 20 refuted).
- [bugfixed.md](bugfixed.md) — what was done about each bug, and the UX changes made with them.
- [version_control.md](version_control.md) — builds vs InBuls, tags, `scripts/changelog.mjs`, how to push.

## Design and architecture

- [system_architecture.md](system_architecture.md) — the planned app architecture (layers, state, folders).
- [flow.md](flow.md) — end-to-end flow from app launch to a logged call disposition.
- [ui_screens.md](ui_screens.md) — screen-by-screen spec transcribed from the Figma file.
- [api_reference.md](api_reference.md) — the mock REST API: endpoints, bodies, response shapes.

## Research

- [external_research.md](external_research.md) — reproducible log of everything found about the assignment, the company, the product and prior submissions.
- [deployment.md](deployment.md) — build/submission checklist (APK, repo access, recording).

## Risks and lessons

- [pain.md](pain.md) — what can break the submission and how badly.
- [tried_and_failed.md](tried_and_failed.md) *(template)* — approaches that didn't work.
- [tried_and_implemented.md](tried_and_implemented.md) *(template)* — approaches confirmed working.

## Assets

- [assets/figma-all-screens.png](assets/figma-all-screens.png) — all 9 Figma frames, one image.
- [assets/notion-page.png](assets/notion-page.png) — the assignment page as published.
- [assets/video-frame-0m28s.png](assets/video-frame-0m28s.png) — one frame of the task video.
- [assets/sample-list-details.json](assets/sample-list-details.json) — full 50-record `GET /api/list/{listId}` payload (from a prior candidate's offline mock, said to match the Postman collection).

Not recreated from the old project: `architecture.md`, `agents.md`, `system_design_and_boundary.md`,
`readme.md`, `frontend.md` — those were marked stale/outdated there and there is no equivalent here yet.
