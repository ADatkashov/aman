import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo/demo_repositories.dart';
import '../data/demo/demo_store.dart';
import '../data/remote/api_client.dart';
import '../data/remote/remote_repositories.dart';
import '../features/analyses/domain/lab_repository.dart';
import '../features/appointments/domain/appointment_repository.dart';
import '../features/auth/data/secure_token_storage.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/domain/token_storage.dart';
import '../features/catalog/domain/catalog_repository.dart';
import '../features/documents/domain/document_repository.dart';
import '../features/medical_record/domain/medical_record_repository.dart';
import '../features/notifications/domain/notification_repository.dart';
import 'config/app_config.dart';
import 'utils/clock.dart';

/// Composition root. Every provider here can be overridden in tests.
final appConfigProvider = Provider<AppConfig>((ref) => const AppConfig());

final clockProvider = Provider<Clock>((ref) => DateTime.now);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden in main()'),
);

final tokenStorageProvider = Provider<TokenStorage>((ref) => SecureTokenStorage());

/// Artificial latency in demo mode so skeletons / spinners are visible.
final demoLatencyProvider = Provider<Duration>((ref) => const Duration(milliseconds: 450));

final demoStoreProvider = Provider<DemoStore>(
  (ref) => DemoStore(clock: ref.watch(clockProvider), latency: ref.watch(demoLatencyProvider)),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(config: ref.watch(appConfigProvider), tokens: ref.watch(tokenStorageProvider)),
);

bool _demo(Ref ref) => ref.watch(appConfigProvider).isDemo;

final authRepositoryProvider = Provider<AuthRepository>((ref) => _demo(ref)
    ? DemoAuthRepository(ref.watch(demoStoreProvider), ref.watch(tokenStorageProvider))
    : RemoteAuthRepository(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider)));

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => _demo(ref)
    ? DemoCatalogRepository(ref.watch(demoStoreProvider))
    : RemoteCatalogRepository(ref.watch(apiClientProvider)));

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) => _demo(ref)
    ? DemoAppointmentRepository(ref.watch(demoStoreProvider))
    : RemoteAppointmentRepository(ref.watch(apiClientProvider)));

final labRepositoryProvider = Provider<LabRepository>((ref) => _demo(ref)
    ? DemoLabRepository(ref.watch(demoStoreProvider))
    : RemoteLabRepository(ref.watch(apiClientProvider)));

final medicalRecordRepositoryProvider = Provider<MedicalRecordRepository>((ref) => _demo(ref)
    ? DemoMedicalRecordRepository(ref.watch(demoStoreProvider))
    : RemoteMedicalRecordRepository(ref.watch(apiClientProvider)));

final documentRepositoryProvider = Provider<DocumentRepository>((ref) => _demo(ref)
    ? DemoDocumentRepository(ref.watch(demoStoreProvider))
    : RemoteDocumentRepository(ref.watch(apiClientProvider)));

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => _demo(ref)
    ? DemoNotificationRepository(ref.watch(demoStoreProvider))
    : RemoteNotificationRepository(ref.watch(apiClientProvider)));
