# calley_MASTER.md — master reference

> Precedence: **code > this file > every other doc**. Last updated 2026-11-04.

## 1. What this is

A take-home **machine test** for the *Flutter Mobile App Developer* role at
**C S Tech Infosolutions Private Limited** (brand: *Calley*, auto-dialer product; website getcalley.com; HR email per prior candidates: `info@cstech.in`).

The candidate builds a Flutter clone of the **Calley mobile app onboarding + dashboard** from a Figma file, wired to the company's **mock REST API**, and submits source + APK + recording.

The role itself is **on-site** — the page says in caps: *"THIS IS NOT A WORK FROM HOME OPPORTUNITY. ONLY THE TEST CAN BE DONE FROM HOME."*

## 2. Primary sources (read these, in this order)

| # | Source | URL | What it gives |
|---|--------|-----|---------------|
| 1 | Notion assignment page | https://cstechmk.notion.site/Machine-Test-Flutter-Mobile-App-Developer-c6a13eb9445e49479c0b0eaeda49ca8e | 3 sentences of brief + video + Figma link. That's all. |
| 2 | Task video (2:20, unlisted, channel "Retaxis", silent, no description/captions) | https://www.youtube.com/watch?v=bP4U-L4EHcg | Screen recording of the expected app flow. **Watch it yourself** — it is the only place the expected behaviour is shown. |
| 3 | Figma design | https://www.figma.com/design/rjv6EBHWOg4yNNJLhLOKjF/Get-Calley-App-Design?node-id=0-1&p=f | 9 phone frames (view-only). See [ui_screens.md](ui_screens.md). |
| 4 | Mock API | `https://mock-api.calleyacd.com/api` | 6 endpoints. See [api_reference.md](api_reference.md). **Not on the Notion page** — came from prior candidates' repos; the official Postman collection was presumably sent by email. Ask HR if you don't have it. |

## 3. The nine screens (canonical list)

| # | Screen | Key elements |
|---|--------|--------------|
| 01 | Choose Your Language | 9 radio options (English, Hindi, Bengali, Kannada, Punjabi, Tamil, Telugu, French, Spanish), each with native-script subtitle; **Select** button |
| 02 | Register — "Welcome! Please register to continue" | Calley logo; Name, Email, Password, +91 country code + Mobile; T&C checkbox; **Sign Up**; "Already have an account? Sign In" |
| 03 | WhatsApp OTP Verification | 6 OTP boxes; "sent to your email" copy; shows mobile `+91 7676286822?`; Resend OTP; **Verify** |
| 04 | Login — "Welcome. Please sign-in to continue" | Email, Password, Forgot Password?; **Sign In**; "Don't have an account? Sign Up" |
| 05 | Getting Started | Blue card "Hello Swati / Calley Personal"; note about uploading list at https://app.getcalley.com; "2 MINUTE CHALLENGE" YouTube thumbnail; WhatsApp button + **Star Calling Now** (sic — typo in design, see rules) |
| 06 | Dashboard — empty state | AppBar "Dashboard" (menu, refresh, bell); greeting card; "LOAD NUMBER TO CALL" card with link + illustration; WhatsApp button + **Star Calling Now**; 5-tab bottom bar |
| 07 | Settings + Calling Lists sheet | Dark profile header (name, email, phone, Parent Account, Current Subscription); PROFILE SETTINGS: App Language, Change Password; CALLING LISTS: "Select Calling List" + **Refresh**; list row "Test List" |
| 08 | Dashboard — active list | "Test List / 50 CALLS" card with avatar "S"; 3-segment donut (blue/yellow/purple); stat cards Pending 28 · Done 22 · Schedule 09; **Star Calling Now** |
| 09 | Side drawer | Header "Swati · Personal / swati@cstech.in"; Getting Started, Sync Data, Gamification, Send Logs, Settings, Help?, Cancel Subscription; App Info: About Us, Privacy Policy, Version 1.01.52, Share App, Logout |

Design mismatch to be aware of: Figma stats are 28/22/09 (=59) while the card says 50 calls and the API sample returns 27 pending / 23 called / 11 rescheduled (=61, with 50 call records). **Render whatever the API returns**; don't hard-code Figma numbers.

## 4. Deliverables (consensus from prior submissions — confirm against your HR email)

1. Flutter source matching the Figma designs
2. REST API integration (register / login / OTP / lists / list details)
3. Dashboard with donut chart + stats
4. GitHub repo, access shared with `info@cstech.in`
5. Debug APK (`flutter build apk --debug`)
6. Screen recording of the app running

## 5. Stack decision (see [decisions.md](decisions.md))

Flutter stable · Dart 3 · Riverpod *or* Provider (DEC-002) · `dio` or `http` · `shared_preferences` · `url_launcher` · custom `CustomPainter` donut · no code-gen unless justified.

## 6. Where things live

```
E:\Projects\CS\
├── MD\            ← these docs
│   └── assets\    ← screenshots, sample JSON
└── (app to be created: calley_app\)
```

## 6a. Where things are (updated 2026-11-04 evening)

- App: `calley_app/` — built, analyzer clean, 32 snapshot tests green. README there.
- Snapshots: `calley_app/snapshots/{light,dark}/` — every screen, rendered by the tests.
- Repo: https://github.com/xeyynon/CS-Infotech- — tags `build-1000`, `InBul01` (see [version_control.md](version_control.md)).
- APK: `calley_app/build/app/outputs/flutter-apk/app-debug.apk` after `flutter build apk --debug` (not committed; attach to a Release).

## 6b. The company (from the user, 2026-11-05)

Product: https://www.getcalley.com/ · Company: https://www.csquaretech.com/ (C S Tech Infosolutions; web design/dev + SaaS: Calley, CloudSync, DripZen). Contact info@csquaretech.com, +91 99711 25588, WhatsApp +91 99711 25511. **Use the address in the HR email for the submission**; `info@cstech.in` was only a prior candidate's guess.

## 7. Open questions (as of 2026-11-04)

- **The mock API is not serving.** Host up, cert for its Plesk name (pinned, DEC-010), every `/api/*` path → empty 404. The app offers labelled sample data when it fails. → [api_reference.md](api_reference.md), [pain.md](pain.md) P-01. **Ask HR for the current API.**
- Exact response bodies for `register`, `login`, `send-otp`, `verify-otp` — not recovered. Only inferred (`login` → `{ "user": {...} }`).
- Is a Postman collection expected *in the repo*, or was it an input? One candidate lists "API Integration with Postman collection" as a deliverable.
- Deadline — not on the page. Check your email.
