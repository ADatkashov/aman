# Build, run and release guide

## Prerequisites

* Flutter 3.47+ (Dart 3.13+) · Java 17+ (21 tested) · Maven 3.9+ · PostgreSQL 14+ (or Docker)
* Android: Android SDK + `ANDROID_HOME`; iOS: macOS + Xcode.

## Backend

```bash
cd backend
mvn verify                                    # compile + 34 unit/integration tests (H2)
mvn spring-boot:run -Dspring-boot.run.profiles=demo   # needs PostgreSQL, see .env.example
mvn -DskipTests package && java -jar target/aman-backend-1.0.0.jar
```

Production profile: no `demo` profile; set `AMAN_DB_*`, `AMAN_JWT_SECRET`, `AMAN_STORAGE_DIR`, `AMAN_CORS_ORIGINS`; provide an `SmsSender` bean;
terminate TLS in front of the service. Docker image: `docker build -t aman-backend backend`.

## Flutter

```bash
cd app
flutter pub get
flutter gen-l10n                      # only needed after editing lib/l10n/*.arb (also run by flutter build)
flutter analyze && flutter test
```

| Target | Command |
| --- | --- |
| Run (demo data) | `flutter run` |
| Run against the API | `flutter run --dart-define=AMAN_API_MODE=remote --dart-define=AMAN_API_URL=https://api.example.kz/api/v1` |
| Android APK | `flutter build apk --release --dart-define=AMAN_API_MODE=remote --dart-define=AMAN_API_URL=https://…` |
| Android App Bundle | `flutter build appbundle --release …` (configure signing in `android/key.properties`, never commit it) |
| iOS | `flutter build ipa --release …` (set bundle id / team in Xcode) |
| Web | `flutter build web --release …` |

`AMAN_API_MODE=demo` (default) needs no server and shows synthetic data only — do not ship a demo build to end users.

## Localization workflow

Add the key to `app/lib/l10n/app_en.arb` (template, with `@key` placeholders) **and** `app_ru.arb`, `app_kk.arb`;
`test/unit/localization_test.dart` fails if a language misses a key or placeholders differ.

## CI suggestion

```yaml
- run: cd app && flutter pub get && flutter analyze && flutter test
- run: cd backend && mvn -B verify
```
