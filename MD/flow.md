# flow.md — end-to-end flow

Order follows the Figma frame numbering, which is what the reviewer expects. Confirm against the video (tasks §0).

```
App launch
  │
  ├─ session present ──────────────────────────────► 06/08 Dashboard
  │
  └─ no session
        ▼
  01 Choose Language ──Select──► 02 Register
                                   │ POST /auth/register {username,email,password}
                                   │ POST /auth/send-otp {email}
                                   ▼
                                03 OTP Verify ──Verify──► POST /auth/verify-otp {email,otp}
                                   │ (Resend → send-otp again)
                                   ▼
                                04 Login ──Sign In──► POST /auth/login {email,password}
                                   │ save session {userId, username, email, phone, subscription}
                                   ▼
                                05 Getting Started
                                   │ "Start Calling Now"
                                   ▼
                                06 Dashboard (empty) ──► GET /list?userId=…
                                   │                      │
                                   │          lists empty ─┘ stay on 06
                                   │          lists found → user picks in 07 sheet / settings
                                   ▼
                                07 Settings / Calling Lists ──select "Test List"──► GET /list/{listId}
                                   ▼
                                08 Dashboard (active) : donut + Pending/Done/Schedule
                                   │ "Start Calling Now"
                                   ▼
                                10 Calling Queue : filter → tap → tel:<Phone> → disposition dialog (local)
                                
  09 Drawer (from any dashboard screen): Getting Started → 05, Settings → 07, Logout → clear session → 04
```

## Data flow per screen

| Screen | Reads | Writes |
|--------|-------|--------|
| 01 | — | prefs.language |
| 02 | — | API register; keeps email in memory for OTP |
| 03 | email from 02 | API send-otp / verify-otp |
| 04 | — | API login → prefs.session |
| 05 | session.username, subscription | — |
| 06 | session.userId → lists | prefs.selectedListId (null) |
| 07 | session, lists | prefs.selectedListId |
| 08 | selectedListId → listDetails | — |
| 09 | session | clears prefs on logout |
| 10 | listDetails.calls | in-memory disposition map |

## Edge cases to handle
- Register returns 4xx (user exists) → show message, offer "Sign In".
- OTP wrong → inline error, keep digits.
- Lists call returns `[]` → stay on empty dashboard with the "LOAD NUMBER TO CALL" card.
- List details slow → skeleton/shimmer on the donut area.
- Network down → ErrorView with retry on 06/07/08; auth screens show snackbar.
