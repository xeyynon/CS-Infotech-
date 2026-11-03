# external_research.md — research log

Reproducible log of what was looked at, how, and what it yielded. Date: **2026-11-04**.

## R1 — The assignment page (Notion)

**URL:** https://cstechmk.notion.site/Machine-Test-Flutter-Mobile-App-Developer-c6a13eb9445e49479c0b0eaeda49ca8e
**Method:** Loaded in Playwright, extracted `document.body.innerText` and all `a/iframe` srcs. Screenshot: [assets/notion-page.png](assets/notion-page.png).
**Full text (verbatim, this is everything):**

> **[Machine Test] - Flutter Mobile App Developer**
> As a Flutter Developer, we will expect you to be able to make mobile applications with backend integration to our rest API. Once created, we want them deployed on the Android Play Store and Apple App Store.
> PLEASE NOTE : THIS IS NOT A WORK FROM HOME OPPORTUNITY ONLY THE TEST CAN BE DONE FROM HOME.
> **Video of the task to be done** — [embedded YouTube `bP4U-L4EHcg`]
> **UI Designs** — You can use the attached Figma file as a reference for creating the UI in Flutter.
> https://www.figma.com/design/rjv6EBHWOg4yNNJLhLOKjF/Get-Calley-App-Design?node-id=0-1&p=f

**Findings:** No API docs, no deadline, no deliverables list, no email address on the page. Everything else must come from the video, Figma, or the HR email.

## R2 — The task video

**URL:** https://www.youtube.com/watch?v=bP4U-L4EHcg
**Facts (from `ytInitialPlayerResponse`):** title "Flutter Machine Test", channel **Retaxis** (25 subscribers), unlisted, ~1.3k views, uploaded ~1 year ago, **2:20 long**, no description, auto-captions track exists but returns empty (silent video).
**Method:** Tried fetching caption XML/json3 → 200 with empty body. Tried seeking the embedded player headlessly → frame didn't refresh (autoplay blocked). One frame captured at 0:28: [assets/video-frame-0m28s.png](assets/video-frame-0m28s.png) — shows the Getting Started screen (Hello Swati / Calley Personal / 2 MINUTE CHALLENGE), i.e. the video is a phone-screen recording of the app flow.
**Action:** Watch it yourself with sound off; note screen order and any interaction Figma doesn't show (tasks §0).

## R3 — The Figma file

**URL:** https://www.figma.com/design/rjv6EBHWOg4yNNJLhLOKjF/Get-Calley-App-Design?node-id=0-1&p=f
**Method:** Loaded anonymously (view-only, "Sign up to comment, edit, inspect" bar). Screenshot at device scale: [assets/figma-all-screens.png](assets/figma-all-screens.png). Transcribed into [ui_screens.md](ui_screens.md).
**Findings:** 9 frames numbered 01–09; one page; demo user "Swati" (swati@cstech.in, 9871125588, Calley Personal); demo list "Test List", 50 calls; stats 28/22/09; app version string "1.01.52"; WhatsApp number in OTP screen `+91 7676286822`.
**Limitation:** Inspect panel (exact hex, font, spacing) needs a Figma login. Sign in with a free account to read values.

## R4 — The company and product

- **C S Tech Infosolutions Private Limited** — publisher of **Calley** ("Automatic Call Dialer") on App Store (id 1222888599, since ~2017) and Play Store (`com.getcalley.app.calley`). Web panel: https://app.getcalley.com. Marketing site: getcalley.com. HubSpot marketplace listing (Calley PRO ≈ $24/mo). Official YouTube: https://www.youtube.com/c/CalleyAutomaticCallDialerApp.
- Product: upload a calling list on the web panel → sync to phone → "Start Calling" auto-dials one by one → agent saves a disposition/note after each call → next call.
- Why it matters: the test app is literally the first 9 screens of their real app. Installing the real Calley app from the Play Store and tapping through it is the **best possible reference** for behaviour the Figma doesn't show.

Sources: [App Store](https://apps.apple.com/in/app/calley/id1222888599), [appgoblin Play listing](https://appgoblin.info/apps/com.getcalley.app.calley), [HubSpot listing](https://ecosystem.hubspot.com/marketplace/apps/calley-2085162), [Calley setup video](https://www.youtube.com/watch?v=hzwSizmvMD0).

## R5 — Prior public submissions (the key find)

Search for the video ID surfaced two candidates' GitHub repos for this exact test:

### R5a — `Renukaaapatil/calley_app`
https://github.com/Renukaaapatil/calley_app
- Provider + http + shared_preferences + url_launcher; custom `CustomPainter` donut.
- 52 files; `lib/constants/api_endpoints.dart` gives the base URL and all 6 endpoints (copied into [api_reference.md](api_reference.md)); `lib/services/mock_data.dart` gives sample User / CallingList / ListDetails JSON.
- README lists a **deliverables checklist**: source matching Figma, API integration "with Postman collection", dashboard with donut, dispositions + dialer, GitHub access to `info@cstech.in`, debug APK, screen recording.
- Weaknesses to avoid: disables TLS verification globally; every endpoint silently returns fake success on failure.

### R5b — `nikhilswami992/calley_app`
https://github.com/nikhilswami992/calley_app
- Calls it "Mock API V2"; same base URL/endpoints; Riverpod-less Provider; google_fonts; repository with remote → local-JSON fallback.
- `assets/mock/list_details.json` = the full 50-record payload, "exact JSON payloads from the Postman collection" → saved as [assets/sample-list-details.json](assets/sample-list-details.json).
- README has unresolved merge-conflict markers — a reminder to proofread yours.

Both independently confirm: 9 screens + a calls list screen, same 6 endpoints, same demo data. Neither has stars; neither is known to have passed.

## R6 — Mock API reachability

```
curl -s -m 15 'https://mock-api.calleyacd.com/api/list?userId=test'   → exit 60 (TLS/cert error), HTTP 000
curl -s -m 15 'https://mock-api.calleyacd.com/'                        → exit 60
```
Not retried with `-k` (deliberately — don't normalise cert bypass). Next step: open the URL in a browser to read the actual certificate error (expired? wrong CN? self-signed?), then test in Postman with SSL verification toggled, and ask HR whether the host is still live.

## R7 — Web searches that found nothing useful
- "CS Tech Infosolutions Flutter machine test Calley API" → generic Flutter tutorials only.
- No Glassdoor/LinkedIn write-ups of this test were found in a standard search.

## Gaps remaining
1. Video content (watch it).
2. Exact API responses (test it).
3. Deadline + submission address (email).
4. Figma exact values (sign in).
