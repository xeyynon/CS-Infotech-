# ui_screens.md — screen-by-screen spec (transcribed from Figma)

Source: https://www.figma.com/design/rjv6EBHWOg4yNNJLhLOKjF/Get-Calley-App-Design?node-id=0-1&p=f (view-only, 9 frames, iPhone-style status bar "09:40"). Overview image: [assets/figma-all-screens.png](assets/figma-all-screens.png).

Common: white background, blue primary (`~#2F6BFF`), full-width rounded primary buttons (~48 px, radius ~8), light-grey outlined text fields with trailing icon, Calley logo = multicolour swoosh + "CALLEY" wordmark + "AUTOMATIC CALL DIALER" tagline. Font looks like a geometric sans (Poppins/Inter-like) — verify in Figma inspect if you can sign in.

---

## 01 — Choose Your Language
- Title centered: **Choose Your Language**
- Card containing 9 rows, each: language name (bold) + native greeting (small grey) + radio on the right:
  1. English — "Hi"
  2. Hindi — "नमस्ते"
  3. Bengali — "হ্যালো"
  4. Kannada — "ನಮಸ್ಕಾರ"
  5. Punjabi — "ਸਤ ਸ੍ਰੀ ਅਕਾਲ"
  6. Tamil — "வணக்கம்"
  7. Telugu — "హలో"
  8. French — "Bonjour"
  9. Spanish — "Hola"
- English selected by default.
- Bottom: primary button **Select**.

## 02 — Register ("Welcome!")
- Logo block at top (centered).
- Card: heading **Welcome!**, sub "Please register to continue".
- Fields (each with trailing icon): Name (person), Email address (mail), Password (lock), **+91** (flag + WhatsApp icon — country code row), Mobile number (phone).
- Checkbox: "I agree to the **Terms and Conditions**" (link styled).
- Text: "Already have an account? **Sign In**".
- Primary button **Sign Up**.

## 03 — WhatsApp OTP Verification
- Logo block.
- Heading (2 lines, centered): **Whatsapp OTP Verification**
- Sub: "Please ensure that the email id mentioned is valid as we have sent an OTP to your email."
- 6 square OTP boxes.
- Below: `+91 7676286822?` (the trailing "?" is in the design — treat as "wrong number?" affordance or drop it).
- "Didn't receive OTP code? **Resend OTP**"
- Primary button **Verify**.

## 04 — Login ("Welcome")
- Logo block.
- Card: heading **Welcome**, sub "Please sign-in to continue".
- Fields: Email address (mail icon), Password (lock icon).
- Right-aligned link **Forgot Password?**
- "Don't have an account? **Sign Up**"
- Primary button **Sign In**.

## 05 — Getting Started (post-login)
- Blue rounded card: avatar + "Hello Swati" (small) / **Calley Personal** (bold).
- Dark-navy header strip: "If you are here for the first time then ensure that you have uploaded the list to call from calley Web Panel hosted on https://app.getcalley.com"
- Below it: image "2 MINUTE CHALLENGE" with YouTube play badge (opens a YouTube video — URL unknown; use a Calley tutorial from https://www.youtube.com/c/CalleyAutomaticCallDialerApp).
- Bottom row: green WhatsApp square button + primary **Star Calling Now** (render "Start Calling Now", DEC-004).

## 06 — Dashboard (empty state)
- AppBar: hamburger, **Dashboard**, trailing refresh + bell icons.
- Blue card: avatar, "Hello Swati" / **Welcome to Calley!**
- Card with dark header **LOAD NUMBER TO CALL**, body: "Visit https://app.getcalley.com to upload numbers that you wish to call using Calley Mobile App." + illustration (person at desk with phone).
- Bottom row: WhatsApp button + **Star Calling Now**.
- Bottom navigation (5): home, contact-card, **center play button (raised blue pill)**, phone, calendar.

## 07 — Settings + Calling Lists (shown as overlay/sheet over a dimmed screen)
- AppBar: back, **Setting**.
- Dark profile card: avatar, "Hello Swati", swati@cstech.in, 9871125588, "Parent Account: NA", "Current Subscription: Calley Personal".
- Section header **PROFILE SETTINGS** (dark bar): rows "App Language" (globe icon, chevron), "Change Password" (lock, chevron).
- Section header **CALLING LISTS**: row "Select Calling List" with a blue **Refresh** button (refresh icon).
- List row: **Test List** with a circled-arrow on the right (tap → select).

## 08 — Dashboard (active list)
- AppBar as 06.
- White card: "Test List" (small) / **50 CALLS** (blue, large) and a blue circular avatar "S" on the right.
- Donut chart, 3 segments: blue (largest), purple, yellow; hollow center.
- Three stat cards in a row, each with a left colour bar:
  - Pending **28** Calls (yellow bar)
  - Done **22** Calls (green/blue bar)
  - Schedule **09** Calls (purple bar)
- Primary **Star Calling Now**.
- Bottom nav as 06.

## 09 — Side drawer
- Blue header: avatar, **Swati** · Personal, swati@cstech.in.
- Items (icon + label): Getting Started, Sync Data, Gamification, Send Logs, Settings, Help?, Cancel Subscription.
- Section label **App Info**: About Us, Privacy Policy, Version 1.01.52, Share App, Logout.
- Drawer overlays 08 (dimmed).

---

## Implied 10th screen — Calling Queue (not in Figma)
Design freely in the same language: list of call records (`Title FirstName LastName`, Company, Phone, status chip), filter chips All/Pending/Done/Scheduled, tap → dial. See DEC-006.

## Colour/size notes to extract from Figma (todo)
- [ ] Exact primary blue, navy header, yellow, purple, green
- [ ] Font family + weights
- [ ] Button height/radius, card radius, page padding
