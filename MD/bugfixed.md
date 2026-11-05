# bugfixed.md: what happened to every bug in [bugs.md](bugs.md)

Fixed on 2026-11-05 in the build after `build-1000`. Checks after the fixes: `flutter analyze` 0 issues; `flutter test` **69 passed** (37 unit/router + 32 snapshots, regenerated and reviewed by eye).

| ID | Sev | Status | What was changed | How it was checked |
|---|---|---|---|---|
| B-01 | S2 | Fixed | `Routes.signedOutOnly = {register, otp, login}`; the signed-in redirect uses it, so /language stays reachable from Settings. | New `test/unit/router_test.dart` mounts the REAL router: Settings → App Language shows LanguageScreen with Save; signed-in users are still kept out of /login. |
| B-02 | S2 | Fixed | StatLedger's Semantics node now carries `onTap`. | Code review; analyzer. |
| B-03 | S2 | Fixed | OtpInput rebuilt as ONE hidden TextField with six drawn boxes. Typing over a box can no longer be mistaken for a paste. | Snapshot 03 types '482' into the single field and shows 4·8·2 in the first three boxes. |
| B-04 | S2 | Fixed | The single real field is labelled 'One-time code, 6 digits' and kept in the semantics tree (`Opacity(alwaysIncludeSemantics: true)`); the drawn boxes are excluded. | Code review. |
| B-05 | S2 | Fixed | PrimaryButton: `Semantics(onTap:, excludeSemantics: true)` + `FocusableActionDetector` (Enter/Space activate) + a visible 2.5 px focus ring. | Analyzer; snapshots unchanged when not focused. |
| B-06 | S2 | Fixed | ErrorView, the OTP notice and the terms error are `Semantics(liveRegion: true)`. | Code review. |
| B-07 | S2 | Fixed | 'Didn't receive OTP code? / Resend' now uses AuthSwitchLine, which is a centred Wrap (also fixes the same risk on Register/Login). | Snapshot 03. |
| B-08 | S2 | Fixed | AuthScaffold shows SampleDataBanner; Register keeps the send-otp message in `pendingSignupProvider` and the OTP screen shows it ('Sample mode: any 6 digits verify'). | Code review; snapshot 12 shows the banner. |
| B-09 | S2 | Fixed | `CallRecord.isRescheduled` (status rescheduled OR rescheduledAt set). The Scheduled filter, the calendar tab and the Scheduled stat now find the 11 records. | Unit test 'a called record with a rescheduledAt counts as scheduled'; queue chips show Scheduled 11. |
| B-10 | S3 | Fixed | `test/**/failures/` added to calley_app/.gitignore. | git status after a failing golden run. |
| B-11 | S3 | Fixed | Light textMuted #656975, danger #C0302F, success #167A47; dark textMuted #8D919C, all ≥4.5:1 on their surfaces. | Contrast computed per pair (noted in theme.dart comments). |
| B-12 | S3 | Fixed | mapDioError recognises a TLS HandshakeException/TlsException and says the certificate was unexpected (possibly renewed). | Unit test 'messages never contain a URL' still green; code review. |
| B-13 | S3 | Fixed (partly by design, DEC-015) | Partly by design: the session is kept (signing someone out because they tapped 'Use sample data' mid-task would be worse). Logged outcomes are cleared on a data-source switch, and lists/details refetch because they watch apiProvider. Recorded as DEC-015. | Code review. |
| B-14 | S3 | Fixed | signOut invalidates `pendingSignupProvider`; a successful login clears it. | Code review. |
| B-15 | S3 | Fixed | Mobile must be 10 digits starting 6–9. | validators_test.dart. |
| B-16 | S3 | Fixed | Same rebuild as B-03: one real field, so soft-keyboard backspace works natively. | Code review (soft keyboards cannot be driven in widget tests). |
| B-17 | S3 | Fixed | Banner 'Try server', error buttons, queue chips, the Refresh pill, disposition options and Forgot Password are all ≥48 dp. | Snapshots 07, 10, 11; code review. |
| B-18 | S3 | Fixed | Auth, language and disposition titles are `Semantics(header: true)`. | Code review. |
| B-19 | S3 | Fixed | A wrong code keeps the digits; only the error is shown. | Code review. |
| B-20 | S3 | Fixed | Register passes the mobile number on; OTP shows '+91 98711 25588' with a 'Wrong details?' link back to Register. | Code review. |
| B-21 | S3 | Fixed | `_retry` remembers which action failed; Retry repeats Resend or Verify accordingly. | Code review. |
| B-22 | S3 | Fixed | Register/Login/OTP read apiProvider and notifiers BEFORE awaiting, and check `mounted` before every setState after an await. | Code review. |
| B-23 | S3 | Fixed | AppTextField has `textCapitalization`; Name uses words. Email fields also turn autocorrect off. | Code review. |
| B-24 | S3 | Fixed | `IndianMobileFormatter` strips +91/0 prefixes from pasted or autofilled numbers before capping at 10 digits. | Code review; validators_test. |
| B-25 | S3 | Fixed | `if (_busy) return;` at the top of every submit/verify/resend. | Code review. |
| B-26 | S3 | Fixed | Checkbox and 'I agree to the' are one MergeSemantics control; 'Terms and Conditions' is a separate 48 dp TextButton. | Snapshot 02. |
| B-27 | S3 | Fixed | `Launcher.dial` returns bool; the outcome sheet only opens if the dialer opened. | Snapshot 10c (stubbed launcher returns true). |
| B-28 | S3 | Fixed | Dispositions are keyed `listId/recordKey`, with get/set/remove/countFor helpers. | Code review. |
| B-29 | S3 | Fixed | List name ellipsises inside Expanded; the '0 of 50 logged' count sits on the right. | Snapshot 10. |
| B-30 | S3 | Fixed | Queue checks `isLoading` before error; dashboard uses `skipLoadingOnRefresh: false`, so Retry shows skeletons. | Code review. |
| B-31 | S3 | Fixed | Search compares digits with digits. | Code review. |
| B-32 | S3 | Fixed | Rows expose `expanded` and an onTapHint; the Call button is disabled (and says so) when there is no number. | Code review. |
| B-33 | S3 | Fixed | 'Rescheduled' fact shows whenever `rescheduledAt != null`. | Snapshot 10b. |
| B-34 | S3 | Fixed | Phone tab dials the next OPEN contact (pending, not rescheduled, not logged), then opens the outcome sheet; loading/error get their own messages. | Code review. |
| B-35 | S3 | Fixed | Greeting restored to Figma: 'Hello' / name / 'Welcome to Calley!'. | Snapshots 05, 06. |
| B-36 | S3 | Fixed | Empty-dashboard CTA is busy while lists load, 'Try again' on error, opens the web panel only when lists loaded empty. | Snapshot 06b. |
| B-37 | S3 | Fixed | Illustration is a fixed 150×126 box; badges sit on the circle's edge. | Snapshot 06b shows both badges. |
| B-38 | S3 | Fixed | Every pull-to-refresh invalidates, then awaits inside try/catch. | Code review. |
| B-39 | S3 | Fixed | 'Done' is `c.done` (blue) in ring, legend, ledger, chips and pills; green is only the call button. | Snapshots 08, 10. |
| B-40 | S3 | Fixed | Ring sized from the card width (LayoutBuilder); legend is a centred Wrap under the ring. | Snapshot 08. |
| B-41 | S3 | Fixed | 'Sync Data' says 'Reloading sample data…' in sample mode. | Code review. |
| B-42 | S3 | Fixed | Language and list rows are single semantics nodes (`excludeSemantics: true`, own onTap), read once. | Code review. |
| B-43 | S3 | Fixed | First run says 'Choose Your Language' and 'Select', as in Figma 01. | Snapshot 01. |
| B-44 | S3 | Fixed | Getting Started instruction restored to the Figma sentence. | Snapshot 05. |
| B-45 | S3 | Fixed | Tutorial card is a centred Column with minHeight 200 that grows with text; play disc outlined. | Snapshot 05. |
| B-46 | S3 | Fixed | Data source is a SwitchListTile 'Use sample data'; one control, one label, whole row toggles. | Snapshot 07b. |
| B-47 | S3 | Fixed | `--pending` rebuilds the report when the title changes (with a warning); keeps hand edits when the title is the same. | Ran during this build's commit. |

## UX/HCI changes made in the same pass

From the 48 judged HCI findings (scores in the audit output). Applied:

- **Centring** (Gestalt / single focal axis): logo, title and instruction on Register, OTP, Login and Language; the ring chart with its legend underneath; empty states; sheet headings; the tutorial card and the web-panel link. Forms, lists and the ledger stay left-aligned for scanning.
- **Counts that add up**: the server's 27 + 23 + 11 = 61 double-counts the 11 rescheduled calls (they are also 'called'). The ring and ledger now show disjoint groups. Pending 27 · Done 12 · Scheduled 11 = 50 contacts, with a one-line note.
- **The calling loop** (task flow for an agent with 50 numbers): queue opens on 'To call'; a thumb-zone 'Call next · Sherri' button; outcome sheet after each call with Undo in a snackbar; 'Log outcome' / 'Change outcome' without dialling; 'n of 50 logged' with a progress bar; logged contacts drop out of 'To call'.
- **Error states by cause**: 404 → 'Not available on the Calley test server' with 'Use sample data' as the primary button; network/timeout get their own words and icons; wrong password/OTP no longer show a cloud icon or 'Request refused'.
- **Search clear button**, and an empty-state 'Clear search' action.
- **Logout warns** how many logged outcomes will be cleared.
- **Real links** from getcalley.com: Terms, Privacy, About, Download; WhatsApp help uses the number published on csquaretech.com.
- **app.getcalley.com** in the copy is now a working link.

Not applied, on purpose (would contradict the Figma screens a reviewer compares against): moving the Sign-in/Sign-up line below the button, renaming 'Whatsapp OTP Verification', relabelling the bottom bar, regrouping the drawer, auto-login after OTP.
