import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AMAN'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your Health. Your Life.'**
  String get tagline;

  /// No description provided for @demoBadge.
  ///
  /// In en, this message translates to:
  /// **'DEMO'**
  String get demoBadge;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. Check your internet and try again.'**
  String get errorNetwork;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get navAppointments;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Health care,\nright at hand'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Doctors, appointments, lab results and your medical history in one secure app.'**
  String get welcomeSubtitle;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'Find the right doctor'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'Compare ratings, experience and prices of specialists from partner clinics.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Book in a few taps'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'Choose a free time slot, confirm the visit and get a reminder.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Your health data, protected'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'Lab results, documents and records are stored securely and shown only to you.'**
  String get onb3Body;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'700 123 45 67'**
  String get phoneHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get confirmPasswordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Surname Name Patronymic'**
  String get fullNameHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptionalLabel;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone number and password.'**
  String get loginSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send a confirmation code to your phone.'**
  String get registerSubtitle;

  /// No description provided for @consentText.
  ///
  /// In en, this message translates to:
  /// **'I agree to the processing of my personal and medical data'**
  String get consentText;

  /// No description provided for @consentNote.
  ///
  /// In en, this message translates to:
  /// **'Data is processed only to provide the service and is never shared without your permission.'**
  String get consentNote;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your phone'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpDemoHint.
  ///
  /// In en, this message translates to:
  /// **'DEMO mode: your code is {code}'**
  String otpDemoHint(String code);

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get otpLabel;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent'**
  String get codeResent;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number — we will send a confirmation code.'**
  String get resetSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Save new password'**
  String get resetButton;

  /// No description provided for @passwordResetDone.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You can sign in now.'**
  String get passwordResetDone;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps doctors prepare for your visit. You can change it later.'**
  String get profileSetupSubtitle;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDateLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @bloodTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Blood type'**
  String get bloodTypeLabel;

  /// No description provided for @demoAccountHint.
  ///
  /// In en, this message translates to:
  /// **'DEMO account: {phone} / {password}'**
  String demoAccountHint(String password, String phone);

  /// No description provided for @useDemoAccount.
  ///
  /// In en, this message translates to:
  /// **'Fill in demo account'**
  String get useDemoAccount;

  /// No description provided for @errRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errRequired;

  /// No description provided for @errPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid +7 phone number'**
  String get errPhone;

  /// No description provided for @errPassword.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, a letter and a digit'**
  String get errPassword;

  /// No description provided for @errEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get errEmail;

  /// No description provided for @errOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code'**
  String get errOtp;

  /// No description provided for @errName.
  ///
  /// In en, this message translates to:
  /// **'Enter surname and name'**
  String get errName;

  /// No description provided for @errMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get errMismatch;

  /// No description provided for @errReason.
  ///
  /// In en, this message translates to:
  /// **'Describe the reason (at least 3 characters)'**
  String get errReason;

  /// No description provided for @errDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid date'**
  String get errDate;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong phone number or password'**
  String get errInvalidCredentials;

  /// No description provided for @errPhoneTaken.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered'**
  String get errPhoneTaken;

  /// No description provided for @errAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get errAccountNotFound;

  /// No description provided for @errInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Wrong confirmation code'**
  String get errInvalidOtp;

  /// No description provided for @errConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent to data processing is required'**
  String get errConsent;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String greeting(String name);

  /// No description provided for @nextAppointment.
  ///
  /// In en, this message translates to:
  /// **'Next appointment'**
  String get nextAppointment;

  /// No description provided for @noAppointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming visits'**
  String get noAppointmentsTitle;

  /// No description provided for @noAppointmentsBody.
  ///
  /// In en, this message translates to:
  /// **'Book a visit to a doctor in a couple of taps.'**
  String get noAppointmentsBody;

  /// No description provided for @bookDoctor.
  ///
  /// In en, this message translates to:
  /// **'Book a doctor'**
  String get bookDoctor;

  /// No description provided for @quickServices.
  ///
  /// In en, this message translates to:
  /// **'Quick services'**
  String get quickServices;

  /// No description provided for @qsBook.
  ///
  /// In en, this message translates to:
  /// **'Book\nvisit'**
  String get qsBook;

  /// No description provided for @qsAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Lab\ntests'**
  String get qsAnalyses;

  /// No description provided for @qsRecord.
  ///
  /// In en, this message translates to:
  /// **'Medical\nrecord'**
  String get qsRecord;

  /// No description provided for @qsDocuments.
  ///
  /// In en, this message translates to:
  /// **'My\ndocuments'**
  String get qsDocuments;

  /// No description provided for @qsClinics.
  ///
  /// In en, this message translates to:
  /// **'Find\nclinics'**
  String get qsClinics;

  /// No description provided for @qsTelemedicine.
  ///
  /// In en, this message translates to:
  /// **'Telemedicine'**
  String get qsTelemedicine;

  /// No description provided for @popularDoctors.
  ///
  /// In en, this message translates to:
  /// **'Popular doctors'**
  String get popularDoctors;

  /// No description provided for @popularSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Popular specialties'**
  String get popularSpecialties;

  /// No description provided for @myResults.
  ///
  /// In en, this message translates to:
  /// **'My results'**
  String get myResults;

  /// No description provided for @careTitle.
  ///
  /// In en, this message translates to:
  /// **'Health care'**
  String get careTitle;

  /// No description provided for @careTip1Title.
  ///
  /// In en, this message translates to:
  /// **'Annual check-up'**
  String get careTip1Title;

  /// No description provided for @careTip1Body.
  ///
  /// In en, this message translates to:
  /// **'A routine check-up with a GP once a year helps notice changes early.'**
  String get careTip1Body;

  /// No description provided for @careTip2Title.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get careTip2Title;

  /// No description provided for @careTip2Body.
  ///
  /// In en, this message translates to:
  /// **'Keep a bottle of water at hand during the day.'**
  String get careTip2Body;

  /// No description provided for @careTip3Title.
  ///
  /// In en, this message translates to:
  /// **'Vaccination reminder'**
  String get careTip3Title;

  /// No description provided for @careTip3Body.
  ///
  /// In en, this message translates to:
  /// **'Check your vaccination schedule with your doctor.'**
  String get careTip3Body;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @inTimeDays.
  ///
  /// In en, this message translates to:
  /// **'in {days} d.'**
  String inTimeDays(int days);

  /// No description provided for @openNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get openNotifications;

  /// No description provided for @spTherapist.
  ///
  /// In en, this message translates to:
  /// **'Therapist'**
  String get spTherapist;

  /// No description provided for @spCardiologist.
  ///
  /// In en, this message translates to:
  /// **'Cardiologist'**
  String get spCardiologist;

  /// No description provided for @spNeurologist.
  ///
  /// In en, this message translates to:
  /// **'Neurologist'**
  String get spNeurologist;

  /// No description provided for @spPediatrician.
  ///
  /// In en, this message translates to:
  /// **'Pediatrician'**
  String get spPediatrician;

  /// No description provided for @spDentist.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get spDentist;

  /// No description provided for @spDermatologist.
  ///
  /// In en, this message translates to:
  /// **'Dermatologist'**
  String get spDermatologist;

  /// No description provided for @spOphthalmologist.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmologist'**
  String get spOphthalmologist;

  /// No description provided for @spEndocrinologist.
  ///
  /// In en, this message translates to:
  /// **'Endocrinologist'**
  String get spEndocrinologist;

  /// No description provided for @doctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctorsTitle;

  /// No description provided for @searchDoctorsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or specialty'**
  String get searchDoctorsHint;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortTitle;

  /// No description provided for @sortPopularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get sortPopularity;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sortRating;

  /// No description provided for @sortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceDesc;

  /// No description provided for @sortExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get sortExperience;

  /// No description provided for @filterClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get filterClinic;

  /// No description provided for @filterRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get filterRating;

  /// No description provided for @filterPrice.
  ///
  /// In en, this message translates to:
  /// **'Maximum price'**
  String get filterPrice;

  /// No description provided for @filterExperience.
  ///
  /// In en, this message translates to:
  /// **'Minimum experience'**
  String get filterExperience;

  /// No description provided for @anyOption.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyOption;

  /// No description provided for @favoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get favoritesOnly;

  /// No description provided for @noDoctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'No doctors found'**
  String get noDoctorsTitle;

  /// No description provided for @noDoctorsBody.
  ///
  /// In en, this message translates to:
  /// **'Try changing the search or filters.'**
  String get noDoctorsBody;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} year} other{{count} years}} of experience'**
  String experienceYears(int count);

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} review} other{{count} reviews}}'**
  String reviewsCount(int count);

  /// No description provided for @consultationPrice.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultationPrice;

  /// No description provided for @nearestSlot.
  ///
  /// In en, this message translates to:
  /// **'Nearest: {when}'**
  String nearestSlot(String when);

  /// No description provided for @noSlotsSoon.
  ///
  /// In en, this message translates to:
  /// **'No free slots soon'**
  String get noSlotsSoon;

  /// No description provided for @bookButton.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get bookButton;

  /// No description provided for @doctorAbout.
  ///
  /// In en, this message translates to:
  /// **'About the doctor'**
  String get doctorAbout;

  /// No description provided for @doctorEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get doctorEducation;

  /// No description provided for @doctorQualification.
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get doctorQualification;

  /// No description provided for @doctorLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get doctorLanguages;

  /// No description provided for @doctorServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get doctorServices;

  /// No description provided for @doctorWorkplace.
  ///
  /// In en, this message translates to:
  /// **'Place of work'**
  String get doctorWorkplace;

  /// No description provided for @doctorReviews.
  ///
  /// In en, this message translates to:
  /// **'Patient reviews'**
  String get doctorReviews;

  /// No description provided for @doctorSchedule.
  ///
  /// In en, this message translates to:
  /// **'Available time'**
  String get doctorSchedule;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @favoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoriteRemoved;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite doctors'**
  String get favoritesTitle;

  /// No description provided for @noFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite doctors yet'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a doctor profile to save them here.'**
  String get noFavoritesBody;

  /// No description provided for @langName_kk.
  ///
  /// In en, this message translates to:
  /// **'Kazakh'**
  String get langName_kk;

  /// No description provided for @langName_ru.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get langName_ru;

  /// No description provided for @langName_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langName_en;

  /// No description provided for @verifiedDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo profile — fictional person'**
  String get verifiedDemoNote;

  /// No description provided for @bookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Book a visit'**
  String get bookingTitle;

  /// No description provided for @stepSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get stepSpecialty;

  /// No description provided for @stepDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get stepDoctor;

  /// No description provided for @stepClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get stepClinic;

  /// No description provided for @stepDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get stepDate;

  /// No description provided for @stepTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get stepTime;

  /// No description provided for @stepReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get stepReason;

  /// No description provided for @stepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get stepConfirm;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @chooseSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Choose a specialty'**
  String get chooseSpecialty;

  /// No description provided for @chooseDoctor.
  ///
  /// In en, this message translates to:
  /// **'Choose a doctor'**
  String get chooseDoctor;

  /// No description provided for @chooseClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic of the visit'**
  String get chooseClinic;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get chooseDate;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get chooseTime;

  /// No description provided for @availableTime.
  ///
  /// In en, this message translates to:
  /// **'Available time'**
  String get availableTime;

  /// No description provided for @noSlotsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No free slots on this day'**
  String get noSlotsOnDay;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason for the visit'**
  String get reasonLabel;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe your symptoms or goal'**
  String get reasonHint;

  /// No description provided for @reasonChipCheckup.
  ///
  /// In en, this message translates to:
  /// **'Check-up'**
  String get reasonChipCheckup;

  /// No description provided for @reasonChipConsult.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get reasonChipConsult;

  /// No description provided for @reasonChipFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get reasonChipFollowUp;

  /// No description provided for @reasonChipResults.
  ///
  /// In en, this message translates to:
  /// **'Discuss test results'**
  String get reasonChipResults;

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Visit summary'**
  String get bookingSummary;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBooking;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @payAtClinicNote.
  ///
  /// In en, this message translates to:
  /// **'Payment is made at the clinic after the visit.'**
  String get payAtClinicNote;

  /// No description provided for @bookingSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You are booked!'**
  String get bookingSuccessTitle;

  /// No description provided for @bookingSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'We will remind you before the visit.'**
  String get bookingSuccessBody;

  /// No description provided for @bookingNumber.
  ///
  /// In en, this message translates to:
  /// **'Booking number'**
  String get bookingNumber;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get addToCalendar;

  /// No description provided for @calendarOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the calendar'**
  String get calendarOpenFailed;

  /// No description provided for @goToAppointments.
  ///
  /// In en, this message translates to:
  /// **'My appointments'**
  String get goToAppointments;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @errSlotTaken.
  ///
  /// In en, this message translates to:
  /// **'This time was just booked by someone else. Please choose another slot.'**
  String get errSlotTaken;

  /// No description provided for @errSlotPast.
  ///
  /// In en, this message translates to:
  /// **'This time is no longer available.'**
  String get errSlotPast;

  /// No description provided for @errOutsideSchedule.
  ///
  /// In en, this message translates to:
  /// **'This time is outside the doctor\'s schedule.'**
  String get errOutsideSchedule;

  /// No description provided for @errBookingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the booking'**
  String get errBookingGeneric;

  /// No description provided for @errTooLate.
  ///
  /// In en, this message translates to:
  /// **'Changes are possible no later than {hours} h before the visit.'**
  String errTooLate(int hours);

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get errNotFound;

  /// No description provided for @errAlreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'You have already reviewed this visit'**
  String get errAlreadyReviewed;

  /// No description provided for @errNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'A review is possible after the visit'**
  String get errNotCompleted;

  /// No description provided for @noDoctorsForSpecialty.
  ///
  /// In en, this message translates to:
  /// **'No doctors for this specialty yet'**
  String get noDoctorsForSpecialty;

  /// No description provided for @appointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'My appointments'**
  String get appointmentsTitle;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// No description provided for @tabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tabCompleted;

  /// No description provided for @tabCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get tabCancelled;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAll;

  /// No description provided for @period30.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get period30;

  /// No description provided for @period90.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get period90;

  /// No description provided for @period365.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get period365;

  /// No description provided for @noUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming visits'**
  String get noUpcomingTitle;

  /// No description provided for @noCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'No completed visits'**
  String get noCompletedTitle;

  /// No description provided for @noCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'No cancelled visits'**
  String get noCancelledTitle;

  /// No description provided for @noAppointmentsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nothing for the selected period.'**
  String get noAppointmentsInPeriod;

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointmentDetails;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel appointment'**
  String get cancelAppointment;

  /// No description provided for @rescheduleAppointment.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get rescheduleAppointment;

  /// No description provided for @repeatAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book again'**
  String get repeatAppointment;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leaveReview;

  /// No description provided for @cancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this appointment?'**
  String get cancelConfirmTitle;

  /// No description provided for @cancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The time slot will be released for other patients.'**
  String get cancelConfirmBody;

  /// No description provided for @cancelReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get cancelReasonHint;

  /// No description provided for @keepAppointment.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepAppointment;

  /// No description provided for @appointmentCancelledSnack.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled'**
  String get appointmentCancelledSnack;

  /// No description provided for @appointmentRescheduledSnack.
  ///
  /// In en, this message translates to:
  /// **'Appointment rescheduled'**
  String get appointmentRescheduledSnack;

  /// No description provided for @rescheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new time'**
  String get rescheduleTitle;

  /// No description provided for @rescheduleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new time'**
  String get rescheduleConfirm;

  /// No description provided for @changePolicy.
  ///
  /// In en, this message translates to:
  /// **'Free changes up to {hours} h before the visit'**
  String changePolicy(int hours);

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your visit?'**
  String get reviewTitle;

  /// No description provided for @reviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get reviewCommentHint;

  /// No description provided for @reviewThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get reviewThanks;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating: {value}'**
  String yourRating(String value);

  /// No description provided for @doctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorLabel;

  /// No description provided for @clinicLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinicLabel;

  /// No description provided for @dateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get dateTimeLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @cancelledReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancelledReasonLabel;

  /// No description provided for @analysesTitle.
  ///
  /// In en, this message translates to:
  /// **'Tests & studies'**
  String get analysesTitle;

  /// No description provided for @tabMyAnalyses.
  ///
  /// In en, this message translates to:
  /// **'My tests'**
  String get tabMyAnalyses;

  /// No description provided for @tabOrders.
  ///
  /// In en, this message translates to:
  /// **'Prescribed'**
  String get tabOrders;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catCbc.
  ///
  /// In en, this message translates to:
  /// **'Blood count'**
  String get catCbc;

  /// No description provided for @catBiochemistry.
  ///
  /// In en, this message translates to:
  /// **'Biochemistry'**
  String get catBiochemistry;

  /// No description provided for @catUrine.
  ///
  /// In en, this message translates to:
  /// **'Urine'**
  String get catUrine;

  /// No description provided for @catHormones.
  ///
  /// In en, this message translates to:
  /// **'Hormones'**
  String get catHormones;

  /// No description provided for @catVitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get catVitamins;

  /// No description provided for @catImmunology.
  ///
  /// In en, this message translates to:
  /// **'Immunology'**
  String get catImmunology;

  /// No description provided for @catPcr.
  ///
  /// In en, this message translates to:
  /// **'PCR'**
  String get catPcr;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @labPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get labPending;

  /// No description provided for @labProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get labProcessing;

  /// No description provided for @labReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get labReady;

  /// No description provided for @labAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get labAttention;

  /// No description provided for @labNoAnalyses.
  ///
  /// In en, this message translates to:
  /// **'No tests yet'**
  String get labNoAnalyses;

  /// No description provided for @labNoAnalysesBody.
  ///
  /// In en, this message translates to:
  /// **'Your results will appear here as soon as the laboratory publishes them.'**
  String get labNoAnalysesBody;

  /// No description provided for @labNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No prescribed tests'**
  String get labNoOrders;

  /// No description provided for @labResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get labResultTitle;

  /// No description provided for @labIndicator.
  ///
  /// In en, this message translates to:
  /// **'Indicator'**
  String get labIndicator;

  /// No description provided for @labReference.
  ///
  /// In en, this message translates to:
  /// **'Reference range'**
  String get labReference;

  /// No description provided for @labRefRange.
  ///
  /// In en, this message translates to:
  /// **'{min} – {max}'**
  String labRefRange(String max, String min);

  /// No description provided for @labRefLess.
  ///
  /// In en, this message translates to:
  /// **'up to {max}'**
  String labRefLess(String max);

  /// No description provided for @labRefMore.
  ///
  /// In en, this message translates to:
  /// **'from {min}'**
  String labRefMore(String min);

  /// No description provided for @labOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Outside the laboratory reference range'**
  String get labOutOfRange;

  /// No description provided for @labInRange.
  ///
  /// In en, this message translates to:
  /// **'Within the reference range'**
  String get labInRange;

  /// No description provided for @labLaboratory.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get labLaboratory;

  /// No description provided for @labDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labDate;

  /// No description provided for @labDynamics.
  ///
  /// In en, this message translates to:
  /// **'Dynamics'**
  String get labDynamics;

  /// No description provided for @labDynamicsFor.
  ///
  /// In en, this message translates to:
  /// **'Trend: {name}'**
  String labDynamicsFor(String name);

  /// No description provided for @labDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Values are compared with the reference ranges provided by the laboratory. AMAN does not diagnose — please discuss results with your doctor.'**
  String get labDisclaimer;

  /// No description provided for @labResultPending.
  ///
  /// In en, this message translates to:
  /// **'The result is not ready yet. We will notify you when it is published.'**
  String get labResultPending;

  /// No description provided for @labPrescribedBy.
  ///
  /// In en, this message translates to:
  /// **'Prescribed by {doctor}'**
  String labPrescribedBy(String doctor);

  /// No description provided for @labOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Open document'**
  String get labOpenDocument;

  /// No description provided for @labTestCount.
  ///
  /// In en, this message translates to:
  /// **'{count} indicators'**
  String labTestCount(int count);

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical record'**
  String get recordTitle;

  /// No description provided for @recGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get recGeneral;

  /// No description provided for @recVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get recVisits;

  /// No description provided for @recDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Diagnoses'**
  String get recDiagnoses;

  /// No description provided for @recPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get recPrescriptions;

  /// No description provided for @recAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get recAllergies;

  /// No description provided for @recChronic.
  ///
  /// In en, this message translates to:
  /// **'Chronic conditions'**
  String get recChronic;

  /// No description provided for @recPast.
  ///
  /// In en, this message translates to:
  /// **'Past illnesses'**
  String get recPast;

  /// No description provided for @recProcedures.
  ///
  /// In en, this message translates to:
  /// **'Procedures'**
  String get recProcedures;

  /// No description provided for @recVaccinations.
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get recVaccinations;

  /// No description provided for @recLabs.
  ///
  /// In en, this message translates to:
  /// **'Laboratory studies'**
  String get recLabs;

  /// No description provided for @recDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get recDocuments;

  /// No description provided for @recAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get recAge;

  /// No description provided for @recAgeValue.
  ///
  /// In en, this message translates to:
  /// **'{years} y.o.'**
  String recAgeValue(int years);

  /// No description provided for @recConfirmedBy.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by: {ref}'**
  String recConfirmedBy(String ref);

  /// No description provided for @recEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get recEmpty;

  /// No description provided for @recDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Only information confirmed by doctors or documents is shown. AMAN does not create medical records on its own.'**
  String get recDisclaimer;

  /// No description provided for @recFilterDates.
  ///
  /// In en, this message translates to:
  /// **'Filter by dates'**
  String get recFilterDates;

  /// No description provided for @recDateFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get recDateFrom;

  /// No description provided for @recDateTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get recDateTo;

  /// No description provided for @recTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get recTimeline;

  /// No description provided for @documentsTitle.
  ///
  /// In en, this message translates to:
  /// **'My documents'**
  String get documentsTitle;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload document'**
  String get uploadDocument;

  /// No description provided for @docTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Document title'**
  String get docTitleLabel;

  /// No description provided for @docKindLabel.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get docKindLabel;

  /// No description provided for @docKindLab.
  ///
  /// In en, this message translates to:
  /// **'Lab report'**
  String get docKindLab;

  /// No description provided for @docKindPrescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get docKindPrescription;

  /// No description provided for @docKindConclusion.
  ///
  /// In en, this message translates to:
  /// **'Conclusion'**
  String get docKindConclusion;

  /// No description provided for @docKindReferral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get docKindReferral;

  /// No description provided for @docKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get docKindOther;

  /// No description provided for @pickFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file (PDF, JPG, PNG)'**
  String get pickFile;

  /// No description provided for @uploadHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 10 MB. Files are checked before upload.'**
  String get uploadHint;

  /// No description provided for @uploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document uploaded'**
  String get uploadSuccess;

  /// No description provided for @deleteDocument.
  ///
  /// In en, this message translates to:
  /// **'Delete document'**
  String get deleteDocument;

  /// No description provided for @deleteDocumentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this document? This cannot be undone.'**
  String get deleteDocumentConfirm;

  /// No description provided for @documentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Document deleted'**
  String get documentDeleted;

  /// No description provided for @errUploadEmpty.
  ///
  /// In en, this message translates to:
  /// **'The file is empty'**
  String get errUploadEmpty;

  /// No description provided for @errUploadLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is larger than 10 MB'**
  String get errUploadLarge;

  /// No description provided for @errUploadType.
  ///
  /// In en, this message translates to:
  /// **'Only PDF, JPG and PNG files are allowed'**
  String get errUploadType;

  /// No description provided for @noDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No documents'**
  String get noDocumentsTitle;

  /// No description provided for @noDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'Upload results, prescriptions or conclusions to keep them in one place.'**
  String get noDocumentsBody;

  /// No description provided for @docPdfNotice.
  ///
  /// In en, this message translates to:
  /// **'PDF file saved securely. Open it with a PDF viewer after downloading.'**
  String get docPdfNotice;

  /// No description provided for @docDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Demo document with synthetic content'**
  String get docDemoNotice;

  /// No description provided for @docUploadedBy.
  ///
  /// In en, this message translates to:
  /// **'Uploaded by you'**
  String get docUploadedBy;

  /// No description provided for @docUploadedByClinic.
  ///
  /// In en, this message translates to:
  /// **'From clinic'**
  String get docUploadedByClinic;

  /// No description provided for @clinicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinics'**
  String get clinicsTitle;

  /// No description provided for @searchClinicsHint.
  ///
  /// In en, this message translates to:
  /// **'Search clinic or address'**
  String get searchClinicsHint;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @clinicHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get clinicHours;

  /// No description provided for @clinicContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get clinicContacts;

  /// No description provided for @buildRoute.
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get buildRoute;

  /// No description provided for @clinicDoctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get clinicDoctors;

  /// No description provided for @clinicServices.
  ///
  /// In en, this message translates to:
  /// **'Services & prices'**
  String get clinicServices;

  /// No description provided for @noClinicsTitle.
  ///
  /// In en, this message translates to:
  /// **'No clinics found'**
  String get noClinicsTitle;

  /// No description provided for @mapDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo map. Connect a map provider key to enable the live map.'**
  String get mapDemoNote;

  /// No description provided for @routeOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the maps app'**
  String get routeOpenFailed;

  /// No description provided for @clinicsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} clinics'**
  String clinicsCount(int count);

  /// No description provided for @callFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the call'**
  String get callFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editProfile;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get personalData;

  /// No description provided for @appointmentHistory.
  ///
  /// In en, this message translates to:
  /// **'Appointment history'**
  String get appointmentHistory;

  /// No description provided for @medicalRecordMenu.
  ///
  /// In en, this message translates to:
  /// **'Medical record'**
  String get medicalRecordMenu;

  /// No description provided for @myAnalyses.
  ///
  /// In en, this message translates to:
  /// **'My tests'**
  String get myAnalyses;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My documents'**
  String get myDocuments;

  /// No description provided for @favoriteDoctors.
  ///
  /// In en, this message translates to:
  /// **'Favorite doctors'**
  String get favoriteDoctors;

  /// No description provided for @notificationsMenu.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsMenu;

  /// No description provided for @settingsMenu.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsMenu;

  /// No description provided for @languageMenu.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageMenu;

  /// No description provided for @securityMenu.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityMenu;

  /// No description provided for @helpMenu.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpMenu;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of AMAN?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to see your data.'**
  String get logoutConfirmBody;

  /// No description provided for @statAppointments.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get statAppointments;

  /// No description provided for @statAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get statAnalyses;

  /// No description provided for @statDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get statDocuments;

  /// No description provided for @statFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get statFavorites;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @securityTokensTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure session'**
  String get securityTokensTitle;

  /// No description provided for @securityTokensBody.
  ///
  /// In en, this message translates to:
  /// **'Access tokens are kept in the device secure storage. Passwords are never stored on the device.'**
  String get securityTokensBody;

  /// No description provided for @securityConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Data processing consent'**
  String get securityConsentTitle;

  /// No description provided for @securityConsentBody.
  ///
  /// In en, this message translates to:
  /// **'You agreed to the processing of personal and medical data when creating the account.'**
  String get securityConsentBody;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpFaqTitle;

  /// No description provided for @faq1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel or reschedule a visit?'**
  String get faq1Q;

  /// No description provided for @faq1A.
  ///
  /// In en, this message translates to:
  /// **'Open the visit in “Visits” and choose the action. Changes are allowed until the deadline set by the clinic.'**
  String get faq1A;

  /// No description provided for @faq2Q.
  ///
  /// In en, this message translates to:
  /// **'Where do my results come from?'**
  String get faq2Q;

  /// No description provided for @faq2A.
  ///
  /// In en, this message translates to:
  /// **'Results and records are provided by clinics and laboratories. The app never interprets them on its own.'**
  String get faq2A;

  /// No description provided for @faq3Q.
  ///
  /// In en, this message translates to:
  /// **'Is my data protected?'**
  String get faq3Q;

  /// No description provided for @faq3A.
  ///
  /// In en, this message translates to:
  /// **'Data is transferred over HTTPS and access to every record is checked and audited.'**
  String get faq3A;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'support@aman.example'**
  String get supportEmail;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @demoModeNote.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: all data is synthetic and stored only in the app memory.'**
  String get demoModeNote;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders and updates about your visits will appear here.'**
  String get noNotificationsBody;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @ntCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment created'**
  String get ntCreatedTitle;

  /// No description provided for @ntCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'{doctor}, {when}'**
  String ntCreatedBody(String doctor, String when);

  /// No description provided for @ntReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit reminder'**
  String get ntReminderTitle;

  /// No description provided for @ntReminderBody.
  ///
  /// In en, this message translates to:
  /// **'{doctor} — {when}'**
  String ntReminderBody(String doctor, String when);

  /// No description provided for @ntRescheduledTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment rescheduled'**
  String get ntRescheduledTitle;

  /// No description provided for @ntRescheduledBody.
  ///
  /// In en, this message translates to:
  /// **'{doctor}, new time: {when}'**
  String ntRescheduledBody(String doctor, String when);

  /// No description provided for @ntCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled'**
  String get ntCancelledTitle;

  /// No description provided for @ntCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'{doctor}, {when}'**
  String ntCancelledBody(String doctor, String when);

  /// No description provided for @ntLabReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Test results are ready'**
  String get ntLabReadyTitle;

  /// No description provided for @ntLabReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Open the app to see the results.'**
  String get ntLabReadyBody;

  /// No description provided for @ntPrescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'New prescription'**
  String get ntPrescriptionTitle;

  /// No description provided for @ntPrescriptionBody.
  ///
  /// In en, this message translates to:
  /// **'{doctor} added a prescription to your record.'**
  String ntPrescriptionBody(String doctor);

  /// No description provided for @ntScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor schedule changed'**
  String get ntScheduleTitle;

  /// No description provided for @ntScheduleBody.
  ///
  /// In en, this message translates to:
  /// **'{doctor} updated the working hours.'**
  String ntScheduleBody(String doctor);

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTitle;

  /// No description provided for @servicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything for your health in one place'**
  String get servicesSubtitle;

  /// No description provided for @svcDoctorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Catalog of specialists'**
  String get svcDoctorsDesc;

  /// No description provided for @svcBookDesc.
  ///
  /// In en, this message translates to:
  /// **'Book in a few steps'**
  String get svcBookDesc;

  /// No description provided for @svcAnalysesDesc.
  ///
  /// In en, this message translates to:
  /// **'Results and trends'**
  String get svcAnalysesDesc;

  /// No description provided for @svcRecordDesc.
  ///
  /// In en, this message translates to:
  /// **'Your history in one place'**
  String get svcRecordDesc;

  /// No description provided for @svcDocumentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Files and conclusions'**
  String get svcDocumentsDesc;

  /// No description provided for @svcClinicsDesc.
  ///
  /// In en, this message translates to:
  /// **'Map and directions'**
  String get svcClinicsDesc;

  /// No description provided for @telemedTitle.
  ///
  /// In en, this message translates to:
  /// **'Telemedicine is on the way'**
  String get telemedTitle;

  /// No description provided for @telemedBody.
  ///
  /// In en, this message translates to:
  /// **'Video consultations are planned for a future release. For now you can book an in-clinic visit.'**
  String get telemedBody;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get comingSoon;

  /// No description provided for @statExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get statExperience;

  /// No description provided for @yearsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} y.'**
  String yearsShort(int count);

  /// No description provided for @routeSummary.
  ///
  /// In en, this message translates to:
  /// **'Route to {clinic}'**
  String routeSummary(String clinic);

  /// No description provided for @selectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedLabel;

  /// No description provided for @weekSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get weekSelectHint;

  /// No description provided for @bookingCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave booking?'**
  String get bookingCancelTitle;

  /// No description provided for @bookingCancelBody.
  ///
  /// In en, this message translates to:
  /// **'Your choices will not be saved.'**
  String get bookingCancelBody;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @appointmentPrice.
  ///
  /// In en, this message translates to:
  /// **'Price at the clinic'**
  String get appointmentPrice;

  /// No description provided for @viewDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor profile'**
  String get viewDoctor;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get showOnMap;

  /// No description provided for @searchNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get searchNothing;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted'**
  String get reviewSubmitted;

  /// No description provided for @rateStars.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate'**
  String get rateStars;

  /// No description provided for @medRecordOpen.
  ///
  /// In en, this message translates to:
  /// **'Open medical record'**
  String get medRecordOpen;

  /// No description provided for @pdfLabel.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfLabel;

  /// No description provided for @profileStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get profileStatsTitle;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @languageSaved.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageSaved;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete notification'**
  String get deleteNotification;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'kk':
      return AppL10nKk();
    case 'ru':
      return AppL10nRu();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
