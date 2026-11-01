# Roadmap: AMAN ecosystem

One platform, three products, one backend and one domain model.

| Product | Audience | Scope |
| --- | --- | --- |
| **AMAN Patient** ✅ | patients | doctors, booking, results, record, documents, clinics + map, notifications, kk/ru/en |
| **AMAN Doctor** | doctors | schedule, today's visits, patient chart within granted rights, conclusions, prescriptions, lab orders |
| **AMAN Clinic** (web) | clinic admins | staff & doctors, schedules, services & prices, appointment management, analytics |
| Admin console | platform admins | users, clinics, doctors, specialties, analytics, access control |

## Foundation already in place

* Roles `PATIENT / DOCTOR / CLINIC_ADMIN / SUPER_ADMIN`, per-prefix authorization (`/doctor`, `/clinic`, `/admin`), deny-by-default.
* Domain tables for doctors, schedules, clinics, services, appointments, lab results/orders, record entries, documents, notifications, audit.
* Medical data is always queried through the patient scope; doctor access will add an explicit **care relationship** check
  (an appointment/referral that grants access) and an audit entry per read.
* Client architecture is feature-first, so the doctor app can reuse `core/` (theme, widgets, l10n, network) as a shared package.

## Next steps (in priority order)

1. SMS gateway adapter (`SmsSender`) and push notifications (FCM/APNs) for reminders and "results ready".
2. Live maps adapter (`MapAdapter` for Google Maps / 2GIS MapGL) with API keys supplied via CI secrets.
3. Doctor API (`/doctor/**`): schedule management, visit conclusions that create `MedicalRecordEntry` rows (types `DIAGNOSIS`, `PRESCRIPTION`, …) and signed documents, lab orders.
4. Clinic API (`/clinic/**`) and web console (Flutter web or React): staff, schedules, prices, analytics.
5. Telemedicine (video visits) — the UI entry point exists and honestly shows "coming soon".
6. Integration with Kazakhstan medical information systems / e-prescriptions; legal review for medical-data processing.
7. Real PDF viewer and in-app document scanning; offline cache (Drift/Isar) for read-only data.
8. Observability: structured logs without PHI, metrics, tracing; load tests of the booking path.
