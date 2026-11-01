# Security policy

AMAN processes personal and **medical** data. This document lists the controls
implemented in the code and what must be done at deployment time.

## Implemented controls

| Area | Control |
| --- | --- |
| Authentication | Phone + password (BCrypt, cost 12) and OTP phone confirmation. Short-lived JWT access tokens (15 min, HS256); opaque refresh tokens stored **hashed**, rotated on every use, reuse of a rotated token revokes the whole family. |
| Brute force | Sliding-window limits on login, OTP and registration; OTP is HMAC-hashed, expires in 5 min, max 5 attempts; login errors are identical for unknown phone / wrong password / unverified account. |
| Authorization | RBAC (`PATIENT`, `DOCTOR`, `CLINIC_ADMIN`, `SUPER_ADMIN`) enforced per URL prefix; deny-by-default. Every medical query is scoped by the owning patient id inside the repository query, so another patient's id returns `404`. |
| Audit | `audit_log` records who read/downloaded/uploaded/deleted lab results, records and documents (never the content). |
| Files | 10 MB limit, extension whitelist (PDF/JPG/PNG), signature (magic bytes) check, random storage key (no user-controlled paths), `nosniff` + `no-store` on downloads, ownership check on every access. |
| Transport | HTTPS is mandatory in production (HSTS header set). The Flutter client rejects cleartext only in release builds when the platform default applies; configure `AMAN_API_URL` with `https://`. |
| Client storage | Tokens are kept in Keychain / Keystore (`flutter_secure_storage`). Passwords and medical data are never persisted on the device. |
| Logging | Only error types are logged; request bodies, OTP codes and medical data are never written to logs. The SMS fallback never logs the code. |
| Data | Demo/seed data is synthetic and marked `DEMO`. Secrets come from the environment; `.env` is git-ignored. |

## Required before production

1. Provide an `SmsSender` bean for a real SMS gateway (Kazakhstan operators) — without it OTP codes are not delivered.
2. Set `AMAN_JWT_SECRET` (>= 32 random bytes) from a secret manager; rotate periodically.
3. Terminate TLS (reverse proxy / load balancer) and restrict the database to the private network.
4. Put `AMAN_STORAGE_DIR` on an encrypted volume or switch `DocumentService` to encrypted object storage; add antivirus scanning of uploads.
5. Replace the in-memory `RateLimiter` with a shared store (Redis) when running more than one instance.
6. Complete the legal basis for processing medical data (Law of the Republic of Kazakhstan on Personal Data and its Protection, health-data localization requirements) and a retention policy.
7. Run a penetration test and dependency scanning (`mvn dependency-check`, `flutter pub outdated`) in CI.

## Reporting a vulnerability

Please open a private security advisory on GitHub or email the repository owner. Do not include real patient data in reports.
