# api_reference.md — Calley mock REST API ("Mock API V2")

> **Official collection found (2026-11-05):** https://documenter.getpostman.com/view/38199901/2sB34Zpiy9 — saved as [assets/postman-mock-api-v2.json](assets/postman-mock-api-v2.json). It confirms the base URL, the six endpoints and the bodies below. Examples: register → 201 `{"message":"User registered"}`; login → 200 `{"message":"Login successful","user":{"_id","username","email"}}`; send-otp → `{"message":"OTP sent"}`; verify-otp → `{"message":"OTP Verfied"}`; `GET /list` → **one object** `{_id,name,agents,clientId}`, not an array; list details → exactly `assets/sample-list-details.json`. Example login password is `123`, so sign-in must not enforce a length (fixed: `Validators.loginPassword`). **The host still answers 404 on every documented path** (re-checked 2026-11-05).


> **Provenance:** NOT on the Notion page. Reconstructed from two prior candidates' public repos
> (`Renukaaapatil/calley_app`, `nikhilswami992/calley_app`) which both cite the same base URL and
> endpoints, and one says its offline JSON "matches the Postman collection". Treat as **unverified
> until you hit it yourself** (tasks §0). Response shapes marked *inferred* were deduced from how
> the candidates parsed them.

**Base URL:** `https://mock-api.calleyacd.com/api`
**Headers:** `Content-Type: application/json`
**Status (2026-11-04, verified with a pinned-cert Dart probe):** the host is up and serves a valid Let's Encrypt certificate for `cool-meninsky.74-208-123-142.plesk.page` (SHA-256 `D35CCFE3…7FDF`, expires 2027-01-19), so hostname validation fails for `mock-api.calleyacd.com`. With that certificate pinned, **every `/api/*` path answers an empty HTTP 404** (nginx), and so do `/api/v2/…`, `/api/v1/…`, `/list`, `/health`. The root `/` is the Plesk default page. **The mock API is not serving.** Ask HR for the current base URL / Postman collection. See pain P-01 and DEC-010.

| # | Method | Path | Body | Success |
|---|--------|------|------|---------|
| 1 | POST | `/auth/register` | `{ "username", "email", "password" }` | 200/201, JSON `{ "message": ... }` *(inferred)* |
| 2 | POST | `/auth/login` | `{ "email", "password" }` | 200, `{ "user": { "_id", "username", "email", "phone"?, "subscription"? } }` *(inferred from parser)* |
| 3 | POST | `/auth/send-otp` | `{ "email" }` | 200, `{ "message": ... }` |
| 4 | POST | `/auth/verify-otp` | `{ "email", "otp" }` | 200, `{ "message": ... }` |
| 5 | GET | `/list?userId={userId}` | — | 200, **array** of CallingList (one candidate also handled a single object) |
| 6 | GET | `/list/{listId}` | — | 200, ListDetails |

## Models (from candidates' mock data — likely mirrors the real Postman examples)

### User
```json
{
  "_id": "68626f9497757cb741f449b0",
  "username": "Swati Sharma",
  "email": "swati@cstech.in",
  "phone": "+91 9871125588",
  "subscription": "Calley Personal"
}
```

### CallingList
```json
{
  "_id": "68626fb697757cb741f449b9",
  "name": "Test List",
  "agents": [],
  "clientId": "68626f9497757cb741f449b0"
}
```

### ListDetails  (full 50-record file: [assets/sample-list-details.json](assets/sample-list-details.json))
```json
{
  "pending": 27,
  "called": 23,
  "rescheduled": 11,
  "calls": [ CallRecord × 50 ]
}
```

### CallRecord
```json
{
  "FirstName": "Danielle",
  "LastName": "Johnson",
  "Title": "Mrs.",
  "Phone": 1000000000,
  "Other Phone 1": 1000000003,
  "Other Phone 2": 1000000006,
  "Other Phone 3": 1000000009,
  "Other Phone 4": 1000000012,
  "Email": "donaldgarcia@mcclain.com",
  "Address": "908 Jennifer Squares, Robinsonshire, AL 21427",
  "Company": "Henderson, Ramirez and Lewis",
  "Age": 73,
  "Zip": 44619,
  "MaritalStatus": "Single",
  "Notes": "Here grow gas enough analysis least by.",
  "calledAt": "2025-06-22 19:41:31",
  "rescheduledAt": "2025-06-23 19:41:31",
  "createdAt": "2025-05-03 10:34:31",
  "status": "called",
  "agentName": "Dhrubo",
  "agentId": "68626f9497757cb741f449b0",
  "duration": 17,
  "feedback": "Needs follow-up"
}
```

Parsing gotchas:
- Keys are **PascalCase with spaces** (`"Other Phone 1"`) — map explicitly, don't rely on codegen defaults.
- `Phone` is a **number**, not a string → `toString()` before `tel:`.
- `calledAt`, `rescheduledAt`, `duration`, `feedback` are **nullable**.
- `status` ∈ `pending | called | rescheduled`. Map to UI: Pending / Done / Schedule.
- `feedback` values seen: "Very positive", "Satisfied", "Needs follow-up", "Neutral", "Negative" → use as disposition options.
- Note `pending + called + rescheduled = 61` while `calls.length = 50` in the sample — counts and records don't reconcile. Show the API counts in the stat cards and `calls.length` in the "N CALLS" badge; don't try to recompute.

## Dart sketch

```dart
class ListDetails {
  final int pending, called, rescheduled;
  final List<CallRecord> calls;
  factory ListDetails.fromJson(Map<String, dynamic> j) => ListDetails(
    pending: j['pending'] ?? 0,
    called: j['called'] ?? 0,
    rescheduled: j['rescheduled'] ?? 0,
    calls: (j['calls'] as List? ?? []).map((e) => CallRecord.fromJson(e)).toList(),
  );
}
```

## To verify (fill in after testing)
- [ ] Register: exact success/duplicate responses
- [ ] Login: does it return `user` or the user object at top level? Any token?
- [ ] send-otp / verify-otp: does *any* 6-digit OTP pass on the mock?
- [ ] GET /list: array vs object
- [ ] Do IDs from register/login actually resolve in `/list?userId=`? Or is there a fixed demo userId (`68626f9497757cb741f449b0`)?
