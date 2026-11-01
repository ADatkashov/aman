# AMAN REST API (v1)

Base URL: `https://<host>/api/v1` · JSON · UTF-8 · timestamps in UTC ISO-8601 · OpenAPI UI at `/swagger-ui.html`
(enabled in the `demo` profile; protect or disable in production).

All endpoints except `/auth/**` require `Authorization: Bearer <access token>`; patient endpoints require the `PATIENT` role.

## Error format

```json
{ "timestamp": "2026-11-01T08:46:34Z", "status": 409, "code": "SLOT_TAKEN",
  "message": "This time has just been booked",
  "details": [ { "field": "password", "message": "8-72 chars with a letter and a digit" } ] }
```

`details` is present only for `VALIDATION_ERROR`. Messages never contain personal or medical data.

| HTTP | `code` | Meaning |
| --- | --- | --- |
| 400 | `VALIDATION_ERROR`, `CONSENT_REQUIRED`, `INVALID_OTP`, `FILE_EMPTY` | invalid input |
| 401 | `UNAUTHORIZED`, `INVALID_CREDENTIALS` | missing/invalid token, wrong login |
| 403 | `FORBIDDEN` | role is not allowed |
| 404 | `NOT_FOUND`, `ACCOUNT_NOT_FOUND` | unknown id **or another patient's resource** |
| 409 | `SLOT_TAKEN`, `TOO_LATE_TO_CHANGE`, `PHONE_TAKEN`, `ALREADY_REVIEWED`, `NOT_COMPLETED`, `CONFLICT` | state conflict |
| 413 | `FILE_TOO_LARGE` | upload > 10 MB |
| 415 | `FILE_TYPE_NOT_ALLOWED` | not PDF/JPG/PNG or content does not match the extension |
| 422 | `SLOT_IN_PAST`, `OUTSIDE_SCHEDULE` | slot cannot be booked |
| 429 | `TOO_MANY_REQUESTS` | rate limit |

## Authentication

| Method & path | Body | Result |
| --- | --- | --- |
| `POST /auth/register` | `{fullName, phone:"+7XXXXXXXXXX", password, consentAccepted}` | `201 {otpSent, demoOtp?}` — creates an **unverified** account, sends an OTP |
| `POST /auth/otp/request` | `{phone}` | `{otpSent, demoOtp?}` |
| `POST /auth/otp/verify` | `{phone, code}` | `AuthResponse` — confirms the phone and signs in |
| `POST /auth/login` | `{phone, password}` | `AuthResponse` |
| `POST /auth/refresh` | `{refreshToken}` | `AuthResponse` (token rotation; re-use revokes all tokens) |
| `POST /auth/logout` | `{refreshToken}` | `204` |
| `POST /auth/password/forgot` | `{phone}` | `{otpSent, demoOtp?}` |
| `POST /auth/password/reset` | `{phone, code, newPassword}` | `204` |

`AuthResponse = { accessToken, refreshToken, expiresInSeconds, patient }`. `demoOtp` is returned only with `aman.otp.expose-demo-code=true` (demo profile).
Password policy: 8–72 characters with a letter and a digit.

## Patient

| Method & path | Notes |
| --- | --- |
| `GET /patients/me` · `PUT /patients/me` | profile (`fullName, email, birthDate, gender MALE\|FEMALE, bloodType, city`) |
| `GET /patients/me/favorites` | ids of favorite doctors |
| `PUT /patients/me/favorites/{doctorId}` · `DELETE …` | idempotent |

## Catalog

| Method & path | Notes |
| --- | --- |
| `GET /doctors?specialty=&clinicId=&q=` | sorted by popularity |
| `GET /doctors/{id}` | education, qualification, about (`{ru,en,kk}`), services, languages |
| `GET /doctors/{id}/schedule?date=YYYY-MM-DD` | `[ {start, available} ]` for the day in the clinic zone; past/outside horizon → `[]` |
| `GET /doctors/{id}/next-slot` | `{start}` or `{}` |
| `GET /doctors/{id}/reviews` | latest 20, author shown as "Name S." |
| `GET /clinics` · `GET /clinics/{id}` | with coordinates, working hours, services |

## Appointments

| Method & path | Notes |
| --- | --- |
| `POST /appointments` | `{doctorId, start, reason}` → `201`. `start` must be a slot returned by `/schedule`. |
| `GET /appointments` · `GET /appointments/{id}` | own visits only |
| `PATCH /appointments/{id}/cancel` | `{reason?}`; allowed until the clinic deadline (`changeDeadlineHours`) |
| `PATCH /appointments/{id}/reschedule` | `{start}`; same rules and slot validation |
| `POST /appointments/{id}/review` | `{rating 1..5, text?}`; after the visit, once |

Double booking is impossible: the database has a unique `active_slot_key`; the loser of a race receives `409 SLOT_TAKEN`.

## Laboratory, medical record, documents, notifications

| Method & path | Notes |
| --- | --- |
| `GET /laboratory/results` · `/results/{id}` · `/orders` | values come with the laboratory's `refMin/refMax`; status `ATTENTION` only means "outside the lab range" — no diagnosis |
| `GET /medical-records` · `/medical-records/{id}` | every entry carries `sourceRef` (visit number / document) |
| `GET /documents` · `GET /documents/{id}` · `GET /documents/{id}/content` | download is `no-store`, `nosniff`, audited |
| `POST /documents` | `multipart/form-data`: `file`, `title?`, `kind?`; ≤ 10 MB; PDF/JPG/PNG with matching signature |
| `DELETE /documents/{id}` | only the patient's own uploads |
| `GET /notifications` · `PATCH /{id}/read` · `PATCH /read-all` · `DELETE /{id}` | events are `type + params`; clients render localized text |

Reads of lab results, records and documents are written to `audit_log` (who / what / when, never the content).

## Reserved prefixes

`/doctor/**` (DOCTOR), `/clinic/**` (CLINIC_ADMIN), `/admin/**` (SUPER_ADMIN) are protected by role and currently have no endpoints (deny by default).
