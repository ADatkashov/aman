import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aman/core/config/app_config.dart';
import 'package:aman/core/l10n/l10n_ext.dart' show NetworkException;
import 'package:aman/data/remote/api_client.dart';
import 'package:aman/data/remote/remote_repositories.dart';
import 'package:aman/features/analyses/domain/lab_result.dart';
import 'package:aman/features/appointments/domain/appointment.dart';
import 'package:aman/features/auth/domain/auth_repository.dart';
import 'package:aman/features/auth/domain/token_storage.dart';
import 'package:aman/features/documents/domain/medical_document.dart';
import 'package:aman/features/notifications/domain/app_notification.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contract test: the Dart models must parse the JSON produced by the real
/// Spring Boot API. The fixtures in `test/fixtures` were exported from the
/// backend running with the `demo` profile (synthetic data).
class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter(this.routes);

  /// `METHOD path` → (status, body)
  final Map<String, (int, Object?)> routes;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final hit = routes['${options.method} ${options.uri.path}'];
    if (hit == null) {
      return ResponseBody.fromString(
        '{"code":"NOT_FOUND"}',
        404,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    final body = hit.$2 is String ? hit.$2 as String : jsonEncode(hit.$2);
    return ResponseBody.fromString(
      body,
      hit.$1,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

String _fx(String name) => File('test/fixtures/$name.json').readAsStringSync();

void main() {
  late _FixtureAdapter adapter;
  late ApiClient api;
  late MemoryTokenStorage tokens;

  setUp(() {
    tokens = MemoryTokenStorage();
    adapter = _FixtureAdapter({
      'GET /api/v1/doctors': (200, _fx('doctors')),
      'GET /api/v1/doctors/1': (200, _fx('doctor_1')),
      'GET /api/v1/doctors/1/schedule': (200, _fx('schedule')),
      'GET /api/v1/doctors/1/next-slot': (200, _fx('next_slot')),
      'GET /api/v1/doctors/1/reviews': (200, _fx('reviews')),
      'GET /api/v1/clinics': (200, _fx('clinics')),
      'GET /api/v1/patients/me/favorites': (200, _fx('favorites')),
      'GET /api/v1/appointments': (200, _fx('appointments')),
      'GET /api/v1/laboratory/results': (200, _fx('lab_results')),
      'GET /api/v1/laboratory/orders': (200, _fx('lab_orders')),
      'GET /api/v1/medical-records': (200, _fx('medical_records')),
      'GET /api/v1/documents': (200, _fx('documents')),
      'GET /api/v1/notifications': (200, _fx('notifications')),
      'GET /api/v1/patients/me': (200, _fx('patients_me')),
      'POST /api/v1/auth/login': (200, _fx('login')),
      'POST /api/v1/appointments': (
        409,
        '{"status":409,"code":"SLOT_TAKEN","message":"x"}',
      ),
      'POST /api/v1/auth/otp/verify': (
        400,
        '{"status":400,"code":"INVALID_OTP","message":"x"}',
      ),
      'PATCH /api/v1/appointments/1/cancel': (
        409,
        '{"status":409,"code":"TOO_LATE_TO_CHANGE","message":"x"}',
      ),
      'POST /api/v1/documents': (
        415,
        '{"status":415,"code":"FILE_TYPE_NOT_ALLOWED","message":"x"}',
      ),
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))
      ..httpClientAdapter = adapter;
    api = ApiClient(
      config: const AppConfig(apiMode: 'remote'),
      tokens: tokens,
      dio: dio,
    );
  });

  test(
    'catalog: doctors, clinics, schedule, next slot and favorites',
    () async {
      final catalog = RemoteCatalogRepository(api);
      final doctors = await catalog.doctors();
      expect(doctors.length, 14);
      final d = doctors.first;
      expect(d.id, isNotEmpty);
      expect(d.education.of('kk'), isNotEmpty);
      expect(d.services, isNotEmpty);
      expect(d.languages, isNotEmpty);
      expect((await catalog.doctor('1')).fullName, startsWith('Смирнов'));

      final clinics = await catalog.clinics();
      expect(clinics.length, 6);
      expect(clinics.first.workingHours.of('en'), contains('Mon'));
      expect(clinics.first.changeDeadlineHours, 2);
      expect(clinics.first.isDemo, isTrue);

      final slots = await catalog.slots('1', DateTime(2026, 11, 4));
      expect(slots, isNotEmpty);
      expect(
        slots.first.start.isUtc,
        isFalse,
        reason: 'converted to local time',
      );
      expect(await catalog.nextSlot('1'), isNotNull);
      expect(await catalog.reviews('1'), isEmpty);
      expect(await catalog.favorites(), {'1', '2', '5'});
      // The date is sent as yyyy-MM-dd.
      expect(
        adapter.requests
            .firstWhere((r) => r.uri.path.endsWith('/schedule'))
            .queryParameters['date'],
        '2026-11-04',
      );
    },
  );

  test('appointments parse with statuses and ISO instants', () async {
    final list = await RemoteAppointmentRepository(api).list();
    expect(list.length, 6);
    expect(list.map((a) => a.status).toSet(), {
      AppointmentStatus.confirmed,
      AppointmentStatus.completed,
      AppointmentStatus.cancelled,
    });
    expect(list.every((a) => a.number.startsWith('AM-')), isTrue);
    final cancelled = list.firstWhere(
      (a) => a.status == AppointmentStatus.cancelled,
    );
    expect(cancelled.cancelReason, isNotEmpty);
  });

  test('laboratory results keep the lab reference ranges and enums', () async {
    final labs = RemoteLabRepository(api);
    final results = await labs.results();
    expect(results.length, greaterThanOrEqualTo(10));
    expect(
      {...results.map((r) => r.category)}.length,
      LabCategory.values.length,
    );
    final bio = results.firstWhere((r) => r.testCode == 'biochem');
    expect(
      bio.status,
      LabStatus.attention,
      reason: 'cholesterol above the laboratory limit',
    );
    final chol = bio.indicators.firstWhere(
      (i) => i.name.of('en') == 'Total cholesterol',
    );
    expect(chol.refMax, 5.2);
    expect(chol.refMin, isNull);
    expect(chol.isOutOfRange, isTrue);
    expect(
      results.firstWhere((r) => r.testCode == 'pcr-flu').status,
      LabStatus.processing,
    );
    expect(
      results.firstWhere((r) => r.testCode == 'ecg').documentId,
      isNotNull,
    );
    final orders = await labs.orders();
    expect(
      orders.map((o) => o.status),
      containsAll([LabStatus.pending, LabStatus.processing]),
    );
  });

  test('medical record, documents and notifications', () async {
    final entries = await RemoteMedicalRecordRepository(api).entries();
    expect(entries, isNotEmpty);
    expect(entries.every((e) => e.sourceRef.isNotEmpty), isTrue);
    final docs = await RemoteDocumentRepository(api).list();
    expect(docs.length, 4);
    expect(docs.first.isPdf, isTrue);
    expect(docs.map((d) => d.kind), contains(DocumentKind.conclusion));
    final notes = await RemoteNotificationRepository(api).list();
    expect(
      notes.map((n) => n.type),
      containsAll([
        NotificationType.appointmentReminder,
        NotificationType.labReady,
      ]),
    );
    expect(notes.first.params, isNotEmpty);
  });

  test('login stores the tokens and returns the profile', () async {
    final auth = RemoteAuthRepository(api, tokens);
    final profile = await auth.login(
      phone: '700 000 00 01',
      password: 'Demo1234',
    );
    expect(profile.firstName, 'Алексей');
    expect(profile.phone, '+77000000001');
    expect(await tokens.readAccessToken(), isNotEmpty);
    expect(await tokens.readRefreshToken(), isNotEmpty);
    // Subsequent calls are authorized.
    expect((await auth.restoreSession())?.fullName, contains('Петров'));
    final me = adapter.requests.firstWhere(
      (r) => r.uri.path.endsWith('/patients/me'),
    );
    expect(me.headers['Authorization'], startsWith('Bearer '));
    // The login call itself is not authorized with a stale token.
    expect(
      adapter.requests.first.headers.containsKey('Authorization'),
      isFalse,
    );
    await auth.logout();
    expect(await tokens.readAccessToken(), isNull);
  });

  test('API error codes map to typed exceptions', () async {
    await expectLater(
      RemoteAppointmentRepository(api)
          .create(doctorId: '1', start: DateTime(2026, 11, 4, 10), reason: 'x'),
      throwsA(
        isA<BookingException>().having(
          (e) => e.failure,
          'failure',
          BookingFailure.slotTaken,
        ),
      ),
    );
    await expectLater(
      RemoteAppointmentRepository(api).cancel('1'),
      throwsA(
        isA<BookingException>().having(
          (e) => e.failure,
          'failure',
          BookingFailure.tooLateToChange,
        ),
      ),
    );
    await expectLater(
      RemoteAuthRepository(
        api,
        tokens,
      ).confirmPhone(phone: '+77000000001', code: '1234'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.failure,
          'failure',
          AuthFailure.invalidOtp,
        ),
      ),
    );
    await expectLater(
      RemoteDocumentRepository(api).upload(
        fileName: 'a.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
        title: 't',
      ),
      throwsA(
        isA<UploadException>().having(
          (e) => e.failure,
          'failure',
          UploadFailure.unsupportedType,
        ),
      ),
    );
  });

  test('network failures become NetworkException', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))
      ..httpClientAdapter = _Offline();
    final offline = ApiClient(
      config: const AppConfig(apiMode: 'remote'),
      tokens: tokens,
      dio: dio,
    );
    await expectLater(
      RemoteCatalogRepository(offline).doctors(),
      throwsA(isA<NetworkException>()),
    );
  });

  test(
    'an expired access token is refreshed once and the request is retried',
    () async {
      await tokens.saveTokens(access: 'old', refresh: 'refresh-1');
      var calls = 0;
      final dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))
        ..httpClientAdapter = _Sequence((o) {
          if (o.uri.path.endsWith('/auth/refresh')) {
            return (
              200,
              jsonEncode({
                'accessToken': 'new',
                'refreshToken': 'refresh-2',
                'patient': null,
              }),
            );
          }
          calls++;
          return calls == 1
              ? (401, '{"code":"UNAUTHORIZED"}')
              : (200, _fx('doctors'));
        });
      final client = ApiClient(
        config: const AppConfig(apiMode: 'remote'),
        tokens: tokens,
        dio: dio,
      );
      final doctors = await RemoteCatalogRepository(client).doctors();
      expect(doctors.length, 14);
      expect(await tokens.readAccessToken(), 'new');
      expect(await tokens.readRefreshToken(), 'refresh-2');
    },
  );
}

class _Offline implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException.connectionError(
    requestOptions: options,
    reason: 'offline',
  );

  @override
  void close({bool force = false}) {}
}

class _Sequence implements HttpClientAdapter {
  _Sequence(this.handler);
  final (int, String) Function(RequestOptions) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final (status, body) = handler(options);
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
