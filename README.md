# AMAN — здоровье рядом · Your Health. Your Life.

AMAN is a digital health ecosystem for Kazakhstan: patients find doctors, book visits,
read lab results, keep a verified medical record and documents — in one secure app.

| Product | Status | Where |
| --- | --- | --- |
| **AMAN Patient** (Flutter, iOS / Android / web) | ✅ implemented | [`app/`](app) |
| **AMAN API** (Spring Boot 3, PostgreSQL) | ✅ implemented (patient domain) | [`backend/`](backend) |
| AMAN Doctor (doctor app) | architecture ready, see [roadmap](docs/ROADMAP.md) | — |
| AMAN Clinic (clinic web platform) | architecture ready, see [roadmap](docs/ROADMAP.md) | — |

> **All data in demo mode is synthetic and marked DEMO.** Never put real personal or medical data into a demo or test environment.

## Quick start (no backend needed)

The app ships with a **demo mode**: an in-memory backend that enforces the same business rules
(slot validation, no double booking, clinic change policy) with synthetic data.

```bash
cd app
flutter pub get
flutter run                      # demo mode is the default
```

Demo account: **+7 700 000 00 01 / `Demo1234`** (OTP code in demo mode: `1111`, shown on screen).

## Run with the real backend

```bash
# 1. Backend + PostgreSQL (synthetic demo data)
cp .env.example .env             # set POSTGRES_PASSWORD and AMAN_JWT_SECRET (openssl rand -base64 48)
docker compose up --build        # API on http://localhost:8080 (Swagger UI: /swagger-ui.html in demo profile)

# 2. Flutter app against the API (Android emulator reaches the host as 10.0.2.2)
cd app
flutter run --dart-define=AMAN_API_MODE=remote --dart-define=AMAN_API_URL=http://10.0.2.2:8080/api/v1
```

Without Docker: `cd backend && mvn spring-boot:run -Dspring-boot.run.profiles=demo` (needs PostgreSQL, see `.env.example`).

## Repository layout

```
app/        Flutter client (feature-first Clean Architecture, Riverpod, GoRouter, Dio)
backend/    Spring Boot 3 REST API (Java 17+, JPA, Flyway, JWT, RBAC)
docs/       Architecture, ER diagram, API reference, build guide, roadmap
```

Details: [Architecture](docs/ARCHITECTURE.md) · [ER diagram](docs/ER_DIAGRAM.md) · [API](docs/API.md) ·
[Build & release](docs/BUILD.md) · [Roadmap](docs/ROADMAP.md) · [Security](SECURITY.md)

## Technology

* **Client:** Flutter 3.x / Dart 3, Material 3 with a custom design system, `flutter_riverpod`, `go_router`, `dio`,
  `flutter_secure_storage`, `intl` + generated ARB localizations (kk / ru / en), `file_picker`, `url_launcher`.
* **Server:** Spring Boot 3.3, Spring Security (stateless JWT), Spring Data JPA, Flyway, PostgreSQL, springdoc OpenAPI.
* **Quality:** `flutter analyze`, 97 Flutter unit/widget tests, JUnit 5 + MockMvc integration tests on the backend.

## Testing

```bash
cd app && flutter analyze && flutter test        # unit + widget tests (demo backend, fixed clock)
cd backend && mvn verify                         # unit + MockMvc integration tests (H2)
```

Covered critical logic: authentication/registration/OTP, doctor search & filters, schedule generation,
booking, **double-booking protection (also under concurrency)**, cancel / reschedule rules, lab results,
localization (key parity, plurals, KZT/date formats), navigation guards, RBAC, data isolation between patients,
secure document upload.

## Design system (summary)

Palette `#0866E9 / #0753C7 / #4D9BFF / #EAF3FF`, background `#F4F7FC`, radii 16–24 px, soft shadows,
light **and** dark themes. Components live in `app/lib/core/widgets`: `PrimaryButton`, `SecondaryButton`,
`DoctorCard`, `ClinicCard`, `AppointmentCard`, `AnalysisCard`, `MedicalRecordCard`, `SearchField`,
`AmanFilterChip`, `StatusBadge`, `EmptyState`, `LoadingState` (skeletons), `ErrorState`,
`CustomBottomNavigation`, `CustomAppBar`, and the AMAN logo (`AmanLogo`).

## Configuration

| Variable (`--dart-define`) | Default | Meaning |
| --- | --- | --- |
| `AMAN_API_MODE` | `demo` | `demo` = in-memory synthetic data, `remote` = Spring Boot API |
| `AMAN_API_URL` | `http://10.0.2.2:8080/api/v1` | API base URL (**HTTPS in production**) |
| `AMAN_MAPS_PROVIDER` | `2gis` | route deep-links: `2gis` or `google` (no API key required) |

Backend settings are environment variables listed in [`.env.example`](.env.example). Real secrets are never committed.

## Known limits / production checklist

See [SECURITY.md](SECURITY.md#required-before-production) and [docs/ROADMAP.md](docs/ROADMAP.md): SMS gateway,
live map SDK key, push notifications, e-signature / integration with national medical information systems,
telemedicine, doctor and clinic portals.

## License

Apache-2.0 — see [LICENSE](LICENSE).
