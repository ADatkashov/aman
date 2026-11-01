import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/l10n/l10n_ext.dart' show NetworkException;
import '../../core/utils/localized_text.dart';
import '../../core/utils/phone.dart';
import '../../features/analyses/domain/lab_repository.dart';
import '../../features/analyses/domain/lab_result.dart';
import '../../features/appointments/domain/appointment.dart';
import '../../features/appointments/domain/appointment_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/domain/patient_profile.dart';
import '../../features/auth/domain/token_storage.dart';
import '../../features/catalog/domain/catalog_repository.dart';
import '../../features/catalog/domain/clinic.dart';
import '../../features/catalog/domain/doctor.dart';
import '../../features/documents/domain/document_repository.dart';
import '../../features/documents/domain/medical_document.dart';
import '../../features/medical_record/domain/medical_entry.dart';
import '../../features/medical_record/domain/medical_record_repository.dart';
import '../../features/notifications/domain/app_notification.dart';
import '../../features/notifications/domain/notification_repository.dart';
import 'api_client.dart';

typedef Json = Map<String, dynamic>;

List<T> _list<T>(Object? data, T Function(Json) parse) =>
    (data as List).map((e) => parse(e as Json)).toList();

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._api, this._tokens);
  final ApiClient _api;
  final TokenStorage _tokens;

  Future<PatientProfile> _storeSession(Json body) async {
    await _tokens.saveTokens(
      access: body['accessToken'] as String,
      refresh: body['refreshToken'] as String?,
    );
    return PatientProfile.fromJson(body['patient'] as Json);
  }

  String _phone(String raw) {
    final n = KzPhone.normalize(raw);
    if (n == null) throw const AuthException(AuthFailure.unknown);
    return n;
  }

  @override
  Future<PatientProfile?> restoreSession() async {
    if (await _tokens.readAccessToken() == null) return null;
    try {
      final res = await _api.run((d) => d.get<Json>('/patients/me'));
      return PatientProfile.fromJson(res.data!);
    } on NetworkException {
      return null; // keep tokens: the user may simply be offline
    } on AuthException {
      await _tokens.clear();
      return null;
    } on DioException {
      await _tokens.clear();
      return null;
    }
  }

  @override
  Future<PatientProfile> login({
    required String phone,
    required String password,
  }) async {
    final res = await _api.run(
      (d) => d.post<Json>(
        '/auth/login',
        data: {'phone': _phone(phone), 'password': password},
      ),
    );
    return _storeSession(res.data!);
  }

  @override
  Future<String?> register({
    required String fullName,
    required String phone,
    required String password,
    required bool consentAccepted,
  }) async {
    final res = await _api.run(
      (d) => d.post<Json>(
        '/auth/register',
        data: {
          'fullName': fullName.trim(),
          'phone': _phone(phone),
          'password': password,
          'consentAccepted': consentAccepted,
        },
      ),
    );
    return res.data?['demoOtp'] as String?;
  }

  @override
  Future<String?> requestOtp(String phone) async {
    final res = await _api.run(
      (d) => d.post<Json>('/auth/otp/request', data: {'phone': _phone(phone)}),
    );
    return res.data?['demoOtp'] as String?;
  }

  @override
  Future<PatientProfile> confirmPhone({
    required String phone,
    required String code,
  }) async {
    final res = await _api.run(
      (d) => d.post<Json>(
        '/auth/otp/verify',
        data: {'phone': _phone(phone), 'code': code},
      ),
    );
    return _storeSession(res.data!);
  }

  @override
  Future<String?> requestPasswordReset(String phone) async {
    final res = await _api.run(
      (d) =>
          d.post<Json>('/auth/password/forgot', data: {'phone': _phone(phone)}),
    );
    return res.data?['demoOtp'] as String?;
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await _api.run(
      (d) => d.post<Json>(
        '/auth/password/reset',
        data: {
          'phone': _phone(phone),
          'code': code,
          'newPassword': newPassword,
        },
      ),
    );
  }

  @override
  Future<PatientProfile> updateProfile(PatientProfile profile) async {
    final res = await _api.run(
      (d) => d.put<Json>('/patients/me', data: profile.toJson()),
    );
    return PatientProfile.fromJson(res.data!);
  }

  @override
  Future<void> logout() async {
    final refresh = await _tokens.readRefreshToken();
    try {
      await _api.run(
        (d) => d.post<Json>('/auth/logout', data: {'refreshToken': refresh}),
      );
    } catch (_) {
      // Local sign-out must always succeed, even when offline.
    } finally {
      await _tokens.clear();
    }
  }
}

class RemoteCatalogRepository implements CatalogRepository {
  RemoteCatalogRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<Doctor>> doctors() async => _list(
    (await _api.run((d) => d.get<List<dynamic>>('/doctors'))).data,
    Doctor.fromJson,
  );

  @override
  Future<Doctor> doctor(String id) async => Doctor.fromJson(
    (await _api.run((d) => d.get<Json>('/doctors/$id'))).data!,
  );

  @override
  Future<List<Clinic>> clinics() async => _list(
    (await _api.run((d) => d.get<List<dynamic>>('/clinics'))).data,
    Clinic.fromJson,
  );

  @override
  Future<Clinic> clinic(String id) async => Clinic.fromJson(
    (await _api.run((d) => d.get<Json>('/clinics/$id'))).data!,
  );

  @override
  Future<List<DoctorReview>> reviews(String doctorId) async => _list(
    (await _api.run((d) => d.get<List<dynamic>>('/doctors/$doctorId/reviews')))
        .data,
    DoctorReview.fromJson,
  );

  @override
  Future<List<TimeSlot>> slots(String doctorId, DateTime date) async {
    final day = date.toIso8601String().substring(0, 10);
    final res = await _api.run(
      (d) => d.get<List<dynamic>>(
        '/doctors/$doctorId/schedule',
        queryParameters: {'date': day},
      ),
    );
    return _list(res.data, TimeSlot.fromJson);
  }

  @override
  Future<DateTime?> nextSlot(String doctorId) async {
    final res = await _api.run(
      (d) => d.get<Json>('/doctors/$doctorId/next-slot'),
    );
    final s = res.data?['start'] as String?;
    return s == null ? null : DateTime.parse(s).toLocal();
  }

  @override
  Future<Set<String>> favorites() async {
    final res = await _api.run(
      (d) => d.get<List<dynamic>>('/patients/me/favorites'),
    );
    return res.data!.map((e) => e.toString()).toSet();
  }

  @override
  Future<Set<String>> toggleFavorite(String doctorId) async {
    final current = await favorites();
    if (current.contains(doctorId)) {
      await _api.run((d) => d.delete<void>('/patients/me/favorites/$doctorId'));
      return current..remove(doctorId);
    }
    await _api.run((d) => d.put<void>('/patients/me/favorites/$doctorId'));
    return current..add(doctorId);
  }
}

class RemoteAppointmentRepository implements AppointmentRepository {
  RemoteAppointmentRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<Appointment>> list() async => _list(
    (await _api.run((d) => d.get<List<dynamic>>('/appointments'))).data,
    Appointment.fromJson,
  );

  @override
  Future<Appointment> get(String id) async => Appointment.fromJson(
    (await _api.run((d) => d.get<Json>('/appointments/$id'))).data!,
  );

  @override
  Future<Appointment> create({
    required String doctorId,
    required DateTime start,
    required String reason,
  }) async {
    final res = await _api.run(
      (d) => d.post<Json>(
        '/appointments',
        data: {
          'doctorId': int.tryParse(doctorId) ?? doctorId,
          'start': start.toUtc().toIso8601String(),
          'reason': reason.trim(),
        },
      ),
    );
    return Appointment.fromJson(res.data!);
  }

  @override
  Future<Appointment> cancel(String id, {String? reason}) async {
    final res = await _api.run(
      (d) =>
          d.patch<Json>('/appointments/$id/cancel', data: {'reason': reason}),
    );
    return Appointment.fromJson(res.data!);
  }

  @override
  Future<Appointment> reschedule(String id, DateTime newStart) async {
    final res = await _api.run(
      (d) => d.patch<Json>(
        '/appointments/$id/reschedule',
        data: {'start': newStart.toUtc().toIso8601String()},
      ),
    );
    return Appointment.fromJson(res.data!);
  }

  @override
  Future<Appointment> review(
    String id, {
    required int rating,
    String? text,
  }) async {
    final res = await _api.run(
      (d) => d.post<Json>(
        '/appointments/$id/review',
        data: {'rating': rating, 'text': text},
      ),
    );
    return Appointment.fromJson(res.data!);
  }
}

class RemoteLabRepository implements LabRepository {
  RemoteLabRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<LabResult>> results() async => _list(
    (await _api.run((d) => d.get<List<dynamic>>('/laboratory/results'))).data,
    LabResult.fromJson,
  );

  @override
  Future<LabResult> result(String id) async => LabResult.fromJson(
    (await _api.run((d) => d.get<Json>('/laboratory/results/$id'))).data!,
  );

  @override
  Future<List<LabOrder>> orders() async {
    final res = await _api.run(
      (d) => d.get<List<dynamic>>('/laboratory/orders'),
    );
    return _list(
      res.data,
      (j) => LabOrder(
        id: j['id'].toString(),
        name: LocalizedText.fromJson(j['name']),
        category: LabCategory.fromId(j['category'] as String),
        doctorName: j['doctorName'] as String,
        date: DateTime.parse(j['date'] as String),
        status: LabStatus.fromId(j['status'] as String),
      ),
    );
  }
}

class RemoteMedicalRecordRepository implements MedicalRecordRepository {
  RemoteMedicalRecordRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<MedicalEntry>> entries() async => _list(
    (await _api.run((d) => d.get<List<dynamic>>('/medical-records'))).data,
    MedicalEntry.fromJson,
  );
}

class RemoteDocumentRepository implements DocumentRepository {
  RemoteDocumentRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<MedicalDocument>> list() async => _list(
    (await _api.run((d) => d.get<List<dynamic>>('/documents'))).data,
    MedicalDocument.fromJson,
  );

  @override
  Future<MedicalDocument> get(String id) async {
    final doc = MedicalDocument.fromJson(
      (await _api.run((d) => d.get<Json>('/documents/$id'))).data!,
    );
    if (!doc.isImage) return doc;
    final bytes = await _api.run(
      (d) => d.get<List<int>>(
        '/documents/$id/content',
        options: Options(responseType: ResponseType.bytes),
      ),
    );
    return MedicalDocument(
      id: doc.id,
      title: doc.title,
      kind: doc.kind,
      fileName: doc.fileName,
      mimeType: doc.mimeType,
      sizeBytes: doc.sizeBytes,
      uploadedAt: doc.uploadedAt,
      uploadedByPatient: doc.uploadedByPatient,
      bytes: Uint8List.fromList(bytes.data!),
    );
  }

  @override
  Future<MedicalDocument> upload({
    required String fileName,
    required Uint8List bytes,
    required String title,
    DocumentKind kind = DocumentKind.other,
  }) async {
    DocumentPolicy.validate(fileName, bytes.length);
    final form = FormData.fromMap({
      'title': title,
      'kind': kind.name,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final res = await _api.run((d) => d.post<Json>('/documents', data: form));
    return MedicalDocument.fromJson(res.data!);
  }

  @override
  Future<void> delete(String id) async =>
      _api.run((d) => d.delete<void>('/documents/$id'));
}

class RemoteNotificationRepository implements NotificationRepository {
  RemoteNotificationRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<AppNotification>> list() async => _list(
    (await _api.run((d) => d.get<List<dynamic>>('/notifications'))).data,
    AppNotification.fromJson,
  );

  @override
  Future<void> markRead(String id) async =>
      _api.run((d) => d.patch<void>('/notifications/$id/read'));

  @override
  Future<void> markAllRead() async =>
      _api.run((d) => d.patch<void>('/notifications/read-all'));

  @override
  Future<void> delete(String id) async =>
      _api.run((d) => d.delete<void>('/notifications/$id'));
}
