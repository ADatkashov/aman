import 'patient_profile.dart';

enum AuthFailure {
  invalidCredentials,
  phoneTaken,
  accountNotFound,
  invalidOtp,
  consentRequired,
  network,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.failure);
  final AuthFailure failure;

  @override
  String toString() => 'AuthException(${failure.name})';
}

abstract class AuthRepository {
  /// Restores the session from secure storage; `null` if signed out.
  Future<PatientProfile?> restoreSession();

  Future<PatientProfile> login({
    required String phone,
    required String password,
  });

  /// Creates a pending account and sends an OTP to [phone].
  /// Returns the OTP only in demo mode (so that it can be displayed).
  Future<String?> register({
    required String fullName,
    required String phone,
    required String password,
    required bool consentAccepted,
  });

  /// Sends a fresh one-time code to [phone]. Returns the code in demo mode.
  Future<String?> requestOtp(String phone);

  /// Verifies the OTP of a freshly registered account and signs in.
  Future<PatientProfile> confirmPhone({
    required String phone,
    required String code,
  });

  Future<String?> requestPasswordReset(String phone);

  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });

  Future<PatientProfile> updateProfile(PatientProfile profile);

  Future<void> logout();
}
