import 'dart:typed_data';

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
import '../../core/utils/phone.dart';
import 'demo_catalog_seed.dart';
import 'demo_patient_seed.dart';
import 'demo_store.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this._store, this._tokens);

  final DemoStore _store;
  final TokenStorage _tokens;

  @override
  Future<PatientProfile?> restoreSession() async {
    final token = await _tokens.readAccessToken();
    if (token == null || !token.startsWith('demo-token:')) return null;
    final phone = token.substring('demo-token:'.length);
    final record = _store.accounts[phone];
    if (record == null || !record.verified) {
      await _tokens.clear();
      return null;
    }
    _store.currentPatientId = record.profile.id;
    return record.profile;
  }

  Future<PatientProfile> _signIn(DemoAccountRecord r) async {
    await _tokens.saveTokens(
      access: 'demo-token:${r.profile.phone}',
      refresh: 'demo-refresh',
    );
    _store.currentPatientId = r.profile.id;
    return r.profile;
  }

  @override
  Future<PatientProfile> login({
    required String phone,
    required String password,
  }) async {
    await _store.delay();
    final normalized = KzPhone.normalize(phone);
    final r = normalized == null ? null : _store.accounts[normalized];
    if (r == null || !r.verified) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    if (DemoStore.hashPassword(password, r.salt) != r.passwordHash) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    return _signIn(r);
  }

  @override
  Future<String?> register({
    required String fullName,
    required String phone,
    required String password,
    required bool consentAccepted,
  }) async {
    await _store.delay();
    if (!consentAccepted) {
      throw const AuthException(AuthFailure.consentRequired);
    }
    final normalized = KzPhone.normalize(phone);
    if (normalized == null) throw const AuthException(AuthFailure.unknown);
    final existing = _store.accounts[normalized];
    if (existing != null && existing.verified) {
      throw const AuthException(AuthFailure.phoneTaken);
    }
    final salt = DemoStore.newSalt();
    _store.accounts[normalized] = DemoAccountRecord(
      profile: PatientProfile(
        id: _store.nextId('p'),
        fullName: fullName.trim(),
        phone: normalized,
        avatarSeed: normalized.hashCode.abs() % 200,
      ),
      salt: salt,
      passwordHash: DemoStore.hashPassword(password, salt),
      verified: false,
    );
    return requestOtp(normalized);
  }

  @override
  Future<String?> requestOtp(String phone) async {
    final normalized = KzPhone.normalize(phone);
    if (normalized == null) throw const AuthException(AuthFailure.unknown);
    _store.pendingOtps[normalized] = DemoAccount.otp;
    return DemoAccount.otp;
  }

  @override
  Future<PatientProfile> confirmPhone({
    required String phone,
    required String code,
  }) async {
    await _store.delay();
    final normalized = KzPhone.normalize(phone);
    final r = normalized == null ? null : _store.accounts[normalized];
    if (r == null) throw const AuthException(AuthFailure.accountNotFound);
    if (_store.pendingOtps[normalized] != code) {
      throw const AuthException(AuthFailure.invalidOtp);
    }
    _store.pendingOtps.remove(normalized);
    r.verified = true;
    return _signIn(r);
  }

  @override
  Future<String?> requestPasswordReset(String phone) async {
    await _store.delay();
    final normalized = KzPhone.normalize(phone);
    final r = normalized == null ? null : _store.accounts[normalized];
    if (r == null || !r.verified) {
      throw const AuthException(AuthFailure.accountNotFound);
    }
    return requestOtp(normalized!);
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await _store.delay();
    final normalized = KzPhone.normalize(phone);
    final r = normalized == null ? null : _store.accounts[normalized];
    if (r == null) throw const AuthException(AuthFailure.accountNotFound);
    if (_store.pendingOtps[normalized] != code) {
      throw const AuthException(AuthFailure.invalidOtp);
    }
    _store.pendingOtps.remove(normalized);
    r.passwordHash = DemoStore.hashPassword(newPassword, r.salt);
  }

  @override
  Future<PatientProfile> updateProfile(PatientProfile profile) async {
    await _store.delay();
    final r = _store.accounts[profile.phone];
    if (r == null) throw const AuthException(AuthFailure.accountNotFound);
    r.profile = profile;
    return profile;
  }

  @override
  Future<void> logout() async {
    await _tokens.clear();
    _store.currentPatientId = null;
  }
}

class DemoCatalogRepository implements CatalogRepository {
  DemoCatalogRepository(this._store);
  final DemoStore _store;

  @override
  Future<List<Doctor>> doctors() async {
    await _store.delay();
    return List.unmodifiable(_store.doctors);
  }

  @override
  Future<Doctor> doctor(String id) async {
    await _store.delay();
    return _store.doctorById(id);
  }

  @override
  Future<List<Clinic>> clinics() async {
    await _store.delay();
    return List.unmodifiable(_store.clinics);
  }

  @override
  Future<Clinic> clinic(String id) async {
    await _store.delay();
    return _store.clinicById(id);
  }

  @override
  Future<List<DoctorReview>> reviews(String doctorId) async {
    await _store.delay();
    return demoReviewsFor(_store.doctorById(doctorId), _store.clock());
  }

  @override
  Future<List<TimeSlot>> slots(String doctorId, DateTime date) async {
    await _store.delay();
    return _store.slots(doctorId, date);
  }

  @override
  Future<DateTime?> nextSlot(String doctorId) async =>
      _store.nextSlot(doctorId);

  @override
  Future<Set<String>> favorites() async => {..._store.favorites};

  @override
  Future<Set<String>> toggleFavorite(String doctorId) async {
    if (!_store.favorites.remove(doctorId)) _store.favorites.add(doctorId);
    return {..._store.favorites};
  }
}

class DemoAppointmentRepository implements AppointmentRepository {
  DemoAppointmentRepository(this._store);
  final DemoStore _store;

  @override
  Future<List<Appointment>> list() async {
    await _store.delay();
    return List.unmodifiable(_store.appointments);
  }

  @override
  Future<Appointment> get(String id) async {
    await _store.delay();
    return _store.appointmentById(id);
  }

  @override
  Future<Appointment> create({
    required String doctorId,
    required DateTime start,
    required String reason,
  }) async {
    await _store.delay(); // network latency happens before the atomic check
    return _store.book(doctorId: doctorId, start: start, reason: reason);
  }

  @override
  Future<Appointment> cancel(String id, {String? reason}) async {
    await _store.delay();
    return _store.cancel(id, reason: reason);
  }

  @override
  Future<Appointment> reschedule(String id, DateTime newStart) async {
    await _store.delay();
    return _store.reschedule(id, newStart);
  }

  @override
  Future<Appointment> review(
    String id, {
    required int rating,
    String? text,
  }) async {
    await _store.delay();
    return _store.review(id, rating);
  }
}

class DemoLabRepository implements LabRepository {
  DemoLabRepository(this._store);
  final DemoStore _store;

  @override
  Future<List<LabResult>> results() async {
    await _store.delay();
    final list = [..._store.labs]..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<LabResult> result(String id) async {
    await _store.delay();
    return _store.labs.firstWhere(
      (l) => l.id == id,
      orElse: () => throw const BookingException(BookingFailure.notFound),
    );
  }

  @override
  Future<List<LabOrder>> orders() async {
    await _store.delay();
    return List.unmodifiable(_store.orders);
  }
}

class DemoMedicalRecordRepository implements MedicalRecordRepository {
  DemoMedicalRecordRepository(this._store);
  final DemoStore _store;

  @override
  Future<List<MedicalEntry>> entries() async {
    await _store.delay();
    final list = [..._store.entries]..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}

class DemoDocumentRepository implements DocumentRepository {
  DemoDocumentRepository(this._store);
  final DemoStore _store;

  @override
  Future<List<MedicalDocument>> list() async {
    await _store.delay();
    final list = [..._store.documents]
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return list;
  }

  @override
  Future<MedicalDocument> get(String id) async {
    await _store.delay();
    return _store.documents.firstWhere(
      (d) => d.id == id,
      orElse: () => throw const BookingException(BookingFailure.notFound),
    );
  }

  @override
  Future<MedicalDocument> upload({
    required String fileName,
    required Uint8List bytes,
    required String title,
    DocumentKind kind = DocumentKind.other,
  }) async {
    await _store.delay();
    final mime = DocumentPolicy.validate(fileName, bytes.length);
    final doc = MedicalDocument(
      id: _store.nextId('doc'),
      title: title.trim().isEmpty ? fileName : title.trim(),
      kind: kind,
      fileName: fileName,
      mimeType: mime,
      sizeBytes: bytes.length,
      uploadedAt: _store.clock(),
      bytes: bytes,
      uploadedByPatient: true,
    );
    _store.documents = [doc, ..._store.documents];
    return doc;
  }

  @override
  Future<void> delete(String id) async {
    await _store.delay();
    _store.documents = _store.documents
        .where((d) => d.id != id || !d.uploadedByPatient)
        .toList();
  }
}

class DemoNotificationRepository implements NotificationRepository {
  DemoNotificationRepository(this._store);
  final DemoStore _store;

  @override
  Future<List<AppNotification>> list() async {
    await _store.delay();
    final list = [..._store.notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> markRead(String id) async {
    _store.notifications = [
      for (final n in _store.notifications)
        n.id == id ? n.copyWith(read: true) : n,
    ];
  }

  @override
  Future<void> markAllRead() async {
    _store.notifications = [
      for (final n in _store.notifications) n.copyWith(read: true),
    ];
  }

  @override
  Future<void> delete(String id) async {
    _store.notifications = _store.notifications
        .where((n) => n.id != id)
        .toList();
  }
}
