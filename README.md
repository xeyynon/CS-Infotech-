# Calley — Flutter machine test

Submission for the **Flutter Mobile App Developer** machine test at C S Tech Infosolutions Pvt. Ltd.: a Flutter build of the Calley (automatic call dialer) onboarding and dashboard, from the supplied Figma file, against the Calley mock REST API.

| | |
|---|---|
| App source | [`calley_app/`](calley_app/) — see its [README](calley_app/README.md) for setup, architecture and screenshots |
| Screenshots | [`calley_app/snapshots/`](calley_app/snapshots/) (light and dark, every screen) |
| Project docs | [`MD/`](MD/) — research, requirements, decisions, risks; start at [`MD/README.md`](MD/README.md) |
| Change history | [`CHANGELOG.md`](CHANGELOG.md) (generated) and `git tag` — see [`MD/version_control.md`](MD/version_control.md) |

## Why the app uses demo data

**The API supplied for this test is not reachable, so the app ships with a demo mode.** Everything else is built against the real API.

- The test points to the Postman collection [Mock API V2](https://documenter.getpostman.com/view/38199901/2sB34Zpiy9), at `https://mock-api.calleyacd.com/api`. A copy is kept in [`MD/assets/postman-mock-api-v2.json`](MD/assets/postman-mock-api-v2.json).
- When checked on 2026-11-04 and again on 2026-11-05, **every documented endpoint returned HTTP 404** with an empty body: register, login, send-otp, verify-otp, list and list details.
- The server's TLS certificate is issued to the hosting provider's name (`cool-meninsky.74-208-123-142.plesk.page`), not to `mock-api.calleyacd.com`, so browsers and Postman refuse the connection.
- The root URL shows the hosting provider's default page. Together this suggests the domain is still parked on the hosting server but the API app is not deployed there.
- You can check this yourself: <https://mock-api.calleyacd.com/api/list?userId=68626f9497757cb741f449b0>.

**What the app does about it:**

1. **It calls the real API first.** Requests, bodies and response parsing follow the Postman collection exactly, including login's `{"user": {...}}` wrapper and `GET /list` returning a single object. TLS is not switched off: the app trusts only that one server's certificate.
2. **When a call fails, it says why.** For example: *"Not available on the Calley test server"*, with **Retry** and **Use sample data**. It never shows a fake success.
3. **Sample data is the collection's own examples.** The "Test List" and its 50 contacts in `calley_app/assets/mock/` are copied from the Postman example responses, so every list screen shows what the real API would return. The signed-in user is Swati, the person in the Figma screens.
4. **A banner stays on every screen while sample data is on.** It cannot be mistaken for live data, and **Try server** switches back.
5. **The demo login** below goes straight to sample mode, so the whole flow can be tested in one tap.

**If the API comes back or moves:** nothing needs rebuilding for the same host. A new address is one build setting: `flutter run --dart-define=API_BASE_URL=https://new-host/api`. If the new server presents a different certificate, its SHA-256 fingerprint is added in `calley_app/lib/core/network/api_client.dart`.

## Demo login

| Email | Password |
|---|---|
| `demo@getcalley.com` | `Demo@1234` |

The login screen shows these, with a one-tap **Sign in with the demo account** button. Any other email goes to the real API.

## Run it

```
cd calley_app
flutter pub get
flutter run                       # device or emulator
flutter build apk --debug         # build/app/outputs/flutter-apk/app-debug.apk
```
