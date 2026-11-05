# video_requirements.md — the task video, step by step, against the app

The task video (<https://www.youtube.com/watch?v=bP4U-L4EHcg>, 2:20, unlisted, silent) was downloaded and cut into one frame per second on 2026-11-05. It is a **click-through of the Figma prototype**: no real data, no API, just which tap leads to which screen. Those taps are the functional requirements.

| Time | In the video | In the app | Met? |
|---|---|---|---|
| 0:00–0:07 | Figma canvas with the 9 frames | — | — |
| 0:08–0:24 | **Choose Your Language**: 9 languages, English selected, tap **Select** | Same screen and wording; Select → Register; choice remembered | ✅ |
| 0:21–0:28 | **Register "Welcome!"**: Name, Email, Password, +91 / Mobile, Terms, "Already have an account? Sign In", **Sign Up** | Same fields, validated; Sign Up calls register + send-otp → OTP | ✅ |
| 0:29–0:48 | **Whatsapp OTP Verification**: 6 boxes, `+91 7676286822?`, Resend OTP, **Verify** | Same; shows the number typed on Register with "Wrong details?"; Verify calls verify-otp → Login | ✅ |
| 0:49–0:53 | **Login "Welcome"**: Email, Password, Forgot Password?, "Don't have an account? Sign Up", **Sign In** | Same; plus the demo account card | ✅ |
| 0:54–1:11 | **Getting Started**: "Hello Swati / Calley Personal", web-panel note, 2 MINUTE CHALLENGE, WhatsApp, **Star Calling Now** | Same content; the video opens YouTube; the button reads "Start Calling Now" (DEC-004) | ✅ |
| 1:12–1:24 | **Dashboard (empty)**: "Hello Swati / Welcome to Calley!", LOAD NUMBER TO CALL, bottom bar with the centre ▶ | Same | ✅ |
| 1:22–1:35 | Tap ▶ → **Settings with the CALLING LISTS panel**: Select Calling List, **Refresh**, tap **Test List** | ▶ or Start Calling Now opens the Calling Lists sheet (Select Calling List, Refresh, Test List). The full Settings screen with the same panel is in the drawer | ✅ (shown as a sheet over the dashboard rather than over Settings) |
| 1:37–1:50 | **Dashboard (active)**: "Test List · 50 CALLS", donut (blue, yellow, purple), **Pending 28 · Done 22 · Schedule 09**, Star Calling Now | Same layout; numbers come from the API data: Pending 27 · Done 12 · Scheduled 11 = 50 (DEC-017) | ✅ (figures differ on purpose: the Figma numbers are placeholders) |
| 1:51–2:08 | **Drawer**: Swati · Personal, Getting Started, Sync Data, Gamification, Send Logs, Settings, Help?, Cancel Subscription, App Info (About Us, Privacy Policy, Version 1.01.52, Share App), Logout | Every item present; working ones open real pages; Logout asks first | ✅ |
| 2:09–2:19 | Back through Dashboard → Login → Register → Language | Back navigation works; the session is remembered across restarts | ✅ |

**Every step of the video is in the app.** On branch `feature/drawer-and-reminders` the drawer's Gamification, Send Logs, Cancel Subscription and Share App, and the bell, are working features rather than stubs (see [plan_drawer_features.md](plan_drawer_features.md)). Beyond it, the app adds what a working dialer needs and the prototype could not show: the real API calls, error states, the calling queue (search, filters, dial, log outcome, undo, progress), sample data while the server is down, the demo login, and light/dark themes.

**Small visual differences, deliberate:**
- The active-list card shows "50 contacts" and a switch-list icon instead of the "S" avatar.
- The dashboard keeps the bottom bar on both states.
- "Start Calling Now" instead of "Star Calling Now".

The logo is now the official artwork from getcalley.com: transparent, plus a dark-theme copy whose tagline and lettering are lightened.
