# bugs.md: bug register

Found by an audit run on 2026-11-05: 8 bug-finding lenses (state, routing, network, layout, forms, models, accessibility, tooling) plus 3 fresh-eyes finders, merged to 67 distinct claims. Each claim then went to **three independent verifiers told to refute it** (framework semantics, reproduction, impact). A claim stands only if at least two of the three could not refute it. **47 stood; 20 were refuted** (listed at the end so nobody re-raises them).

Severity: **S1** breaks a flow or corrupts state · **S2** wrong behaviour a user would notice · **S3** minor. Line numbers are as of commit `0110b46` (InBul02).

Status lives in [bugfixed.md](bugfixed.md): every ID here has an entry there saying fixed / won't fix and how it was checked.

| ID | Sev | Where | Bug |
|---|---|---|---|
| B-01 | S2 | `lib/app/router.dart:53` | Settings > App Language is redirected to a second Dashboard, so a signed-in user cannot change the language |
| B-02 | S2 | `lib/core/widgets/cards.dart:69` | StatLedger columns are announced as buttons but have no tap action (ExcludeSemantics strips the InkWell's) |
| B-03 | S2 | `lib/core/widgets/otp_input.dart:59` | Typing into an OTP box that already has a digit is treated as a paste and overwrites the next box |
| B-04 | S2 | `lib/core/widgets/otp_input.dart:95` | OTP boxes are six unlabelled text fields; the group label does not reach them |
| B-05 | S2 | `lib/core/widgets/primary_button.dart:38` | PrimaryButton (the main CTA on every screen) exposes no tap action to assistive tech and cannot be reached or activated by keyboard |
| B-06 | S2 | `lib/core/widgets/status_views.dart:92` | Error and status messages appear without being announced (no live region) |
| B-07 | S2 | `lib/features/auth/otp_screen.dart:365` | OTP 'Didn't receive OTP code? / Resend in 30s' Row overflows at 1.3x text scale on a 360 px phone |
| B-08 | S2 | `lib/features/auth/register_screen.dart:64` | Sample mode is invisible on auth screens; OTP screen says a code was emailed and never says any 6 digits work |
| B-09 | S2 | `lib/features/calls/calling_queue_screen.dart:220` | No record ever parses as rescheduled, so the Scheduled filter, the Calendar tab and the Scheduled stat tap all show an empty queue |
| B-10 | S3 | `.gitignore:33` | Golden failure output directory is not gitignored |
| B-11 | S3 | `lib/app/theme.dart:84` | textMuted, success and danger text fail WCAG AA 4.5:1 on light surfaces |
| B-12 | S3 | `lib/core/network/api_client.dart:136` | Pin mismatch (e.g. after the leaf certificate renews) is reported as a generic unknown error; the badCertificate branch never fires |
| B-13 | S3 | `lib/core/providers.dart:70` | Session survives a switch between sample data and the real server |
| B-14 | S3 | `lib/core/providers.dart:100` | Logout keeps the previous registrant's email and pre-fills it on Login |
| B-15 | S3 | `lib/core/utils/validators.dart:30` | Indian mobile validator accepts numbers that cannot be real (any 10 digits) |
| B-16 | S3 | `lib/core/widgets/otp_input.dart:80` | OTP backspace-to-previous-box only works with a hardware keyboard |
| B-17 | S3 | `lib/core/widgets/status_views.dart:257` | Several tap targets are under the 48 px minimum |
| B-18 | S3 | `lib/features/auth/auth_scaffold.dart:36` | Auth screen titles are not marked as headings |
| B-19 | S3 | `lib/features/auth/otp_screen.dart:99` | Wrong OTP clears all six digits, contrary to the specified 'keep digits' behaviour |
| B-20 | S3 | `lib/features/auth/otp_screen.dart:120` | OTP screen shows the email instead of '+91 <mobile>'; the mobile number from Register is collected, validated and then discarded |
| B-21 | S3 | `lib/features/auth/otp_screen.dart:142` | Retry on a failed 'Resend OTP' runs Verify instead of resending |
| B-22 | S3 | `lib/features/auth/register_screen.dart:61` | setState/ref used after await with no mounted check: navigating away mid-request throws and can lose a successful sign-in |
| B-23 | S3 | `lib/features/auth/register_screen.dart:97` | Name field does not capitalise words |
| B-24 | S3 | `lib/features/auth/register_screen.dart:158` | An autofilled or pasted +91 number is cut down to the wrong 10 digits and still passes validation |
| B-25 | S3 | `lib/features/auth/register_screen.dart:162` | Keyboard submit bypasses the busy guard, so register/login can fire twice and push the OTP route twice |
| B-26 | S3 | `lib/features/auth/register_screen.dart:263` | Terms checkbox is announced without its label |
| B-27 | S3 | `lib/features/calls/calling_queue_screen.dart:47` | Disposition sheet ('How did the call go?') opens even when the dialer could not be launched |
| B-28 | S3 | `lib/features/calls/calling_queue_screen.dart:53` | Dispositions are keyed by contact only, so a note logged in one list appears in other lists |
| B-29 | S3 | `lib/features/calls/calling_queue_screen.dart:91` | Calling queue header: list name in a Row without Expanded overflows when the name is long |
| B-30 | S3 | `lib/features/calls/calling_queue_screen.dart:121` | Retry on list-details / lists errors gives no feedback because when() skips loading on refresh |
| B-31 | S3 | `lib/features/calls/calling_queue_screen.dart:142` | Queue search cannot find a number typed the way the queue shows it |
| B-32 | S3 | `lib/features/calls/calling_queue_screen.dart:326` | Queue row expands and collapses with no expanded state, and the Call button is not marked disabled when there is no number |
| B-33 | S3 | `lib/features/calls/calling_queue_screen.dart:432` | The expanded record hides rescheduledAt for the records that actually have one |
| B-34 | S3 | `lib/features/dashboard/dashboard_screen.dart:50` | Phone tab ('Dial next pending') always dials the same first pending contact and skips the disposition step |
| B-35 | S3 | `lib/features/dashboard/dashboard_screen.dart:140` | Greeting cards say 'Good morning/afternoon/evening' instead of the specified 'Hello <name>', and the dashboard subline is not 'Welcome to Calley!' |
| B-36 | S3 | `lib/features/dashboard/dashboard_screen.dart:220` | Empty dashboard 'Start Calling Now' opens the web panel while lists are still loading or have failed |
| B-37 | S3 | `lib/features/dashboard/dashboard_screen.dart:313` | Upload illustration badges never render: Positioned offsets assume a full-width Stack but the Stack is only 108 px wide |
| B-38 | S3 | `lib/features/dashboard/dashboard_screen.dart:349` | Failed pull-to-refresh raises an unhandled async error every time the server is down |
| B-39 | S3 | `lib/features/dashboard/dashboard_screen.dart:440` | 'Done' is blue in the donut and legend but green in the ledger directly below |
| B-40 | S3 | `lib/features/dashboard/dashboard_screen.dart:487` | Dashboard legend and StatLedger break or cut 'Scheduled' on a 360 px phone at 1.3x text |
| B-41 | S3 | `lib/features/drawer/app_drawer.dart:134` | Drawer 'Sync Data' says 'Refreshing from the server…' while sample data is active |
| B-42 | S3 | `lib/features/language/language_screen.dart:126` | Wrapper Semantics labels repeat the visible text, so rows are read twice |
| B-43 | S3 | `lib/features/language/language_screen.dart:298` | Language screen button reads 'Continue' (and the title is reworded), not the Figma 'Select' / 'Choose Your Language' |
| B-44 | S3 | `lib/features/onboarding/getting_started_screen.dart:51` | Getting Started instruction text is reworded from the Figma copy |
| B-45 | S3 | `lib/features/onboarding/getting_started_screen.dart:143` | Getting Started tutorial card: the subtitle runs under the play button on a 360 px phone and at 1.3x text |
| B-46 | S3 | `lib/features/settings/settings_screen.dart:210` | Data-source Switch in Settings has no accessible label, and tapping its row does not toggle it |
| B-47 | S3 | `scripts/changelog.mjs:69` | --pending re-run silently keeps the old title/summary, so --tag then fails the title check |

## Details

### B-01 · S2 · Settings > App Language is redirected to a second Dashboard, so a signed-in user cannot change the language

**Where:** `calley_app/lib/app/router.dart:53` · **Category:** navigation-redirect

Settings opens the language picker with context.push(Routes.language) (settings_screen.dart:149). LanguageScreen has a mode for this: when context.canPop() is true it shows 'App language' / 'Save' and pops back (language_screen.dart:13-14, 28-31, 38). But Routes.authGroup includes '/language' (router.dart:25), and the redirect sends any signed-in user on an auth-group path to /dashboard or /getting-started (router.dart:53-56). go_router also runs redirect on push, so the push lands on /dashboard and the stack becomes Dashboard > Settings > Dashboard. A signed-in user never sees the language screen, and its 'changing' mode can never run. The snapshot tests miss this because they mount appRoutes() without the redirect (router.dart:69-71).

**Evidence**

```dart
router.dart:25  static const authGroup = {language, register, otp, login};
router.dart:53-56  if (loggedIn && inAuth) { return ref.read(onboardedProvider) ? Routes.dashboard : Routes.gettingStarted; }
settings_screen.dart:149  onTap: () => context.push(Routes.language),
language_screen.dart:28-31  if (context.canPop()) { context.pop(); } else { context.go(Routes.register); }
```

**Proposed fix:** Add `static const signedOutOnly = {register, otp, login};` and change the first branch to `if (loggedIn && Routes.signedOutOnly.contains(path))`. Keep authGroup (which includes /language) in the `!loggedIn && !inAuth` branch, so signed-out users can still reach /language. Add a widget test that mounts the real routerProvider with a signed-in session, opens Settings, taps 'App Language' and expects LanguageScreen with its 'Save' button.

### B-02 · S2 · StatLedger columns are announced as buttons but have no tap action (ExcludeSemantics strips the InkWell's)

**Where:** `calley_app/lib/core/widgets/cards.dart:69` · **Category:** accessibility

The Pending/Done/Scheduled columns open the filtered queue on tap. Their Semantics wrapper marks them as buttons with a label but has no onTap, and ExcludeSemantics hides the InkWell's tap action. A screen-reader double-tap or Switch Access therefore does nothing.

**Evidence**

```dart
child: Semantics(
  button: entries[i].onTap != null,
  label: '${entries[i].label}, ${entries[i].value} calls',
  child: ExcludeSemantics(
    child: InkWell(
      onTap: entries[i].onTap,
```

**Proposed fix:** Pass `onTap: entries[i].onTap` to Semantics, or use `Semantics(..., onTap: ..., excludeSemantics: true, child: InkWell(...))`.

### B-03 · S2 · Typing into an OTP box that already has a digit is treated as a paste and overwrites the next box

**Where:** `calley_app/lib/core/widgets/otp_input.dart:59` · **Category:** forms-input

No box has a maxLength, so typing into a box that already holds a digit leaves two characters there, and _onChanged runs the paste branch. The old digit stays in box i, the new digit replaces box i+1, and focus jumps ahead. Fixing one wrong digit therefore leaves it unchanged and corrupts the next box. If all six boxes were full, onCompleted fires straight away with the wrong code. Pasting a full code into a box that already holds a digit shifts the code by one place.

**Evidence**

```dart
final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      // Paste: spread the digits from this box onwards.
      for (var k = 0; k < digits.length && i + k < widget.length; k++) {
        _ctrls[i + k].text = digits[k];
```

**Proposed fix:** Remember each box's previous text. When the new text is the previous digit plus one new character, keep only the new character. Treat input as a paste only when more than one character was inserted, and then spread only the inserted digits, starting at box i.

### B-04 · S2 · OTP boxes are six unlabelled text fields; the group label does not reach them

**Where:** `calley_app/lib/core/widgets/otp_input.dart:95` · **Category:** accessibility

The Semantics label wraps the Row but is not a container. Each TextField is its own semantics node with no label, so a screen reader announces 'Edit box' six times and never says 'One-time code' or which digit is focused.

**Evidence**

```dart
return Semantics(
      label: 'One-time code, ${widget.length} digits',
      child: Row(
...
                    decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
```

**Proposed fix:** Wrap each TextField in `Semantics(label: 'Digit ${i + 1} of ${widget.length}', child: ...)`, and drop the outer label or make it a container.

### B-05 · S2 · PrimaryButton (the main CTA on every screen) exposes no tap action to assistive tech and cannot be reached or activated by keyboard

**Where:** `calley_app/lib/core/widgets/primary_button.dart:38` · **Category:** accessibility

The outer Semantics sets button, label and enabled but no onTap, and ExcludeSemantics removes the GestureDetector's tap action from the semantics tree. On Android, TalkBack's double-tap and Switch Access / Voice Access send SemanticsAction.tap, which this node does not have, so nothing happens. A raw GestureDetector is not focusable either, so Tab never reaches the button and Enter/Space cannot press it. This affects Continue/Save, Sign Up, Verify, Sign In and Start Calling Now.

**Evidence**

```dart
return Semantics(
      button: true,
      enabled: enabled,
      label: widget.busy ? '${widget.label}, please wait' : widget.label,
      child: ExcludeSemantics(
        child: GestureDetector(
```

**Proposed fix:** Add `onTap: enabled ? widget.onPressed : null` to the Semantics widget, or replace ExcludeSemantics with `Semantics(excludeSemantics: true, onTap: ...)`. Wrap the GestureDetector in a FocusableActionDetector (or an InkWell with a transparent splash) that maps ActivateIntent to onPressed and draws a visible focus ring.

### B-06 · S2 · Error and status messages appear without being announced (no live region)

**Where:** `calley_app/lib/core/widgets/status_views.dart:92` · **Category:** accessibility

ErrorView is a plain AppCard with no liveRegion, so screen readers say nothing when a sign-in, register, OTP or list load fails. The OTP success notice (otp_screen.dart:132) and the register terms error (register_screen.dart:292) are not announced either.

**Evidence**

```dart
return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
```

**Proposed fix:** Wrap the message column in `Semantics(liveRegion: true, container: true, ...)`, or call SemanticsService.sendAnnouncement when _error is set. Do the same for the OTP notice and the terms error.

### B-07 · S2 · OTP 'Didn't receive OTP code? / Resend in 30s' Row overflows at 1.3x text scale on a 360 px phone

**Where:** `calley_app/lib/features/auth/otp_screen.dart:365` · **Category:** overflow

This Row holds a Text and a TextButton, neither of them flexible. At 1.3x on a 360 px phone it needs about 333 px but has 320 px, so it overflows by about 13 px and the resend countdown is clipped. AuthSwitchLine (auth_scaffold.dart:72) uses the same Row pattern and fails the same way at larger scales.

**Evidence**

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text("Didn't receive OTP code? ", style: TextStyle(fontSize: 13, color: c.textSecondary)),
    TextButton(
```

**Proposed fix:** Use `Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [...])` here and in AuthSwitchLine.

### B-08 · S2 · Sample mode is invisible on auth screens; OTP screen says a code was emailed and never says any 6 digits work

**Where:** `calley_app/lib/features/auth/register_screen.dart:64` · **Category:** error-surfacing

SampleDataBanner is used only on the dashboard, queue and settings. AuthScaffold (register, OTP, login) has none, although calley_api.dart:121 promises 'The UI shows a banner whenever this is active'. After 'Use sample data' on Register, the sample sendOtp returns 'Sample mode: any 6 digits verify', but register discards that value. The OTP screen then shows its fixed subtitle 'we have sent an OTP to your email', so nothing tells the user that no email was sent or which code to enter. Sample mode is also persisted and clearSession does not reset it, so after logout or a relaunch, Login silently accepts any password against bundled data with no banner.

**Evidence**

```dart
await ref.read(apiProvider).sendOtp(email: _email.text.trim());   // return value dropped
...
subtitle: 'Please ensure that the email id mentioned is valid as we have sent an OTP to your email.',  // otp_screen.dart:111
```

**Proposed fix:** Render `const SampleDataBanner()` at the top of AuthScaffold. In register, keep the sendOtp message (e.g. in a pendingOtpNoticeProvider next to pendingEmail) and have OtpScreen initialise `_notice` from it.

### B-09 · S2 · No record ever parses as rescheduled, so the Scheduled filter, the Calendar tab and the Scheduled stat tap all show an empty queue

**Where:** `calley_app/lib/features/calls/calling_queue_screen.dart:220` · **Category:** correctness

The data marks a call as rescheduled with a non-null rescheduledAt on a record whose status is 'called'. The status 'rescheduled' never appears in the data. CallRecord.status comes only from CallStatus.parse (models.dart:196), so all 11 such records become 'called'. The queue filters and counts by `r.status == s`. The dashboard shows 'Scheduled 11', but the stat tap (dashboard_screen.dart:526) and the Calendar tab (dashboard_screen.dart:42) both open a queue with 0 records, and the Scheduled chip reads 0.

**Evidence**

```dart
int count(CallStatus? s) => s == null ? details.calls.length : details.calls.where((r) => r.status == s).length;  // models.dart:196 status: CallStatus.parse(_str(j['status'])) -- sample statuses: {called: 23, pending: 27}
```

**Proposed fix:** Add `bool get isRescheduled => status == CallStatus.rescheduled || rescheduledAt != null;` to CallRecord, and use it for the Scheduled filter and count. Alternatively, map these records to CallStatus.rescheduled in fromJson, and adjust the Done count so they are not dropped from it.

### B-10 · S3 · Golden failure output directory is not gitignored

**Where:** `calley_app/.gitignore:33` · **Category:** tooling

When a golden comparison fails, the diff images go to calley_app/test/snapshots/failures/, which no .gitignore rule covers, so a routine `git add calley_app/test` would commit them.

**Evidence**

```dart
/build/
/coverage/
```

**Proposed fix:** Add `test/**/failures/` to calley_app/.gitignore.

### B-11 · S3 · textMuted, success and danger text fail WCAG AA 4.5:1 on light surfaces

**Where:** `calley_app/lib/app/theme.dart:84` · **Category:** accessibility

Light textMuted #7A7E89 measures about 4.06:1 on the white card, 3.71:1 on bg #F6F5F1, 3.56:1 on cardAlt #F1F0EB and 3.48:1 on the input fill #EFEEE9. It is used for small text: 11 px eyebrows, 12.5 px queue phone numbers and fact labels, Settings values, the dashboard footnote, the disposition note, and every TextField hint (theme.dart:296), which is the field's only visible label. Dark textMuted #80848F drops to about 4.3:1 on cardAlt. Light success #1C9A5A for the 12.5 px OTP notice (otp_screen.dart:353) is about 3.3:1 on bg, and about 3.0:1 for the queue call icon on its green tint (calling_queue_screen.dart:383). Light danger #D83A3A for the 12 px terms error is about 4.2:1.

**Evidence**

```dart
textMuted: Color(0xFF7A7E89),
success: Color(0xFF1C9A5A),
danger: Color(0xFFD83A3A),
// otp_screen.dart:353 style: TextStyle(fontSize: 12.5, color: c.success),
```

**Proposed fix:** Darken light textMuted to about #63666F-#696D77 (≥4.6:1 on #EFEEE9), and lighten dark textMuted to about #8A8E99. For text in light mode, add darker variants of success (about #147A46) and danger (about #B92B2B), or render those messages in c.text/textSecondary next to a coloured icon.

### B-12 · S3 · Pin mismatch (e.g. after the leaf certificate renews) is reported as a generic unknown error; the badCertificate branch never fires

**Where:** `calley_app/lib/core/network/api_client.dart:136` · **Category:** tls-pinning

When badCertificateCallback rejects the certificate, dart:io throws a HandshakeException, which Dio reports as DioExceptionType.unknown, so the message is the generic 'Something went wrong talking to the server.' The badCertificate arm in mapDioError is dead code. When the leaf certificate renews (it expires 2027-01-19), every request will fail with this vague message.

**Evidence**

```dart
DioExceptionType.connectionError ||
  DioExceptionType.badCertificate => const ApiException(...network),
  _ => ApiException(e.message ?? 'Something went wrong talking to the server.'),
```

**Proposed fix:** In mapDioError, check `e.error is HandshakeException || e.error is TlsException` and return a specific certificate error. Alternatively, move the pin check to `IOHttpClientAdapter(validateCertificate: ...)`, so the badCertificate arm actually runs.

### B-13 · S3 · Session survives a switch between sample data and the real server

**Where:** `calley_app/lib/core/providers.dart:70` · **Category:** state

Switching the data source keeps the current session, selected list and dispositions. A user signed in with sample data is then shown as a server account with no banner, and a server session carries into bundled data the same way. The session persists across restarts.

**Evidence**

```dart
Future<void> set(DataSource d) async {
    state = d;
    await ref.read(sessionStoreProvider).writeDataSource(d.name);
  }
```

**Proposed fix:** When the source changes while a user is signed in, call signOut(), or at least clear the list and dispositions and re-validate the user.

### B-14 · S3 · Logout keeps the previous registrant's email and pre-fills it on Login

**Where:** `calley_app/lib/core/providers.dart:100` · **Category:** state

signOut never resets pendingEmailProvider, so the next person on a shared phone sees the previous user's email filled in on Login.

**Evidence**

```dart
state = null;
    await ref.read(sessionStoreProvider).clearSession();
    ref.invalidate(selectedListProvider);
    ref.invalidate(onboardedProvider);
    ref.invalidate(dispositionsProvider);
```

**Proposed fix:** Invalidate pendingEmailProvider in signOut, and clear it after a successful login.

### B-15 · S3 · Indian mobile validator accepts numbers that cannot be real (any 10 digits)

**Where:** `calley_app/lib/core/utils/validators.dart:30` · **Category:** validation

Validators.mobile accepts any 10 digits, including '0000000000'. Indian mobile numbers always start with 6, 7, 8 or 9.

**Evidence**

```dart
return digits.length == 10 ? null : 'Enter a 10-digit mobile number';
```

**Proposed fix:** Use `RegExp(r'^[6-9]\d{9}$').hasMatch(digits)`.

### B-16 · S3 · OTP backspace-to-previous-box only works with a hardware keyboard

**Where:** `calley_app/lib/core/widgets/otp_input.dart:80` · **Category:** forms-input

Moving back to the previous box is handled only in a Focus.onKeyEvent handler that waits for a backspace KeyDownEvent while the current box is empty. Android and iOS soft keyboards do not send a key event for backspace in an empty TextField, so on a phone backspace in an empty box does nothing, contrary to the widget's own promise that 'backspace retreats'.

**Evidence**

```dart
KeyEventResult _onKey(int i, FocusNode node, KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[i].text.isEmpty &&
```

**Proposed fix:** Do not rely on key events. Use one hidden TextField (maxLength 6) and draw the six boxes from its value, or give each box a zero-width placeholder character so a soft-keyboard backspace becomes a text change. When a box becomes empty, clear box i-1 and focus it.

### B-17 · S3 · Several tap targets are under the 48 px minimum

**Where:** `calley_app/lib/core/widgets/status_views.dart:257` · **Category:** hit-target

Several targets are smaller than 48 px: 'Try server' (36 px), the ErrorView Retry and 'Use sample data' buttons (44 px), the disposition outcome buttons (44 px), the queue filter chips (46 px, clipped at large text scales) and the Calling Lists Refresh pill (about 36 px).

**Evidence**

```dart
style: TextButton.styleFrom(
  minimumSize: const Size(0, 36),
```

**Proposed fix:** Use `minimumSize: const Size(0, Dims.tap)` on these buttons, give the chip strip a height of 56 or a min height per chip, and give the Refresh pill a minHeight of Dims.tap.

### B-18 · S3 · Auth screen titles are not marked as headings

**Where:** `calley_app/lib/features/auth/auth_scaffold.dart:36` · **Category:** accessibility

The Register, OTP, Login and Language screen titles are plain Text, so screen-reader heading navigation finds no heading on them.

**Evidence**

```dart
Text(title, style: context.display(34, weight: FontWeight.w800)),
```

**Proposed fix:** Wrap each title in `Semantics(header: true, ...)`.

### B-19 · S3 · Wrong OTP clears all six digits, contrary to the specified 'keep digits' behaviour

**Where:** `calley_app/lib/features/auth/otp_screen.dart:99` · **Category:** error-surfacing

MD/flow.md says 'OTP wrong → inline error, keep digits.' On any badRequest the screen calls clear(), which wipes every box, so a one-digit typo means retyping the whole code.

**Evidence**

```dart
if (e.kind == ApiErrorKind.badRequest) _otpKey.currentState?.clear();
```

**Proposed fix:** Remove the clear() call. If a reset is wanted, move focus to the last box instead.

### B-20 · S3 · OTP screen shows the email instead of '+91 <mobile>'; the mobile number from Register is collected, validated and then discarded

**Where:** `calley_app/lib/features/auth/otp_screen.dart:120` · **Category:** spec-divergence

FR-3 and ui_screens 03 require the OTP screen to show '+91 <number>' under the boxes. The screen shows only the email. RegisterScreen validates a 10-digit mobile number, but stores only the email in pendingEmailProvider, so the number is never shown or used.

**Evidence**

```dart
otp_screen.dart:120-129 `if (email.isNotEmpty) Text(email, ...)`; register_screen.dart:61 `ref.read(pendingEmailProvider.notifier).set(_email.text.trim());` (no mobile carried)
```

**Proposed fix:** Carry the mobile number from Register as well (a pendingMobileProvider, or an (email, mobile) record). Render `'+91 ${fmtPhone(mobile)}'` under the OTP boxes as a 'wrong number?' link that pops back to Register.

### B-21 · S3 · Retry on a failed 'Resend OTP' runs Verify instead of resending

**Where:** `calley_app/lib/features/auth/otp_screen.dart:142` · **Category:** correctness

_resend and _verify store their failures in the same _error field, and the ErrorView is always wired to `_verify()`. After a resend fails with a network or server error (Retry is shown), tapping Retry does not resend. With fewer than 6 digits entered, it replaces the server error with the 'enter the OTP' validation message. With 6 digits entered, it sends a verify request the user did not ask for.

**Evidence**

```dart
} on ApiException catch (e) {
      setState(() => _error = e);   // in _resend
...
          ErrorView(
            error: _error!,
            onRetry: () => _verify(),
```

**Proposed fix:** Add `VoidCallback? _retry;`. Set `_retry = _resend` in _resend's catch and `_retry = _verify` in _verify's catch, then pass `onRetry: _retry` to ErrorView.

### B-22 · S3 · setState/ref used after await with no mounted check: navigating away mid-request throws and can lose a successful sign-in

**Where:** `calley_app/lib/features/auth/register_screen.dart:61` · **Category:** lifecycle

After the awaited API call, the auth screens use ref and setState without checking `mounted`. The 'Sign In' / 'Sign Up' links (context.go) stay tappable while a request runs, and tapping one disposes the screen. When the request then finishes, Riverpod 3 throws a StateError for using ref on a disposed widget, or setState throws 'setState() called after dispose()'. On Login success, `ref.read(sessionProvider.notifier)` throws, so a sign-in that succeeded is lost. Affected sites: register_screen.dart:61/64 (pendingEmailProvider, apiProvider) and :70 (catch setState), login_screen.dart:49-52, otp_screen.dart:70/73 (_resend setState and _startTimer) and otp_screen.dart:98 (_verify catch).

**Evidence**

```dart
await ref.read(apiProvider).register(...);
      ref.read(pendingEmailProvider.notifier).set(_email.text.trim());
...
final user = await ref.read(apiProvider).login(email: _email.text.trim(), password: _password.text);
await ref.read(sessionProvider.notifier).signIn(user);
...
} on ApiException catch (e) {
  setState(() => _error = e);
```

**Proposed fix:** Before the first await, capture what is needed afterwards: `final api = ref.read(apiProvider); final session = ref.read(sessionProvider.notifier); final pending = ref.read(pendingEmailProvider.notifier);`. That way the sign-in still completes if the screen is gone. Add `if (!mounted) return;` right after each await and before every setState (register:61/70, login:52, otp:70/73/98).

### B-23 · S3 · Name field does not capitalise words

**Where:** `calley_app/lib/features/auth/register_screen.dart:97` · **Category:** keyboard

AppTextField has no textCapitalization parameter, so the Register name field defaults to TextCapitalization.none and names are typed in lower case.

**Evidence**

```dart
AppTextField(controller: _name, hint: 'Name', ... keyboardType: TextInputType.name,
```

**Proposed fix:** Add a textCapitalization parameter to AppTextField and set TextCapitalization.words on the Name field.

### B-24 · S3 · An autofilled or pasted +91 number is cut down to the wrong 10 digits and still passes validation

**Where:** `calley_app/lib/features/auth/register_screen.dart:158` · **Category:** phone-input

The mobile field asks for AutofillHints.telephoneNumberNational, and autofill or paste often supplies '+91 98765 43210' or '098765 43210'. digitsOnly turns that into '919876543210' or '09876543210', and LengthLimitingTextInputFormatter(10) keeps the first 10 digits, giving '9198765432' or '0987654321'. That is a different, invalid number, but Validators.mobile accepts it.

**Evidence**

```dart
inputFormatters: [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(10),
],
```

**Proposed fix:** Replace the two formatters with one custom formatter that keeps only digits, removes a leading '91' when more than 10 digits remain and a leading '0' when 11 remain, and then keeps the last 10 digits. Also tighten Validators.mobile to `^[6-9]\d{9}$`.

### B-25 · S3 · Keyboard submit bypasses the busy guard, so register/login can fire twice and push the OTP route twice

**Where:** `calley_app/lib/features/auth/register_screen.dart:162` · **Category:** double-submit

PrimaryButton ignores taps while busy, but _submit has no `if (_busy) return;`, and the fields stay enabled during the request. The mobile field's onSubmitted (register_screen.dart:162) and the password field's onSubmitted (login_screen.dart:119) call _submit directly. Pressing Done/Enter twice, or Done and then the button, while the first request is still running (connect timeout is 10 s) starts a second request. On Register this sends a second POST /auth/register and a second send-otp. In sample mode both calls succeed and context.push(Routes.otp) runs twice, leaving two OTP screens on the stack. Against a real server the second call gets 409 'Already exists'. On Login, signIn runs twice.

**Evidence**

```dart
Future<void> _submit() async {
  setState(() => _agreeError = !_agreed);
  if (!_form.currentState!.validate() || !_agreed) return;
  setState(() {
    _busy = true;
...
onSubmitted: (_) => _submit(),   // register_screen.dart:162, login_screen.dart:119
```

**Proposed fix:** Make `if (_busy) return;` the first line of _submit in RegisterScreen and LoginScreen, and of _verify and _resend in OtpScreen. Optionally also pass `enabled: !_busy` to the AppTextField/PasswordField widgets.

### B-26 · S3 · Terms checkbox is announced without its label

**Where:** `calley_app/lib/features/auth/register_screen.dart:263` · **Category:** accessibility

The Checkbox becomes a separate semantics node from the 'I agree to the Terms and Conditions' text, so TalkBack reads 'Checkbox, not checked' with no name. The required consent control has no accessible name.

**Evidence**

```dart
InkWell(
  onTap: () => onChanged(!value),
  child: Row(
    children: [
      Checkbox(
        value: value,
```

**Proposed fix:** Wrap the Checkbox in `Semantics(label: 'I agree to the Terms and Conditions', ...)`, or merge the checkbox and text with MergeSemantics and keep the Terms link outside the merged row.

### B-27 · S3 · Disposition sheet ('How did the call go?') opens even when the dialer could not be launched

**Where:** `calley_app/lib/features/calls/calling_queue_screen.dart:47` · **Category:** correctness

Launcher.dial returns Future<void>. When launching fails (a tablet, an emulator without a dialer, tel: blocked, or an empty number), it shows a snackbar and returns normally. _call cannot tell, so it opens the disposition sheet for a call that never happened. The agent can then log an outcome, which shows on the row as 'Logged: ... (this session only)'. That conflicts with FR-9 and with R-06's honesty rule.

**Evidence**

```dart
await ref.read(launcherProvider).dial(context, r.phone!);
    if (!mounted) return;
    // We cannot know when the call ended; offer the disposition straight away
    final result = await showDispositionSheet(context, r);  // launchers.dart:46-62 dial() returns void after showing the failure snackbar
```

**Proposed fix:** Make Launcher.dial return Future<bool> (false for empty digits or when `_safe` fails, true otherwise). In _call, write `final ok = await ...dial(...); if (!ok || !mounted) return;` before calling showDispositionSheet.

### B-28 · S3 · Dispositions are keyed by contact only, so a note logged in one list appears in other lists

**Where:** `calley_app/lib/features/calls/calling_queue_screen.dart:53` · **Category:** stale-state

The disposition map is keyed by CallRecord.key (phone|email|first|last, models.dart:163), which has no list id, and it resets only on logout. If the same contact is in two lists, an outcome logged in one list shows in the other. In sample mode every list returns the same details, so every disposition shows up in every list.

**Evidence**

```dart
ref.read(dispositionsProvider.notifier).set(r.key, result);
...
disposition: dispositions[items[i].key],
```

**Proposed fix:** Include the list id in the key (`'${selected.id}/${r.key}'`), or make dispositionsProvider a family keyed by list id.

### B-29 · S3 · Calling queue header: list name in a Row without Expanded overflows when the name is long

**Where:** `calley_app/lib/features/calls/calling_queue_screen.dart:91` · **Category:** overflow

The selected list name is uppercased in the eyebrow style (11 px mono, letterSpacing 1.4) inside a Row with no Flexible, maxLines or overflow. On a 360 px phone, a name longer than about 40 characters (about 32 at 1.3x) causes a RenderFlex overflow in debug and is clipped in release. List names come from the server, so their length is not controlled.

**Evidence**

```dart
child: Row(
  children: [
    Text(selected.name.toUpperCase(), style: context.eyebrow()),
  ],
),
```

**Proposed fix:** Remove the Row and use `Text(selected.name.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: context.eyebrow())`, or wrap the Text in Expanded.

### B-30 · S3 · Retry on list-details / lists errors gives no feedback because when() skips loading on refresh

**Where:** `calley_app/lib/features/calls/calling_queue_screen.dart:121` · **Category:** retry-wiring

Retry calls ref.invalidate(listDetailsProvider(id)). In Riverpod 3 that is a refresh: the provider keeps its AsyncError with isLoading=true, and AsyncValue.when defaults to skipLoadingOnRefresh: true, so it calls error() again instead of loading(). The same ErrorView stays on screen with no spinner until the request ends, which can take up to the 10 s connect timeout plus the 15 s receive timeout. Each further tap starts a new request. This affects the queue (lines 121-134), the dashboard stats (dashboard_screen.dart:400-405) and the calling lists sheet (calling_lists_sheet.dart:84-95). _EmptyDashboard already handles this case with `lists.hasError && !lists.isLoading` (line 145), so the screens behave inconsistently.

**Evidence**

```dart
details.when(
  loading: () => const _StatsSkeleton(),
  error: (e, _) => ErrorView(
    error: e,
    onRetry: () => ref.invalidate(listDetailsProvider(list.id)),
  ),
```

**Proposed fix:** Pass `skipLoadingOnRefresh: false` to these when() calls (calling_queue_screen.dart:110 and 121, dashboard_screen.dart:373 and 400, calling_lists_sheet.dart:84). Or check `details.isLoading` before the error branch, as _EmptyDashboard does. Pull-to-refresh keeps working because RefreshIndicator shows its own spinner.

### B-31 · S3 · Queue search cannot find a number typed the way the queue shows it

**Where:** `calley_app/lib/features/calls/calling_queue_screen.dart:142` · **Category:** correctness

Rows show the formatted number (e.g. '10000 00000'), but search matches only raw digits, so a query with spaces or a '+91' prefix returns 'No match'.

**Evidence**

```dart
(r.phone ?? '').contains(_query);
```

**Proposed fix:** Strip non-digits from both the query and the phone number before matching.

### B-32 · S3 · Queue row expands and collapses with no expanded state, and the Call button is not marked disabled when there is no number

**Where:** `calley_app/lib/features/calls/calling_queue_screen.dart:326` · **Category:** accessibility

The row InkWell exposes no expanded flag, so screen-reader users are not told that the row expands. The Call button is announced as active even when r.phone is null and the tap does nothing.

**Evidence**

```dart
InkWell(onTap: onToggle,
...
Semantics(button: true, label: 'Call ${r.displayName}', child: Material(
      onTap: r.phone == null ? null : onCall,
```

**Proposed fix:** Wrap the row in `Semantics(expanded: expanded, onTapHint: ...)`, and add `enabled: r.phone != null` to the Call button's Semantics.

### B-33 · S3 · The expanded record hides rescheduledAt for the records that actually have one

**Where:** `calley_app/lib/features/calls/calling_queue_screen.dart:432` · **Category:** correctness

The 'Rescheduled' row renders only when status == rescheduled, which no record has, so the 11 called records that have a rescheduledAt never show it.

**Evidence**

```dart
if (r.status == CallStatus.rescheduled)
  _fact(context, 'Rescheduled', fmtDate(r.rescheduledAt), mono: true),
```

**Proposed fix:** Use `if (r.rescheduledAt != null)`, or the isRescheduled getter.

### B-34 · S3 · Phone tab ('Dial next pending') always dials the same first pending contact and skips the disposition step

**Where:** `calley_app/lib/features/dashboard/dashboard_screen.dart:50` · **Category:** correctness

The Phone tab picks the first record whose server status is pending. It ignores dispositionsProvider and never offers the disposition sheet, so every tap dials the same number, including contacts already logged in the queue. While details are still loading or have failed, it says 'No pending call to dial.', which may be wrong because pending calls may simply not have loaded yet.

**Evidence**

```dart
final next = details.hasValue
    ? details.value!.calls.where((r) => r.status == CallStatus.pending).firstOrNull
    : null;
if (next?.phone != null) {
  if (context.mounted) {
    ref.read(launcherProvider).dial(context, next!.phone!);
```

**Proposed fix:** Skip contacts that are already logged: `.where((r) => r.status == CallStatus.pending && !ref.read(dispositionsProvider).containsKey(r.key))`. After a successful dial, show showDispositionSheet and store the result, as CallingQueueScreen._call does. While details.isLoading or details.hasError, show a loading or error message instead of 'No pending call to dial.'

### B-35 · S3 · Greeting cards say 'Good morning/afternoon/evening' instead of the specified 'Hello <name>', and the dashboard subline is not 'Welcome to Calley!'

**Where:** `calley_app/lib/features/dashboard/dashboard_screen.dart:140` · **Category:** copy-fidelity

FR-5 and ui_screens 05/06 call for 'Hello Swati', with 'Welcome to Calley!' on the dashboard. The app shows a time-of-day greeting, and when there is no subscription the subline reads 'Welcome to Calley · ' with a dangling separator.

**Evidence**

```dart
dashboard_screen.dart:139-143 `GreetingCard(eyebrow: greetingFor(now), name: user?.firstName ?? 'there', subline: 'Welcome to Calley · ${user?.subscription ?? ''}')`; getting_started_screen.dart:35-39 `eyebrow: greetingFor(now)`
```

**Proposed fix:** Use 'Hello' as the eyebrow on both screens and 'Welcome to Calley!' as the dashboard subline. If the time-based greeting is intentional, record it as a DEC entry.

### B-36 · S3 · Empty dashboard 'Start Calling Now' opens the web panel while lists are still loading or have failed

**Where:** `calley_app/lib/features/dashboard/dashboard_screen.dart:220` · **Category:** state

hasLists is false while listsProvider is loading or has failed, so tapping the main CTA in that window opens the web panel in the browser, even when the account has lists that are about to load.

**Evidence**

```dart
onPressed: hasLists
    ? () => showCallingListsSheet(context)
    : () => ref.read(launcherProvider).open(context, Links.webPanel),
```

**Proposed fix:** Disable the button while the lists are loading, make it retry when they failed, and open the web panel only when the lists loaded empty.

### B-37 · S3 · Upload illustration badges never render: Positioned offsets assume a full-width Stack but the Stack is only 108 px wide

**Where:** `calley_app/lib/features/dashboard/dashboard_screen.dart:313` · **Category:** layout

_UploadIllustration's Stack sits in a Column with centred cross-axis alignment, so it gets loose width constraints and sizes to its widest non-positioned child, the 108 px circle. `Positioned(top: 4, right: 118)` therefore places the 38 px upload badge at x = -48, and `Positioned(bottom: 4, left: 118)` places the headset badge at x = 118. Both fall outside the Stack and are clipped by its default hardEdge clip. The snapshot 06b-dashboard-empty.png shows only the circle and the phone icon. Even with a full-width Stack, edge-relative offsets of 118 would shift with screen width.

**Evidence**

```dart
child: SizedBox(
        height: 126,
        child: Stack(
          alignment: Alignment.center,
          children: [ Container(width: 108, height: 108, ...),
            Positioned(top: 4, right: 118, child: badge(Icons.cloud_upload_outlined, c.scheduled)),
            Positioned(bottom: 4, left: 118, child: badge(Icons.headset_mic_outlined, c.pending)),
```

**Proposed fix:** Give the Stack a fixed square, e.g. `SizedBox(width: 170, height: 126, child: Stack(clipBehavior: Clip.none, ...))`, centred in the card. Position the badges relative to that box (e.g. `top: 4, right: 4` and `bottom: 4, left: 4`), or use `Align(alignment: Alignment(0.8, -0.9))`.

### B-38 · S3 · Failed pull-to-refresh raises an unhandled async error every time the server is down

**Where:** `calley_app/lib/features/dashboard/dashboard_screen.dart:349` · **Category:** error-handling

onRefresh returns ref.refresh(provider.future). When the request fails, that future completes with an ApiException that RefreshIndicator never handles (it only chains whenComplete), so every failed pull reports an unhandled exception to the zone and to any crash reporter. The same pattern is at dashboard_screen.dart:135 and calling_queue_screen.dart:156. The provider's AsyncValue already shows the error on screen.

**Evidence**

```dart
onRefresh: () => ref.refresh(listDetailsProvider(list.id).future),
...
onRefresh: () => ref.refresh(listsProvider.future),
```

**Proposed fix:** Swallow the error in the callback: `onRefresh: () async { try { await ref.refresh(...future); } catch (_) {} }`. Apply this at all three sites.

### B-39 · S3 · 'Done' is blue in the donut and legend but green in the ledger directly below

**Where:** `calley_app/lib/features/dashboard/dashboard_screen.dart:440` · **Category:** rendering

On the active dashboard, the Done donut segment and its legend dot use c.done (blue). The StatLedger entry for the same Done count uses c.success (green), and so does the calling queue's _colorFor. Snapshot 08-dashboard-active.png shows a blue Done dot in the legend and a green Done dot in the ledger, about 30 px apart.

**Evidence**

```dart
DonutSegment(label: 'Done', value: details.called, color: c.done),
...
LedgerEntry(label: 'Done', value: details.called, color: c.success,
```

**Proposed fix:** Use one token for 'called' everywhere. Either change line 440 to `color: c.success`, or change line 519 and calling_queue_screen.dart line 41 to `c.done`.

### B-40 · S3 · Dashboard legend and StatLedger break or cut 'Scheduled' on a 360 px phone at 1.3x text

**Where:** `calley_app/lib/features/dashboard/dashboard_screen.dart:487` · **Category:** overflow

The legend column beside the fixed 150 px donut leaves about 67 px for the label. At 1.3x, 'Scheduled' is about 90 px, so it breaks mid-word. In StatLedger (cards.dart:412) each label gets about 64 px, so 'Scheduled' is cut to 'Sched…' at 1.3x.

**Evidence**

```dart
DonutChart(segments: segments, size: 150,
...
Expanded(child: Text(s.label, style: context.body(13.5, color: c.textSecondary),
```

**Proposed fix:** Size the donut to the available width with a LayoutBuilder, and set `maxLines: 1, softWrap: false, overflow: ellipsis` on the legend label. Reduce StatLedger's horizontal padding, or stack the dot above the label.

### B-41 · S3 · Drawer 'Sync Data' says 'Refreshing from the server…' while sample data is active

**Where:** `calley_app/lib/features/drawer/app_drawer.dart:134` · **Category:** honesty

In sample mode, Sync Data only re-reads the bundled JSON, but the snackbar still claims a server refresh, and the open drawer covers the sample banner. That breaks R-06 and DEC-007.

**Evidence**

```dart
app_drawer.dart:128-136 `ref.invalidate(listsProvider); ... SnackBar(content: Text('Refreshing from the server…'))`
```

**Proposed fix:** Read dataSourceProvider and show 'Reloading sample data…' in sample mode.

### B-42 · S3 · Wrapper Semantics labels repeat the visible text, so rows are read twice

**Where:** `calley_app/lib/features/language/language_screen.dart:126` · **Category:** accessibility

The wrapper labels merge with the child Text labels, so the language row, the calling-list row (which also says 'selected' twice), the queue filter chips and the Refresh pill are all read twice.

**Evidence**

```dart
return Semantics(inMutuallyExclusiveGroup: true, checked: selected, label: '${language.name}, ${language.greeting}', child: InkWell(
```

**Proposed fix:** Add `excludeSemantics: true` plus `onTap: onTap` to these Semantics wrappers, and drop the ', selected' suffix in _ListRow.

### B-43 · S3 · Language screen button reads 'Continue' (and the title is reworded), not the Figma 'Select' / 'Choose Your Language'

**Where:** `calley_app/lib/features/language/language_screen.dart:298` · **Category:** copy-fidelity

FR-1 and ui_screens 01 call for the title 'Choose Your Language' and a 'Select' button. The app shows 'Choose your\nlanguage' and 'Continue', and no DEC entry covers the change.

**Evidence**

```dart
language_screen.dart:59 `'Choose your\nlanguage'`; :101 `label: changing ? 'Save' : 'Continue'`
```

**Proposed fix:** Use 'Select' and 'Choose Your Language' on first run, or record the rewording as a DEC entry.

### B-44 · S3 · Getting Started instruction text is reworded from the Figma copy

**Where:** `calley_app/lib/features/onboarding/getting_started_screen.dart:51` · **Category:** copy-fidelity

R-03 requires the Figma copy verbatim, but the Getting Started instruction sentence has been rewritten.

**Evidence**

```dart
getting_started_screen.dart:51 `text: 'If you are here for the first time, make sure you have uploaded the list to call from the Calley web panel at ',`
```

**Proposed fix:** Restore the Figma sentence, or record the change as a DEC entry.

### B-45 · S3 · Getting Started tutorial card: the subtitle runs under the play button on a 360 px phone and at 1.3x text

**Where:** `calley_app/lib/features/onboarding/getting_started_screen.dart:143` · **Category:** overflow

The text column is `Positioned(left: 20, top: 22)` with no right or width constraint, so its lines never wrap. The 56 px play button is pinned at right: 20, bottom: 20 inside the same fixed 200 px Stack. At 390 px and 1.0x (05-getting-started.png), the subtitle already ends only about 25 px left of the button (x≈269 vs 294) and shares rows with it vertically. At 360 px the text runs about 5 px under the button. At 1.3x the line is about 300-325 px wide and runs under most of the button. Longer text is clipped at the card edge instead of wrapping, and larger scales also overflow the 200 px height.

**Evidence**

```dart
Container(
  height: 200,
...
Positioned(
  left: 20,
  top: 22,
  child: Column(
 ...
    Text('Upload a list, sync, dial. Watch how.',
...
Positioned(right: 20, bottom: 20, child: Container(width: 56, height: 56,
```

**Proposed fix:** Constrain the text with `Positioned(left: 20, top: 22, right: 96, child: ...)` so it wraps clear of the button. Replace the fixed `height: 200` with `BoxConstraints(minHeight: 200)` and lay the card out with a Column/Row instead of a Stack, so it grows with text scale.

### B-46 · S3 · Data-source Switch in Settings has no accessible label, and tapping its row does not toggle it

**Where:** `calley_app/lib/features/settings/settings_screen.dart:210` · **Category:** accessibility

The Switch is the trailing widget of a plain ListTile with no onTap and no MergeSemantics. TalkBack reads only 'Switch, off', with nothing saying what it controls, and tapping the row text does nothing.

**Evidence**

```dart
trailing: kForceMock
    ? null
    : Switch(
        value: source == DataSource.sample,
        onChanged: (v) => ref
```

**Proposed fix:** Use a SwitchListTile (title 'Use sample data', subtitle showing the current source), or wrap the ListTile in MergeSemantics and give it an onTap that toggles the value.

### B-47 · S3 · --pending re-run silently keeps the old title/summary, so --tag then fails the title check

**Where:** `scripts/changelog.mjs:69` · **Category:** tooling

nextBuild() returns the number of an existing report that has no tag yet, so a second `--pending "<new title>" "<new summary>"` reuses build-N.md. writeReport finds the existing manual block and keeps it, silently dropping the new title, summary, --why, --verified and --next. If the commit then uses the new title, `--tag` fails with 'Commit title ... does not match report title ...'.

**Evidence**

```dart
if (existsSync(path)) {
    const old = readFileSync(path, 'utf8');
    manual = /<!-- manual:start -->([\s\S]*?)<!-- manual:end -->/.exec(old)?.[1]?.trim();
  }
  if (!manual) { manual = [ `# Build ${n}: ${title}`, ...
```

**Proposed fix:** Keep the old manual block only when no new content was passed. Otherwise rebuild it from the new arguments, or at least replace the heading and the 'What changed' body. If the old block is kept, print a warning that names the stale title.

## Refuted claims (not bugs)

| Claim | Where | Why refuted (majority view) |
|---|---|---|
| ListDetails.total counts rescheduled calls twice, so the donut total and every percentage are wrong | `lib/models/models.dart:220` | The arithmetic in the claim is right. In assets/mock/list_details.json the counts are pending 27 / called 23 / rescheduled 11, there are 50 records, and the 11 records with a rescheduledAt all have status "called". So the donut does sum to 61. But this is a deliberate, documented decision, not an ac… |
| listDetailsProvider family is never disposed or reset, so earlier sessions' list details are cached and served after logout | `lib/core/providers.dart:165` | The caching itself is real: in Riverpod 3 a plain `FutureProvider.family` is not autoDispose, and `signOut()` (providers.dart:100-106) does not invalidate it. But the claimed harm cannot be seen. First, the cache key is only the listId, and the request `getListDetails(listId)` (calley_api.dart:112-1… |
| apiProvider creates a new Dio on every switch to remote and never closes the old one | `lib/core/providers.dart:82` | The code is as quoted: apiProvider (providers.dart:80-85) calls createDio() each time it rebuilds into the remote branch, with no ref.onDispose. But the harm described doesn't happen in practice. (1) No resources pile up. A rebuild only happens when the user taps the data-source toggle (settings_scr… |
| Non-list 'agents'/'calls' values throw TypeError, which escapes ApiException handling | `lib/models/models.dart:75` | The code matches the claim. models.dart:75 has `j['agents'] as List?` and models.dart:226 has `j['calls'] as List?`. A non-list value would throw a TypeError, and status_views.dart:81-91 would then show the generic error with no sample-data offer. But nobody using the app can make that happen. The o… |
| After a wrong OTP, clear() cannot refocus the first box because the boxes are still disabled | `lib/features/auth/otp_screen.dart:99` | The focus mechanism is real: clear() at otp_screen.dart:99 runs while _busy is still true, the TextFields are disabled (enabled: widget.enabled, otp_input.dart:109), and a disabled TextField's node can't take focus, so `_nodes.first.requestFocus()` (otp_input.dart:42) does nothing. But no one can re… |
| Resend OTP has no in-flight guard, and a failed initial send-otp is silently swallowed | `lib/features/auth/otp_screen.dart:63` | The code does match the description. In otp_screen.dart:155 the button stays enabled while `_resend` (lines 63-75) is waiting. Lines 70-71 call setState and `_startTimer` with no mounted check. register_screen.dart:63-67 drops a send-otp failure. But I could not build a scenario where a person sees … |
| White initials on several contact-avatar hues fall below 4.5:1 | `lib/core/widgets/cards.dart:270` | The numbers check out. In calling_queue_screen.dart:332 the queue avatar is `Avatar(initial: initials, size: 42, seed: r.displayName)`, and cards.dart:300 draws the text at `size * 0.42`, which is about 17.6 px w700. That is under the 18.67 px bold cutoff for large text. White on #D9772C, #0E9F6E an… |
| Donut: a single non-zero segment (100% done) is drawn with a notch at 12 o'clock, and tiny segments merge into the next one | `lib/core/widgets/donut_chart.dart:163` | The geometry is right: with size 150 the stroke is 16.5, the gap arc is about 23.1 px, and round caps leave about a 6.6 px notch. But no user can reach the triggering data. The donut's only caller is _Stats in dashboard_screen.dart (lines 439-467). Its segments are details.called, details.pending an… |
| Calling-lists sheet uses isScrollControlled without useSafeArea, so a long list slides under the status bar | `lib/features/lists/calling_lists_sheet.dart:181` | On the framework side the claim is accurate. Without useSafeArea, ModalBottomSheetRoute strips the top padding and an isScrollControlled sheet is allowed to grow to full screen height. But nobody using this app can make the sheet that tall. The real API at mock-api.calleyacd.com is dead and answers … |
| Active-list header skeleton (34 px) is shorter than the content it stands in for (about 46 px), so the card jumps on load | `lib/features/dashboard/dashboard_screen.dart:374` | The claim measures the skeleton against the wrong thing. In dashboard_screen.dart lines 355-396 the skeleton sits in a Row next to a left Column: eyebrow (11 px x 1.2 = 13.2) + SizedBox 6 + list name at display(22) with height 1.05 (23.1), about 42.3 px. The Row is therefore never shorter than about… |
| Email fields leave autocorrect and suggestions on | `lib/core/widgets/app_text_field.dart:51` | It is true that AppTextField (app_text_field.dart:51-63) passes neither `autocorrect` nor `enableSuggestions` to TextFormField, so both stay at Flutter's default of true. But the harm described is mostly already handled by the framework and the platforms. For the password case, Flutter's engine sets… |
| OTP boxes have no one-time-code autofill hint | `lib/core/widgets/otp_input.dart:106` | It is true that none of the TextFields in calley_app/lib/core/widgets/otp_input.dart (lines 106-122) set autofillHints. But no user can actually hit the claimed failure, "the OS never offers the code that was just sent". The mock API at mock-api.calleyacd.com is dead and answers every /api/* path wi… |
| fmtShare rounds each share on its own, so the legend can add up to 99% or 101% | `lib/core/utils/formatters.dart:61` | The arithmetic in the claim is right. `fmtShare` (formatters.dart:57-62) rounds each share separately, and the legend in dashboard_screen.dart:475-496 calls it for Done, Pending and Scheduled against `details.total`, which is `pending + called + rescheduled` (models.dart:220). So counts of 1/1/1 sho… |
| nextBuild() can return a number below the latest build tag | `scripts/changelog.mjs:38` | The claimed ordering can't happen through the script's own commands. For a build tag above an untagged report (say build-1002 tagged while build-1001.md is untagged), nextBuild() would have had to return 1002 while build-1001.md sat untagged. It can't. Whenever any untagged report exists, nextBuild(… |
| snapshotFontFamily is never read, so the Roboto fallback in the font loader does nothing | `test/snapshots/snapshot_harness.dart:38` | The factual part is true. Grep shows snapshotFontFamily is only written (snapshot_harness.dart:38, 74, 84) and never read, and the theme hard-codes Fonts.body = 'Inter' (theme.dart:154). The doc comment at lines 41-42 is also stale: it says Inter is "downloaded into test/fonts", but Inter-400..800.t… |
| _ListsOnlyApi is the same as the default sample API, so test 06 does not test the state it names | `test/snapshots/snapshots_test.dart:45` | It's true that `_ListsOnlyApi` (snapshots_test.dart:45-48) overrides nothing, so it is the same as the harness default `sampleApi` (snapshot_harness.dart:28-31). But the main claim is wrong: test 06 does test the state it names. The test is called "dashboard, lists available, none chosen", and that … |
| iOS LSApplicationQueriesSchemes and the unit tests exist only in the working tree | `ios/Runner/Info.plist:69` | No user can trigger this in the app. The claim describes git state, not app behavior. The diff shows LSApplicationQueriesSchemes and test/unit/ as uncommitted work in progress, and the user has just asked to resume that work, so committing it is the next workflow step rather than a defect. The "neve… |
| Queue, Calendar and Phone taps with no list open the picker, then drop the action | `lib/features/dashboard/dashboard_screen.dart:36` | The code does what the reviewer says. At dashboard_screen.dart:35-37 and 46-48, a tap with no list selected awaits showCallingListsSheet and then returns, and the sheet just pops when a list is picked (calling_lists_sheet.dart:193). But this is a design choice, not a defect. MD/system_architecture.m… |
| An empty list shows 'Nothing  in this list. Try another status.' with no filter set | `lib/features/calls/calling_queue_screen.dart:148` | The copy at calling_queue_screen.dart:147-152 does produce a double space ('Nothing  in this list') when `_filter` is null. But in this app that branch can't be reached. With no filter and an empty `_query`, the `where` at lines 137-143 keeps every record, so `items` is empty only if `d.calls` itsel… |
| TapGestureRecognizer for the Terms link is created on every build and never disposed | `lib/features/auth/register_screen.dart:280` | The code is as described: `_TermsRow` at register_screen.dart:239 is a StatelessWidget, and line 280 creates `recognizer: TapGestureRecognizer()..onTap = onTerms,` on every build. Each setState in RegisterScreen, such as typing in a field, builds a new one, and the old one is never disposed. No user… |
