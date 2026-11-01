import 'package:aman/core/utils/phone.dart';
import 'package:aman/core/utils/validators.dart';
import 'package:aman/features/documents/domain/medical_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KzPhone', () {
    test('normalizes common formats', () {
      expect(KzPhone.normalize('+7 (700) 123-45-67'), '+77001234567');
      expect(KzPhone.normalize('8 700 123 45 67'), '+77001234567');
      expect(KzPhone.normalize('700 123 45 67'), '+77001234567');
      expect(KzPhone.normalize('77001234567'), '+77001234567');
    });

    test('rejects invalid numbers', () {
      expect(KzPhone.normalize('12345'), isNull);
      expect(KzPhone.normalize('+1 700 123 45 67'), isNull);
      expect(KzPhone.normalize('+7 000 123 45 67'), isNull);
      expect(KzPhone.normalize(''), isNull);
    });

    test('formats and masks', () {
      expect(KzPhone.format('+77001234567'), '+7 700 123 45 67');
      expect(KzPhone.maskNational('7001234567'), '700 123 45 67');
      expect(KzPhone.maskNational('70012'), '700 12');
      expect(KzPhone.nationalDigits('+7 700 123 45 67 999'), '7001234567');
      expect(KzPhone.nationalDigits('7001234567'), '7001234567', reason: 'national numbers may start with 7');
      expect(KzPhone.nationalDigits('87001234567'), '7001234567');
    });
  });

  group('Validators', () {
    test('password needs 8+ chars, a letter and a digit', () {
      expect(Validators.password('short1'), FieldError.weakPassword);
      expect(Validators.password('onlyletters'), FieldError.weakPassword);
      expect(Validators.password('12345678'), FieldError.weakPassword);
      expect(Validators.password('Secret123'), isNull);
      expect(Validators.password('Пароль123'), isNull);
      expect(Validators.password(''), FieldError.required);
    });

    test('full name needs surname and name', () {
      expect(Validators.fullName('Алексей'), FieldError.nameTooShort);
      expect(Validators.fullName('Петров Алексей'), isNull);
      expect(Validators.fullName(' '), FieldError.required);
    });

    test('email is optional but validated when present', () {
      expect(Validators.optionalEmail(''), isNull);
      expect(Validators.optionalEmail('a@b.kz'), isNull);
      expect(Validators.optionalEmail('a@b'), FieldError.invalidEmail);
    });

    test('otp, confirm password and reason', () {
      expect(Validators.otp('1234'), isNull);
      expect(Validators.otp('12a4'), FieldError.invalidOtp);
      expect(Validators.confirmPassword('x', 'y'), FieldError.passwordMismatch);
      expect(Validators.confirmPassword('x', 'x'), isNull);
      expect(Validators.reason('ab'), FieldError.reasonTooShort);
      expect(Validators.reason('Боль в спине'), isNull);
    });
  });

  group('DocumentPolicy', () {
    test('accepts PDF/JPG/PNG within 10 MB', () {
      expect(DocumentPolicy.validate('a.PDF', 100), 'application/pdf');
      expect(DocumentPolicy.validate('a.jpeg', 100), 'image/jpeg');
      expect(DocumentPolicy.validate('a.png', DocumentPolicy.maxBytes), 'image/png');
    });

    test('rejects empty, oversized and unsupported files', () {
      expect(() => DocumentPolicy.validate('a.pdf', 0), throwsA(isA<UploadException>().having((e) => e.failure, 'f', UploadFailure.empty)));
      expect(() => DocumentPolicy.validate('a.pdf', DocumentPolicy.maxBytes + 1),
          throwsA(isA<UploadException>().having((e) => e.failure, 'f', UploadFailure.tooLarge)));
      expect(() => DocumentPolicy.validate('virus.exe', 10),
          throwsA(isA<UploadException>().having((e) => e.failure, 'f', UploadFailure.unsupportedType)));
      expect(() => DocumentPolicy.validate('noext', 10), throwsA(isA<UploadException>()));
    });
  });
}
