# prd.md — product requirements

## Goal

Ship a Flutter app that reproduces the 9 Figma screens of the Calley onboarding/dashboard flow,
backed by the Calley mock REST API, and package it for review (repo + APK + recording).

## Users

- **Primary:** the reviewer at C S Tech (likely a senior Flutter dev / CTO) who will open the repo, install the APK, and compare against Figma + their own app.
- **Simulated end user:** "Swati", a Calley Personal subscriber who registers, verifies OTP, logs in, sees her calling list, and starts calling.

## Functional requirements

### FR-1 Language selection
- 9 languages with native-script subtitle; single-select radio; persisted locally.
- "Select" navigates to Register. (Actual i18n of strings is **nice-to-have**, not required by the brief.)

### FR-2 Registration
- Fields: Name, Email, Password, Country code (+91, fixed or picker), Mobile number, T&C checkbox.
- Validation: non-empty, email format, password ≥ 6, 10-digit mobile, checkbox must be ticked.
- `POST /api/auth/register` with `{username, email, password}` → on success go to OTP.
- Link to Login.

### FR-3 OTP verification
- 6 single-digit boxes, auto-advance, backspace moves back; paste support is nice-to-have.
- Copy mentions email; mobile shown as `+91 <number>`.
- `POST /api/auth/send-otp` on arrival (or on Resend); `POST /api/auth/verify-otp` with `{email, otp}` on Verify.
- Resend with countdown (30 s used by a prior candidate; not specified).

### FR-4 Login
- Email + password, show/hide password, "Forgot Password?" (can be a stub dialog).
- `POST /api/auth/login` → store user (id, name, email, phone, subscription) locally; go to Getting Started.

### FR-5 Getting Started
- Greeting card (`Hello <name>` / plan), instruction text, "2 MINUTE CHALLENGE" thumbnail that opens YouTube, WhatsApp button (deep link), "Start Calling Now" → Dashboard.

### FR-6 Dashboard — empty state
- Shown when no calling list is selected / none exist. "LOAD NUMBER TO CALL" card with link to https://app.getcalley.com.
- Bottom nav with 5 items (home, contacts/list, play (center, highlighted), phone, calendar) per Figma.

### FR-7 Calling lists
- `GET /api/list?userId={id}` → list of `{_id, name}`; shown in a bottom sheet / settings section with a **Refresh** button.
- Selecting a list switches Dashboard to the active-list state.

### FR-8 Dashboard — active list
- `GET /api/list/{listId}` → `{pending, called, rescheduled, calls[]}`.
- Card: list name + `N CALLS` (N = `calls.length`).
- Donut chart with 3 segments (Done=blue, Pending=yellow, Schedule=purple), animated.
- 3 stat cards: Pending, Done, Schedule with counts from the API.
- "Start Calling Now" → calling queue (FR-9) or `tel:` the first pending number.

### FR-9 Calling queue (not in Figma, shown/implied by brief "start calling")
- List of `calls[]` filterable All / Pending / Done / Scheduled; tap → `tel:` launch.
- Optional disposition dialog after call (values seen in data: Very positive, Satisfied, Needs follow-up, Neutral, Negative). Keep in-memory — the mock API has no write endpoint.

### FR-10 Drawer + Settings
- Drawer with header + menu items as in Figma; Logout clears local session and returns to Login.
- Settings screen with profile header, App Language, Change Password (stubs OK), Calling Lists section.

## Non-functional

- Pixel-faithful to Figma on a 390×844 viewport; sane on small (360) and large screens.
- No crash when the API is down: show an error state with retry (and optional cached/mock fallback — must be clearly labelled, see rules R-06).
- Cold start < 2 s on a mid-range Android device.
- `flutter analyze` clean; at least a handful of widget/unit tests.

## Definition of done

- [ ] All 9 Figma screens implemented and navigable in the Figma order.
- [ ] All 6 API endpoints called from the app with correct bodies.
- [ ] Donut + stats driven by live API data.
- [ ] Logout / session persistence works across app restarts.
- [ ] `flutter build apk --debug` succeeds; APK attached to GitHub release or shared.
- [ ] README in repo: setup, architecture, API, screenshots, known issues.
- [ ] Screen recording (≤ 3 min) covering the full flow.
- [ ] Repo access granted to `info@cstech.in` (verify the exact address from your email).

## Out of scope

- Real telephony / auto-dialing; real OTP delivery; Play Store / App Store publishing (mentioned in brief as what the *job* entails, not the test).
- iOS build (unless you have a Mac — nice-to-have).
