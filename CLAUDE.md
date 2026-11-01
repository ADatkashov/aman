# AMAN — instructions for AI agents

Digital health ecosystem: **Flutter** patient app (`app/`) + **Spring Boot 3** API (`backend/`).

## Authorization (granted by the repository owner)

The owner granted full control of the `main` branch: merge commits, merges of
pull requests and pushes are allowed without asking for confirmation each time.
Details: [`docs/PROJECT_PERMISSIONS.md`](docs/PROJECT_PERMISSIONS.md).

## Rules

- Synthetic data only; mark demo content `DEMO`. Never commit secrets or real PHI.
- Never put user-facing strings in widgets: add them to `app/lib/l10n/app_{en,ru,kk}.arb`.
- Business rules live in domain/services, not in widgets. Keep them unit-tested.
- Before pushing: `cd app && flutter analyze && flutter test`; `cd backend && mvn verify`.

## Commands

| Task | Command |
| --- | --- |
| Flutter run (demo) | `cd app && flutter run` |
| Flutter tests | `cd app && flutter test` |
| Backend tests | `cd backend && mvn verify` |
| Backend run (demo) | `cd backend && mvn spring-boot:run -Dspring-boot.run.profiles=demo` |
