// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AMAN';

  @override
  String get tagline => 'Your Health. Your Life.';

  @override
  String get demoBadge => 'DEMO';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get continueAction => 'Continue';

  @override
  String get retry => 'Try again';

  @override
  String get done => 'Done';

  @override
  String get search => 'Search';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get all => 'All';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get details => 'Details';

  @override
  String get seeAll => 'See all';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get skip => 'Skip';

  @override
  String get finish => 'Finish';

  @override
  String get submit => 'Submit';

  @override
  String get call => 'Call';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'No connection to the server. Check your internet and try again.';

  @override
  String get navHome => 'Home';

  @override
  String get navAppointments => 'Visits';

  @override
  String get navServices => 'Services';

  @override
  String get navProfile => 'Profile';

  @override
  String get welcomeTitle => 'Health care,\nright at hand';

  @override
  String get welcomeSubtitle =>
      'Doctors, appointments, lab results and your medical history in one secure app.';

  @override
  String get onb1Title => 'Find the right doctor';

  @override
  String get onb1Body =>
      'Compare ratings, experience and prices of specialists from partner clinics.';

  @override
  String get onb2Title => 'Book in a few taps';

  @override
  String get onb2Body =>
      'Choose a free time slot, confirm the visit and get a reminder.';

  @override
  String get onb3Title => 'Your health data, protected';

  @override
  String get onb3Body =>
      'Lab results, documents and records are stored securely and shown only to you.';

  @override
  String get getStarted => 'Get started';

  @override
  String get haveAccount => 'I already have an account';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '700 123 45 67';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Repeat password';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Surname Name Patronymic';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailOptionalLabel => 'Email (optional)';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in with your phone number and password.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle =>
      'We will send a confirmation code to your phone.';

  @override
  String get consentText =>
      'I agree to the processing of my personal and medical data';

  @override
  String get consentNote =>
      'Data is processed only to provide the service and is never shared without your permission.';

  @override
  String get otpTitle => 'Confirm your phone';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 4-digit code sent to $phone';
  }

  @override
  String otpDemoHint(String code) {
    return 'DEMO mode: your code is $code';
  }

  @override
  String get otpLabel => 'Code';

  @override
  String get resendCode => 'Resend code';

  @override
  String get codeResent => 'A new code has been sent';

  @override
  String get verify => 'Verify';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetSubtitle =>
      'Enter your phone number — we will send a confirmation code.';

  @override
  String get sendCode => 'Send code';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get resetButton => 'Save new password';

  @override
  String get passwordResetDone => 'Password updated. You can sign in now.';

  @override
  String get profileSetupTitle => 'Tell us about yourself';

  @override
  String get profileSetupSubtitle =>
      'This helps doctors prepare for your visit. You can change it later.';

  @override
  String get birthDateLabel => 'Date of birth';

  @override
  String get genderLabel => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get cityLabel => 'City';

  @override
  String get bloodTypeLabel => 'Blood type';

  @override
  String demoAccountHint(String password, String phone) {
    return 'DEMO account: $phone / $password';
  }

  @override
  String get useDemoAccount => 'Fill in demo account';

  @override
  String get errRequired => 'This field is required';

  @override
  String get errPhone => 'Enter a valid +7 phone number';

  @override
  String get errPassword => 'At least 8 characters, a letter and a digit';

  @override
  String get errEmail => 'Enter a valid email';

  @override
  String get errOtp => 'Enter the 4-digit code';

  @override
  String get errName => 'Enter surname and name';

  @override
  String get errMismatch => 'Passwords don\'t match';

  @override
  String get errReason => 'Describe the reason (at least 3 characters)';

  @override
  String get errDate => 'Choose a valid date';

  @override
  String get errInvalidCredentials => 'Wrong phone number or password';

  @override
  String get errPhoneTaken => 'This phone number is already registered';

  @override
  String get errAccountNotFound => 'Account not found';

  @override
  String get errInvalidOtp => 'Wrong confirmation code';

  @override
  String get errConsent => 'Consent to data processing is required';

  @override
  String greeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get nextAppointment => 'Next appointment';

  @override
  String get noAppointmentsTitle => 'No upcoming visits';

  @override
  String get noAppointmentsBody =>
      'Book a visit to a doctor in a couple of taps.';

  @override
  String get bookDoctor => 'Book a doctor';

  @override
  String get quickServices => 'Quick services';

  @override
  String get qsBook => 'Book\nvisit';

  @override
  String get qsAnalyses => 'Lab\ntests';

  @override
  String get qsRecord => 'Medical\nrecord';

  @override
  String get qsDocuments => 'My\ndocuments';

  @override
  String get qsClinics => 'Find\nclinics';

  @override
  String get qsTelemedicine => 'Telemedicine';

  @override
  String get popularDoctors => 'Popular doctors';

  @override
  String get popularSpecialties => 'Popular specialties';

  @override
  String get myResults => 'My results';

  @override
  String get careTitle => 'Health care';

  @override
  String get careTip1Title => 'Annual check-up';

  @override
  String get careTip1Body =>
      'A routine check-up with a GP once a year helps notice changes early.';

  @override
  String get careTip2Title => 'Drink water';

  @override
  String get careTip2Body => 'Keep a bottle of water at hand during the day.';

  @override
  String get careTip3Title => 'Vaccination reminder';

  @override
  String get careTip3Body =>
      'Check your vaccination schedule with your doctor.';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String inTimeDays(int days) {
    return 'in $days d.';
  }

  @override
  String get openNotifications => 'Notifications';

  @override
  String get spTherapist => 'Therapist';

  @override
  String get spCardiologist => 'Cardiologist';

  @override
  String get spNeurologist => 'Neurologist';

  @override
  String get spPediatrician => 'Pediatrician';

  @override
  String get spDentist => 'Dentist';

  @override
  String get spDermatologist => 'Dermatologist';

  @override
  String get spOphthalmologist => 'Ophthalmologist';

  @override
  String get spEndocrinologist => 'Endocrinologist';

  @override
  String get doctorsTitle => 'Doctors';

  @override
  String get searchDoctorsHint => 'Search by name or specialty';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get sortTitle => 'Sort by';

  @override
  String get sortPopularity => 'Popularity';

  @override
  String get sortRating => 'Rating';

  @override
  String get sortPriceAsc => 'Price: low to high';

  @override
  String get sortPriceDesc => 'Price: high to low';

  @override
  String get sortExperience => 'Experience';

  @override
  String get filterClinic => 'Clinic';

  @override
  String get filterRating => 'Minimum rating';

  @override
  String get filterPrice => 'Maximum price';

  @override
  String get filterExperience => 'Minimum experience';

  @override
  String get anyOption => 'Any';

  @override
  String get favoritesOnly => 'Favorites only';

  @override
  String get noDoctorsTitle => 'No doctors found';

  @override
  String get noDoctorsBody => 'Try changing the search or filters.';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String experienceYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '$count year',
    );
    return '$_temp0 of experience';
  }

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '$count review',
    );
    return '$_temp0';
  }

  @override
  String get consultationPrice => 'Consultation';

  @override
  String nearestSlot(String when) {
    return 'Nearest: $when';
  }

  @override
  String get noSlotsSoon => 'No free slots soon';

  @override
  String get bookButton => 'Book';

  @override
  String get doctorAbout => 'About the doctor';

  @override
  String get doctorEducation => 'Education';

  @override
  String get doctorQualification => 'Qualification';

  @override
  String get doctorLanguages => 'Languages';

  @override
  String get doctorServices => 'Services';

  @override
  String get doctorWorkplace => 'Place of work';

  @override
  String get doctorReviews => 'Patient reviews';

  @override
  String get doctorSchedule => 'Available time';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get favoriteAdded => 'Added to favorites';

  @override
  String get favoriteRemoved => 'Removed from favorites';

  @override
  String get favoritesTitle => 'Favorite doctors';

  @override
  String get noFavoritesTitle => 'No favorite doctors yet';

  @override
  String get noFavoritesBody =>
      'Tap the heart on a doctor profile to save them here.';

  @override
  String get langName_kk => 'Kazakh';

  @override
  String get langName_ru => 'Russian';

  @override
  String get langName_en => 'English';

  @override
  String get verifiedDemoNote => 'Demo profile — fictional person';

  @override
  String get bookingTitle => 'Book a visit';

  @override
  String get stepSpecialty => 'Specialty';

  @override
  String get stepDoctor => 'Doctor';

  @override
  String get stepClinic => 'Clinic';

  @override
  String get stepDate => 'Date';

  @override
  String get stepTime => 'Time';

  @override
  String get stepReason => 'Reason';

  @override
  String get stepConfirm => 'Confirmation';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get chooseSpecialty => 'Choose a specialty';

  @override
  String get chooseDoctor => 'Choose a doctor';

  @override
  String get chooseClinic => 'Clinic of the visit';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get chooseTime => 'Choose a time';

  @override
  String get availableTime => 'Available time';

  @override
  String get noSlotsOnDay => 'No free slots on this day';

  @override
  String get reasonLabel => 'Reason for the visit';

  @override
  String get reasonHint => 'Briefly describe your symptoms or goal';

  @override
  String get reasonChipCheckup => 'Check-up';

  @override
  String get reasonChipConsult => 'Consultation';

  @override
  String get reasonChipFollowUp => 'Follow-up';

  @override
  String get reasonChipResults => 'Discuss test results';

  @override
  String get bookingSummary => 'Visit summary';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String get priceLabel => 'Price';

  @override
  String get payAtClinicNote =>
      'Payment is made at the clinic after the visit.';

  @override
  String get bookingSuccessTitle => 'You are booked!';

  @override
  String get bookingSuccessBody => 'We will remind you before the visit.';

  @override
  String get bookingNumber => 'Booking number';

  @override
  String get addToCalendar => 'Add to calendar';

  @override
  String get calendarOpenFailed => 'Could not open the calendar';

  @override
  String get goToAppointments => 'My appointments';

  @override
  String get backHome => 'Back to home';

  @override
  String get errSlotTaken =>
      'This time was just booked by someone else. Please choose another slot.';

  @override
  String get errSlotPast => 'This time is no longer available.';

  @override
  String get errOutsideSchedule =>
      'This time is outside the doctor\'s schedule.';

  @override
  String get errBookingGeneric => 'Could not complete the booking';

  @override
  String errTooLate(int hours) {
    return 'Changes are possible no later than $hours h before the visit.';
  }

  @override
  String get errNotFound => 'Not found';

  @override
  String get errAlreadyReviewed => 'You have already reviewed this visit';

  @override
  String get errNotCompleted => 'A review is possible after the visit';

  @override
  String get noDoctorsForSpecialty => 'No doctors for this specialty yet';

  @override
  String get appointmentsTitle => 'My appointments';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabCompleted => 'Completed';

  @override
  String get tabCancelled => 'Cancelled';

  @override
  String get periodAll => 'All time';

  @override
  String get period30 => '30 days';

  @override
  String get period90 => '3 months';

  @override
  String get period365 => 'Year';

  @override
  String get noUpcomingTitle => 'No upcoming visits';

  @override
  String get noCompletedTitle => 'No completed visits';

  @override
  String get noCancelledTitle => 'No cancelled visits';

  @override
  String get noAppointmentsInPeriod => 'Nothing for the selected period.';

  @override
  String get appointmentDetails => 'Appointment';

  @override
  String get cancelAppointment => 'Cancel appointment';

  @override
  String get rescheduleAppointment => 'Reschedule';

  @override
  String get repeatAppointment => 'Book again';

  @override
  String get leaveReview => 'Leave a review';

  @override
  String get cancelConfirmTitle => 'Cancel this appointment?';

  @override
  String get cancelConfirmBody =>
      'The time slot will be released for other patients.';

  @override
  String get cancelReasonHint => 'Reason (optional)';

  @override
  String get keepAppointment => 'Keep it';

  @override
  String get appointmentCancelledSnack => 'Appointment cancelled';

  @override
  String get appointmentRescheduledSnack => 'Appointment rescheduled';

  @override
  String get rescheduleTitle => 'Choose a new time';

  @override
  String get rescheduleConfirm => 'Confirm new time';

  @override
  String changePolicy(int hours) {
    return 'Free changes up to $hours h before the visit';
  }

  @override
  String get reviewTitle => 'How was your visit?';

  @override
  String get reviewCommentHint => 'Comment (optional)';

  @override
  String get reviewThanks => 'Thank you for your review!';

  @override
  String yourRating(String value) {
    return 'Your rating: $value';
  }

  @override
  String get doctorLabel => 'Doctor';

  @override
  String get clinicLabel => 'Clinic';

  @override
  String get dateTimeLabel => 'Date and time';

  @override
  String get statusLabel => 'Status';

  @override
  String get cancelledReasonLabel => 'Cancellation reason';

  @override
  String get analysesTitle => 'Tests & studies';

  @override
  String get tabMyAnalyses => 'My tests';

  @override
  String get tabOrders => 'Prescribed';

  @override
  String get catAll => 'All';

  @override
  String get catCbc => 'Blood count';

  @override
  String get catBiochemistry => 'Biochemistry';

  @override
  String get catUrine => 'Urine';

  @override
  String get catHormones => 'Hormones';

  @override
  String get catVitamins => 'Vitamins';

  @override
  String get catImmunology => 'Immunology';

  @override
  String get catPcr => 'PCR';

  @override
  String get catOther => 'Other';

  @override
  String get labPending => 'Pending';

  @override
  String get labProcessing => 'Processing';

  @override
  String get labReady => 'Ready';

  @override
  String get labAttention => 'Needs attention';

  @override
  String get labNoAnalyses => 'No tests yet';

  @override
  String get labNoAnalysesBody =>
      'Your results will appear here as soon as the laboratory publishes them.';

  @override
  String get labNoOrders => 'No prescribed tests';

  @override
  String get labResultTitle => 'Result';

  @override
  String get labIndicator => 'Indicator';

  @override
  String get labReference => 'Reference range';

  @override
  String labRefRange(String max, String min) {
    return '$min – $max';
  }

  @override
  String labRefLess(String max) {
    return 'up to $max';
  }

  @override
  String labRefMore(String min) {
    return 'from $min';
  }

  @override
  String get labOutOfRange => 'Outside the laboratory reference range';

  @override
  String get labInRange => 'Within the reference range';

  @override
  String get labLaboratory => 'Laboratory';

  @override
  String get labDate => 'Date';

  @override
  String get labDynamics => 'Dynamics';

  @override
  String labDynamicsFor(String name) {
    return 'Trend: $name';
  }

  @override
  String get labDisclaimer =>
      'Values are compared with the reference ranges provided by the laboratory. AMAN does not diagnose — please discuss results with your doctor.';

  @override
  String get labResultPending =>
      'The result is not ready yet. We will notify you when it is published.';

  @override
  String labPrescribedBy(String doctor) {
    return 'Prescribed by $doctor';
  }

  @override
  String get labOpenDocument => 'Open document';

  @override
  String labTestCount(int count) {
    return '$count indicators';
  }

  @override
  String get recordTitle => 'Medical record';

  @override
  String get recGeneral => 'General';

  @override
  String get recVisits => 'Visits';

  @override
  String get recDiagnoses => 'Diagnoses';

  @override
  String get recPrescriptions => 'Prescriptions';

  @override
  String get recAllergies => 'Allergies';

  @override
  String get recChronic => 'Chronic conditions';

  @override
  String get recPast => 'Past illnesses';

  @override
  String get recProcedures => 'Procedures';

  @override
  String get recVaccinations => 'Vaccinations';

  @override
  String get recLabs => 'Laboratory studies';

  @override
  String get recDocuments => 'Documents';

  @override
  String get recAge => 'Age';

  @override
  String recAgeValue(int years) {
    return '$years y.o.';
  }

  @override
  String recConfirmedBy(String ref) {
    return 'Confirmed by: $ref';
  }

  @override
  String get recEmpty => 'No entries yet';

  @override
  String get recDisclaimer =>
      'Only information confirmed by doctors or documents is shown. AMAN does not create medical records on its own.';

  @override
  String get recFilterDates => 'Filter by dates';

  @override
  String get recDateFrom => 'From';

  @override
  String get recDateTo => 'To';

  @override
  String get recTimeline => 'Timeline';

  @override
  String get documentsTitle => 'My documents';

  @override
  String get uploadDocument => 'Upload document';

  @override
  String get docTitleLabel => 'Document title';

  @override
  String get docKindLabel => 'Document type';

  @override
  String get docKindLab => 'Lab report';

  @override
  String get docKindPrescription => 'Prescription';

  @override
  String get docKindConclusion => 'Conclusion';

  @override
  String get docKindReferral => 'Referral';

  @override
  String get docKindOther => 'Other';

  @override
  String get pickFile => 'Choose a file (PDF, JPG, PNG)';

  @override
  String get uploadHint => 'Up to 10 MB. Files are checked before upload.';

  @override
  String get uploadSuccess => 'Document uploaded';

  @override
  String get deleteDocument => 'Delete document';

  @override
  String get deleteDocumentConfirm =>
      'Delete this document? This cannot be undone.';

  @override
  String get documentDeleted => 'Document deleted';

  @override
  String get errUploadEmpty => 'The file is empty';

  @override
  String get errUploadLarge => 'The file is larger than 10 MB';

  @override
  String get errUploadType => 'Only PDF, JPG and PNG files are allowed';

  @override
  String get noDocumentsTitle => 'No documents';

  @override
  String get noDocumentsBody =>
      'Upload results, prescriptions or conclusions to keep them in one place.';

  @override
  String get docPdfNotice =>
      'PDF file saved securely. Open it with a PDF viewer after downloading.';

  @override
  String get docDemoNotice => 'Demo document with synthetic content';

  @override
  String get docUploadedBy => 'Uploaded by you';

  @override
  String get docUploadedByClinic => 'From clinic';

  @override
  String get clinicsTitle => 'Clinics';

  @override
  String get searchClinicsHint => 'Search clinic or address';

  @override
  String get mapView => 'Map';

  @override
  String get listView => 'List';

  @override
  String get clinicHours => 'Working hours';

  @override
  String get clinicContacts => 'Contacts';

  @override
  String get buildRoute => 'Get directions';

  @override
  String get clinicDoctors => 'Doctors';

  @override
  String get clinicServices => 'Services & prices';

  @override
  String get noClinicsTitle => 'No clinics found';

  @override
  String get mapDemoNote =>
      'Demo map. Connect a map provider key to enable the live map.';

  @override
  String get routeOpenFailed => 'Could not open the maps app';

  @override
  String clinicsCount(int count) {
    return '$count clinics';
  }

  @override
  String get callFailed => 'Could not start the call';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get personalData => 'Personal data';

  @override
  String get appointmentHistory => 'Appointment history';

  @override
  String get medicalRecordMenu => 'Medical record';

  @override
  String get myAnalyses => 'My tests';

  @override
  String get myDocuments => 'My documents';

  @override
  String get favoriteDoctors => 'Favorite doctors';

  @override
  String get notificationsMenu => 'Notifications';

  @override
  String get settingsMenu => 'Settings';

  @override
  String get languageMenu => 'App language';

  @override
  String get securityMenu => 'Security';

  @override
  String get helpMenu => 'Help & support';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirmTitle => 'Sign out of AMAN?';

  @override
  String get logoutConfirmBody =>
      'You will need to sign in again to see your data.';

  @override
  String get statAppointments => 'Visits';

  @override
  String get statAnalyses => 'Tests';

  @override
  String get statDocuments => 'Documents';

  @override
  String get statFavorites => 'Favorites';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get securityTokensTitle => 'Secure session';

  @override
  String get securityTokensBody =>
      'Access tokens are kept in the device secure storage. Passwords are never stored on the device.';

  @override
  String get securityConsentTitle => 'Data processing consent';

  @override
  String get securityConsentBody =>
      'You agreed to the processing of personal and medical data when creating the account.';

  @override
  String get changePassword => 'Change password';

  @override
  String get helpFaqTitle => 'Frequently asked questions';

  @override
  String get faq1Q => 'How do I cancel or reschedule a visit?';

  @override
  String get faq1A =>
      'Open the visit in “Visits” and choose the action. Changes are allowed until the deadline set by the clinic.';

  @override
  String get faq2Q => 'Where do my results come from?';

  @override
  String get faq2A =>
      'Results and records are provided by clinics and laboratories. The app never interprets them on its own.';

  @override
  String get faq3Q => 'Is my data protected?';

  @override
  String get faq3A =>
      'Data is transferred over HTTPS and access to every record is checked and audited.';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get supportEmail => 'support@aman.example';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get demoModeNote =>
      'Demo mode: all data is synthetic and stored only in the app memory.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get noNotificationsTitle => 'No notifications';

  @override
  String get noNotificationsBody =>
      'Reminders and updates about your visits will appear here.';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get undo => 'Undo';

  @override
  String get ntCreatedTitle => 'Appointment created';

  @override
  String ntCreatedBody(String doctor, String when) {
    return '$doctor, $when';
  }

  @override
  String get ntReminderTitle => 'Visit reminder';

  @override
  String ntReminderBody(String doctor, String when) {
    return '$doctor — $when';
  }

  @override
  String get ntRescheduledTitle => 'Appointment rescheduled';

  @override
  String ntRescheduledBody(String doctor, String when) {
    return '$doctor, new time: $when';
  }

  @override
  String get ntCancelledTitle => 'Appointment cancelled';

  @override
  String ntCancelledBody(String doctor, String when) {
    return '$doctor, $when';
  }

  @override
  String get ntLabReadyTitle => 'Test results are ready';

  @override
  String get ntLabReadyBody => 'Open the app to see the results.';

  @override
  String get ntPrescriptionTitle => 'New prescription';

  @override
  String ntPrescriptionBody(String doctor) {
    return '$doctor added a prescription to your record.';
  }

  @override
  String get ntScheduleTitle => 'Doctor schedule changed';

  @override
  String ntScheduleBody(String doctor) {
    return '$doctor updated the working hours.';
  }

  @override
  String get servicesTitle => 'Services';

  @override
  String get servicesSubtitle => 'Everything for your health in one place';

  @override
  String get svcDoctorsDesc => 'Catalog of specialists';

  @override
  String get svcBookDesc => 'Book in a few steps';

  @override
  String get svcAnalysesDesc => 'Results and trends';

  @override
  String get svcRecordDesc => 'Your history in one place';

  @override
  String get svcDocumentsDesc => 'Files and conclusions';

  @override
  String get svcClinicsDesc => 'Map and directions';

  @override
  String get telemedTitle => 'Telemedicine is on the way';

  @override
  String get telemedBody =>
      'Video consultations are planned for a future release. For now you can book an in-clinic visit.';

  @override
  String get comingSoon => 'Soon';

  @override
  String get statExperience => 'Experience';

  @override
  String yearsShort(int count) {
    return '$count y.';
  }

  @override
  String routeSummary(String clinic) {
    return 'Route to $clinic';
  }

  @override
  String get selectedLabel => 'Selected';

  @override
  String get weekSelectHint => 'Pick a day';

  @override
  String get bookingCancelTitle => 'Leave booking?';

  @override
  String get bookingCancelBody => 'Your choices will not be saved.';

  @override
  String get leave => 'Leave';

  @override
  String get appointmentPrice => 'Price at the clinic';

  @override
  String get viewDoctor => 'Doctor profile';

  @override
  String get showOnMap => 'Show on map';

  @override
  String get searchNothing => 'Nothing found';

  @override
  String get reviewSubmitted => 'Review submitted';

  @override
  String get rateStars => 'Tap a star to rate';

  @override
  String get medRecordOpen => 'Open medical record';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get profileStatsTitle => 'Overview';

  @override
  String get themeTitle => 'Theme';

  @override
  String get languageSaved => 'Language changed';

  @override
  String get deleteNotification => 'Delete notification';
}
