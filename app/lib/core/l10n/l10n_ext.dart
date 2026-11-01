import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analyses/domain/lab_result.dart';
import '../../features/appointments/domain/appointment.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/catalog/domain/specialty.dart';
import '../../features/documents/domain/medical_document.dart';
import '../../features/medical_record/domain/medical_entry.dart';
import '../../l10n/app_localizations.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';

export '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppL10n get l10n => AppL10n.of(this);

  /// Locale-aware formatters for money / dates.
  AmanFormat get fmt => AmanFormat(Localizations.localeOf(this).toLanguageTag());

  String get langCode => Localizations.localeOf(this).languageCode;
}

/// Convenience provider so non-widget code can obtain formatters.
final formatProvider = Provider.family<AmanFormat, String>((ref, locale) => AmanFormat(locale));

extension SpecialtyL10n on Specialty {
  String label(AppL10n l) => switch (this) {
        Specialty.therapist => l.spTherapist,
        Specialty.cardiologist => l.spCardiologist,
        Specialty.neurologist => l.spNeurologist,
        Specialty.pediatrician => l.spPediatrician,
        Specialty.dentist => l.spDentist,
        Specialty.dermatologist => l.spDermatologist,
        Specialty.ophthalmologist => l.spOphthalmologist,
        Specialty.endocrinologist => l.spEndocrinologist,
      };
}

extension AppointmentStatusL10n on AppointmentStatus {
  String label(AppL10n l) => switch (this) {
        AppointmentStatus.confirmed => l.statusConfirmed,
        AppointmentStatus.completed => l.statusCompleted,
        AppointmentStatus.cancelled => l.statusCancelled,
      };
}

extension LabCategoryL10n on LabCategory {
  String label(AppL10n l) => switch (this) {
        LabCategory.cbc => l.catCbc,
        LabCategory.biochemistry => l.catBiochemistry,
        LabCategory.urine => l.catUrine,
        LabCategory.hormones => l.catHormones,
        LabCategory.vitamins => l.catVitamins,
        LabCategory.immunology => l.catImmunology,
        LabCategory.pcr => l.catPcr,
        LabCategory.other => l.catOther,
      };
}

extension LabStatusL10n on LabStatus {
  String label(AppL10n l) => switch (this) {
        LabStatus.pending => l.labPending,
        LabStatus.processing => l.labProcessing,
        LabStatus.ready => l.labReady,
        LabStatus.attention => l.labAttention,
      };
}

extension MedicalEntryTypeL10n on MedicalEntryType {
  String label(AppL10n l) => switch (this) {
        MedicalEntryType.visit => l.recVisits,
        MedicalEntryType.diagnosis => l.recDiagnoses,
        MedicalEntryType.prescription => l.recPrescriptions,
        MedicalEntryType.allergy => l.recAllergies,
        MedicalEntryType.chronic => l.recChronic,
        MedicalEntryType.pastIllness => l.recPast,
        MedicalEntryType.procedure => l.recProcedures,
        MedicalEntryType.vaccination => l.recVaccinations,
        MedicalEntryType.lab => l.recLabs,
        MedicalEntryType.document => l.recDocuments,
      };
}

extension DocumentKindL10n on DocumentKind {
  String label(AppL10n l) => switch (this) {
        DocumentKind.labReport => l.docKindLab,
        DocumentKind.prescription => l.docKindPrescription,
        DocumentKind.conclusion => l.docKindConclusion,
        DocumentKind.referral => l.docKindReferral,
        DocumentKind.other => l.docKindOther,
      };
}

extension FieldErrorL10n on FieldError {
  String message(AppL10n l) => switch (this) {
        FieldError.required => l.errRequired,
        FieldError.invalidPhone => l.errPhone,
        FieldError.weakPassword => l.errPassword,
        FieldError.invalidEmail => l.errEmail,
        FieldError.invalidOtp => l.errOtp,
        FieldError.nameTooShort => l.errName,
        FieldError.passwordMismatch => l.errMismatch,
        FieldError.invalidDate => l.errDate,
        FieldError.reasonTooShort => l.errReason,
      };
}

/// Maps any thrown error to a user-facing localized message.
/// Technical details never reach the UI (and never contain medical data).
String errorMessage(AppL10n l, Object error, {int changeHours = 2}) {
  if (error is BookingException) {
    return switch (error.failure) {
      BookingFailure.slotTaken => l.errSlotTaken,
      BookingFailure.slotInPast => l.errSlotPast,
      BookingFailure.outsideSchedule => l.errOutsideSchedule,
      BookingFailure.tooLateToChange => l.errTooLate(changeHours),
      BookingFailure.notFound => l.errNotFound,
      BookingFailure.reasonRequired => l.errReason,
      BookingFailure.alreadyReviewed => l.errAlreadyReviewed,
      BookingFailure.notCompleted => l.errNotCompleted,
    };
  }
  if (error is AuthException) {
    return switch (error.failure) {
      AuthFailure.invalidCredentials => l.errInvalidCredentials,
      AuthFailure.phoneTaken => l.errPhoneTaken,
      AuthFailure.accountNotFound => l.errAccountNotFound,
      AuthFailure.invalidOtp => l.errInvalidOtp,
      AuthFailure.consentRequired => l.errConsent,
      AuthFailure.network => l.errorNetwork,
      AuthFailure.unknown => l.errorGeneric,
    };
  }
  if (error is UploadException) {
    return switch (error.failure) {
      UploadFailure.empty => l.errUploadEmpty,
      UploadFailure.tooLarge => l.errUploadLarge,
      UploadFailure.unsupportedType => l.errUploadType,
    };
  }
  if (error is NetworkException) return l.errorNetwork;
  return l.errorGeneric;
}

/// Raised by the HTTP layer when the server cannot be reached.
class NetworkException implements Exception {
  const NetworkException();
}
