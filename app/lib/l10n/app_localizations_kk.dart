// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppL10nKk extends AppL10n {
  AppL10nKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'AMAN';

  @override
  String get tagline => 'AMAN — денсаулық қасыңызда';

  @override
  String get demoBadge => 'DEMO';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get confirm => 'Растау';

  @override
  String get save => 'Сақтау';

  @override
  String get close => 'Жабу';

  @override
  String get next => 'Келесі';

  @override
  String get back => 'Артқа';

  @override
  String get continueAction => 'Жалғастыру';

  @override
  String get retry => 'Қайталау';

  @override
  String get done => 'Дайын';

  @override
  String get search => 'Іздеу';

  @override
  String get apply => 'Қолдану';

  @override
  String get reset => 'Тазалау';

  @override
  String get all => 'Барлығы';

  @override
  String get delete => 'Жою';

  @override
  String get edit => 'Өңдеу';

  @override
  String get details => 'Толығырақ';

  @override
  String get seeAll => 'Барлығы';

  @override
  String get today => 'Бүгін';

  @override
  String get tomorrow => 'Ертең';

  @override
  String get skip => 'Өткізіп жіберу';

  @override
  String get finish => 'Аяқтау';

  @override
  String get submit => 'Жіберу';

  @override
  String get call => 'Қоңырау шалу';

  @override
  String get errorGeneric => 'Бірдеңе дұрыс болмады. Қайта көріңіз.';

  @override
  String get errorNetwork =>
      'Серверге қосылу жоқ. Интернетті тексеріп, қайта көріңіз.';

  @override
  String get navHome => 'Басты бет';

  @override
  String get navAppointments => 'Жазылулар';

  @override
  String get navServices => 'Сервистер';

  @override
  String get navProfile => 'Профиль';

  @override
  String get welcomeTitle => 'Денсаулық —\nәрдайым жанында';

  @override
  String get welcomeSubtitle =>
      'Дәрігерлер, қабылдауға жазылу, талдаулар және медициналық тарих — бір қауіпсіз қосымшада.';

  @override
  String get onb1Title => 'Өз дәрігеріңізді табыңыз';

  @override
  String get onb1Body =>
      'Серіктес клиникалар мамандарының рейтингін, тәжірибесін және бағасын салыстырыңыз.';

  @override
  String get onb2Title => 'Бірнеше басумен жазылыңыз';

  @override
  String get onb2Body =>
      'Бос уақытты таңдап, келуді растаңыз және еске салғыш алыңыз.';

  @override
  String get onb3Title => 'Деректеріңіз қорғалған';

  @override
  String get onb3Body =>
      'Талдаулар, құжаттар және жазбалар қауіпсіз сақталады және тек сізге қолжетімді.';

  @override
  String get getStarted => 'Бастау';

  @override
  String get haveAccount => 'Менде аккаунт бар';

  @override
  String get signIn => 'Кіру';

  @override
  String get signUp => 'Аккаунт жасау';

  @override
  String get phoneLabel => 'Телефон нөмірі';

  @override
  String get phoneHint => '700 123 45 67';

  @override
  String get passwordLabel => 'Құпия сөз';

  @override
  String get confirmPasswordLabel => 'Құпия сөзді қайталаңыз';

  @override
  String get fullNameLabel => 'Аты-жөні';

  @override
  String get fullNameHint => 'Тегі Аты Әкесінің аты';

  @override
  String get emailLabel => 'Электрондық пошта';

  @override
  String get emailOptionalLabel => 'Электрондық пошта (міндетті емес)';

  @override
  String get loginTitle => 'Қош келдіңіз';

  @override
  String get loginSubtitle => 'Телефон нөмірі мен құпия сөз арқылы кіріңіз.';

  @override
  String get forgotPassword => 'Құпия сөзді ұмыттыңыз ба?';

  @override
  String get noAccount => 'Аккаунт жоқ па?';

  @override
  String get registerTitle => 'Аккаунт жасаңыз';

  @override
  String get registerSubtitle => 'Телефоныңызға растау кодын жібереміз.';

  @override
  String get consentText =>
      'Жеке және медициналық деректерімді өңдеуге келісемін';

  @override
  String get consentNote =>
      'Деректер тек қызмет көрсету үшін өңделеді және сіздің рұқсатыңызсыз берілмейді.';

  @override
  String get otpTitle => 'Телефонды растаңыз';

  @override
  String otpSubtitle(String phone) {
    return '$phone нөміріне жіберілген 4 таңбалы кодты енгізіңіз';
  }

  @override
  String otpDemoHint(String code) {
    return 'DEMO режимі: кодыңыз — $code';
  }

  @override
  String get otpLabel => 'Код';

  @override
  String get resendCode => 'Кодты қайта жіберу';

  @override
  String get codeResent => 'Жаңа код жіберілді';

  @override
  String get verify => 'Растау';

  @override
  String get resetTitle => 'Құпия сөзді қалпына келтіру';

  @override
  String get resetSubtitle =>
      'Телефон нөміріңізді енгізіңіз — растау кодын жібереміз.';

  @override
  String get sendCode => 'Код жіберу';

  @override
  String get newPasswordLabel => 'Жаңа құпия сөз';

  @override
  String get resetButton => 'Жаңа құпия сөзді сақтау';

  @override
  String get passwordResetDone => 'Құпия сөз жаңартылды. Енді кіре аласыз.';

  @override
  String get profileSetupTitle => 'Өзіңіз туралы айтыңыз';

  @override
  String get profileSetupSubtitle =>
      'Бұл дәрігерлерге қабылдауға дайындалуға көмектеседі. Кейін өзгертуге болады.';

  @override
  String get birthDateLabel => 'Туған күні';

  @override
  String get genderLabel => 'Жынысы';

  @override
  String get male => 'Ер';

  @override
  String get female => 'Әйел';

  @override
  String get cityLabel => 'Қала';

  @override
  String get bloodTypeLabel => 'Қан тобы';

  @override
  String demoAccountHint(String password, String phone) {
    return 'DEMO-аккаунт: $phone / $password';
  }

  @override
  String get useDemoAccount => 'Демо-аккаунтты енгізу';

  @override
  String get errRequired => 'Міндетті өріс';

  @override
  String get errPhone => '+7 нөмірін дұрыс енгізіңіз';

  @override
  String get errPassword => 'Кемінде 8 таңба, әріп және сан';

  @override
  String get errEmail => 'Электрондық поштаны дұрыс енгізіңіз';

  @override
  String get errOtp => '4 таңбалы кодты енгізіңіз';

  @override
  String get errName => 'Тегі мен атын көрсетіңіз';

  @override
  String get errMismatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String get errReason => 'Себебін сипаттаңыз (кемінде 3 таңба)';

  @override
  String get errDate => 'Күнді дұрыс таңдаңыз';

  @override
  String get errInvalidCredentials => 'Телефон нөмірі немесе құпия сөз қате';

  @override
  String get errPhoneTaken => 'Бұл нөмір тіркелген';

  @override
  String get errAccountNotFound => 'Аккаунт табылмады';

  @override
  String get errInvalidOtp => 'Растау коды қате';

  @override
  String get errConsent => 'Деректерді өңдеуге келісім қажет';

  @override
  String greeting(String name) {
    return 'Сәлеметсіз бе, $name!';
  }

  @override
  String get nextAppointment => 'Жақын жазылу';

  @override
  String get noAppointmentsTitle => 'Алдағы жазылулар жоқ';

  @override
  String get noAppointmentsBody => 'Дәрігерге бірнеше басумен жазылыңыз.';

  @override
  String get bookDoctor => 'Дәрігерге жазылу';

  @override
  String get quickServices => 'Жылдам сервистер';

  @override
  String get qsBook => 'Дәрігерге\nжазылу';

  @override
  String get qsAnalyses => 'Талдаулар';

  @override
  String get qsRecord => 'Медициналық\nкарта';

  @override
  String get qsDocuments => 'Менің\nқұжаттарым';

  @override
  String get qsClinics => 'Клиника\nіздеу';

  @override
  String get qsTelemedicine => 'Телемедицина';

  @override
  String get popularDoctors => 'Танымал дәрігерлер';

  @override
  String get popularSpecialties => 'Танымал мамандықтар';

  @override
  String get myResults => 'Менің нәтижелерім';

  @override
  String get careTitle => 'Денсаулық күтімі';

  @override
  String get careTip1Title => 'Жыл сайынғы тексеру';

  @override
  String get careTip1Body =>
      'Жылына бір рет терапевтке профилактикалық қаралу өзгерістерді уақытында байқауға көмектеседі.';

  @override
  String get careTip2Title => 'Су ішіңіз';

  @override
  String get careTip2Body => 'Күні бойы жаныңызда су бөтелкесін ұстаңыз.';

  @override
  String get careTip3Title => 'Вакцинация туралы еске салу';

  @override
  String get careTip3Body => 'Екпе кестесін дәрігеріңізбен нақтылаңыз.';

  @override
  String get statusConfirmed => 'Расталған';

  @override
  String get statusCompleted => 'Аяқталған';

  @override
  String get statusCancelled => 'Бас тартылған';

  @override
  String inTimeDays(int days) {
    return '$days күннен кейін';
  }

  @override
  String get openNotifications => 'Хабарламалар';

  @override
  String get spTherapist => 'Терапевт';

  @override
  String get spCardiologist => 'Кардиолог';

  @override
  String get spNeurologist => 'Невролог';

  @override
  String get spPediatrician => 'Педиатр';

  @override
  String get spDentist => 'Стоматолог';

  @override
  String get spDermatologist => 'Дерматолог';

  @override
  String get spOphthalmologist => 'Офтальмолог';

  @override
  String get spEndocrinologist => 'Эндокринолог';

  @override
  String get doctorsTitle => 'Дәрігерлер';

  @override
  String get searchDoctorsHint => 'Аты немесе мамандығы бойынша іздеу';

  @override
  String get filtersTitle => 'Сүзгілер';

  @override
  String get sortTitle => 'Сұрыптау';

  @override
  String get sortPopularity => 'Танымалдығы бойынша';

  @override
  String get sortRating => 'Рейтинг бойынша';

  @override
  String get sortPriceAsc => 'Баға: өсу бойынша';

  @override
  String get sortPriceDesc => 'Баға: кему бойынша';

  @override
  String get sortExperience => 'Тәжірибе бойынша';

  @override
  String get filterClinic => 'Клиника';

  @override
  String get filterRating => 'Ең төмен рейтинг';

  @override
  String get filterPrice => 'Ең жоғары баға';

  @override
  String get filterExperience => 'Ең аз тәжірибе';

  @override
  String get anyOption => 'Кез келген';

  @override
  String get favoritesOnly => 'Тек таңдаулылар';

  @override
  String get noDoctorsTitle => 'Дәрігерлер табылмады';

  @override
  String get noDoctorsBody => 'Іздеу сұранысын немесе сүзгілерді өзгертіңіз.';

  @override
  String get resetFilters => 'Сүзгілерді тазалау';

  @override
  String experienceYears(int count) {
    return '$count жыл тәжірибе';
  }

  @override
  String reviewsCount(int count) {
    return '$count пікір';
  }

  @override
  String get consultationPrice => 'Кеңес';

  @override
  String nearestSlot(String when) {
    return 'Жақын уақыт: $when';
  }

  @override
  String get noSlotsSoon => 'Бос уақыт жоқ';

  @override
  String get bookButton => 'Жазылу';

  @override
  String get doctorAbout => 'Дәрігер туралы';

  @override
  String get doctorEducation => 'Білімі';

  @override
  String get doctorQualification => 'Біліктілігі';

  @override
  String get doctorLanguages => 'Қызмет көрсету тілдері';

  @override
  String get doctorServices => 'Қызметтер';

  @override
  String get doctorWorkplace => 'Жұмыс орны';

  @override
  String get doctorReviews => 'Пациент пікірлері';

  @override
  String get doctorSchedule => 'Қолжетімді уақыт';

  @override
  String get addFavorite => 'Таңдаулыға қосу';

  @override
  String get removeFavorite => 'Таңдаулыдан алып тастау';

  @override
  String get favoriteAdded => 'Таңдаулыға қосылды';

  @override
  String get favoriteRemoved => 'Таңдаулыдан алынды';

  @override
  String get favoritesTitle => 'Таңдаулы дәрігерлер';

  @override
  String get noFavoritesTitle => 'Таңдаулы дәрігерлер жоқ';

  @override
  String get noFavoritesBody =>
      'Дәрігер профиліндегі жүрекшені басып, осында сақтаңыз.';

  @override
  String get langName_kk => 'Қазақша';

  @override
  String get langName_ru => 'Орысша';

  @override
  String get langName_en => 'Ағылшынша';

  @override
  String get verifiedDemoNote => 'Демо-профиль — ойдан шығарылған маман';

  @override
  String get bookingTitle => 'Дәрігерге жазылу';

  @override
  String get stepSpecialty => 'Мамандық';

  @override
  String get stepDoctor => 'Дәрігер';

  @override
  String get stepClinic => 'Клиника';

  @override
  String get stepDate => 'Күні';

  @override
  String get stepTime => 'Уақыты';

  @override
  String get stepReason => 'Өтініш себебі';

  @override
  String get stepConfirm => 'Растау';

  @override
  String stepOf(int current, int total) {
    return '$current-қадам / $total';
  }

  @override
  String get chooseSpecialty => 'Мамандықты таңдаңыз';

  @override
  String get chooseDoctor => 'Дәрігерді таңдаңыз';

  @override
  String get chooseClinic => 'Қабылдау клиникасы';

  @override
  String get chooseDate => 'Күнді таңдаңыз';

  @override
  String get chooseTime => 'Уақытты таңдаңыз';

  @override
  String get availableTime => 'Қолжетімді уақыт';

  @override
  String get noSlotsOnDay => 'Бұл күні бос уақыт жоқ';

  @override
  String get reasonLabel => 'Өтініш себебі';

  @override
  String get reasonHint =>
      'Шағымдарыңызды немесе мақсатыңызды қысқаша сипаттаңыз';

  @override
  String get reasonChipCheckup => 'Профилактикалық қарау';

  @override
  String get reasonChipConsult => 'Кеңес алу';

  @override
  String get reasonChipFollowUp => 'Қайта қабылдау';

  @override
  String get reasonChipResults => 'Талдауларды талқылау';

  @override
  String get bookingSummary => 'Жазылу деректері';

  @override
  String get confirmBooking => 'Жазылуды растау';

  @override
  String get priceLabel => 'Құны';

  @override
  String get payAtClinicNote => 'Төлем қабылдаудан кейін клиникада жасалады.';

  @override
  String get bookingSuccessTitle => 'Сіз жазылдыңыз!';

  @override
  String get bookingSuccessBody => 'Келу алдында сізге еске саламыз.';

  @override
  String get bookingNumber => 'Жазылу нөмірі';

  @override
  String get addToCalendar => 'Күнтізбеге қосу';

  @override
  String get calendarOpenFailed => 'Күнтізбені ашу мүмкін болмады';

  @override
  String get goToAppointments => 'Менің жазылуларым';

  @override
  String get backHome => 'Басты бетке';

  @override
  String get errSlotTaken =>
      'Бұл уақытты жаңа ғана басқа адам алды. Басқа уақыт таңдаңыз.';

  @override
  String get errSlotPast => 'Бұл уақыт енді қолжетімді емес.';

  @override
  String get errOutsideSchedule => 'Бұл уақыт дәрігердің кестесінен тыс.';

  @override
  String get errBookingGeneric => 'Жазылуды рәсімдеу мүмкін болмады';

  @override
  String errTooLate(int hours) {
    return 'Жазылуды қабылдауға $hours сағат қалғанға дейін ғана өзгертуге болады.';
  }

  @override
  String get errNotFound => 'Табылмады';

  @override
  String get errAlreadyReviewed => 'Бұл қабылдау туралы пікір қалдырдыңыз';

  @override
  String get errNotCompleted => 'Пікірді қабылдаудан кейін қалдыруға болады';

  @override
  String get noDoctorsForSpecialty => 'Бұл мамандық бойынша дәрігерлер жоқ';

  @override
  String get appointmentsTitle => 'Менің жазылуларым';

  @override
  String get tabUpcoming => 'Алдағы';

  @override
  String get tabCompleted => 'Аяқталған';

  @override
  String get tabCancelled => 'Бас тартылған';

  @override
  String get periodAll => 'Барлық уақыт';

  @override
  String get period30 => '30 күн';

  @override
  String get period90 => '3 ай';

  @override
  String get period365 => 'Жыл';

  @override
  String get noUpcomingTitle => 'Алдағы жазылулар жоқ';

  @override
  String get noCompletedTitle => 'Аяқталған қабылдаулар жоқ';

  @override
  String get noCancelledTitle => 'Бас тартылған жазылулар жоқ';

  @override
  String get noAppointmentsInPeriod => 'Таңдалған кезеңде ештеңе жоқ.';

  @override
  String get appointmentDetails => 'Жазылу';

  @override
  String get cancelAppointment => 'Жазылудан бас тарту';

  @override
  String get rescheduleAppointment => 'Жазылуды ауыстыру';

  @override
  String get repeatAppointment => 'Қайта жазылу';

  @override
  String get leaveReview => 'Пікір қалдыру';

  @override
  String get cancelConfirmTitle => 'Жазылудан бас тарту керек пе?';

  @override
  String get cancelConfirmBody => 'Уақыт басқа пациенттер үшін босатылады.';

  @override
  String get cancelReasonHint => 'Себебі (міндетті емес)';

  @override
  String get keepAppointment => 'Қалдыру';

  @override
  String get appointmentCancelledSnack => 'Жазылудан бас тартылды';

  @override
  String get appointmentRescheduledSnack => 'Жазылу ауыстырылды';

  @override
  String get rescheduleTitle => 'Жаңа уақытты таңдаңыз';

  @override
  String get rescheduleConfirm => 'Ауыстыруды растау';

  @override
  String changePolicy(int hours) {
    return 'Қабылдауға $hours сағатқа дейін тегін өзгерту';
  }

  @override
  String get reviewTitle => 'Қабылдау қалай өтті?';

  @override
  String get reviewCommentHint => 'Пікір (міндетті емес)';

  @override
  String get reviewThanks => 'Пікіріңіз үшін рахмет!';

  @override
  String yourRating(String value) {
    return 'Сіздің бағаңыз: $value';
  }

  @override
  String get doctorLabel => 'Дәрігер';

  @override
  String get clinicLabel => 'Клиника';

  @override
  String get dateTimeLabel => 'Күні мен уақыты';

  @override
  String get statusLabel => 'Күйі';

  @override
  String get cancelledReasonLabel => 'Бас тарту себебі';

  @override
  String get analysesTitle => 'Талдаулар мен зерттеулер';

  @override
  String get tabMyAnalyses => 'Менің талдауларым';

  @override
  String get tabOrders => 'Тағайындаулар';

  @override
  String get catAll => 'Барлығы';

  @override
  String get catCbc => 'Қанның жалпы талдауы';

  @override
  String get catBiochemistry => 'Биохимия';

  @override
  String get catUrine => 'Несеп талдауы';

  @override
  String get catHormones => 'Гормондар';

  @override
  String get catVitamins => 'Витаминдер';

  @override
  String get catImmunology => 'Иммунология';

  @override
  String get catPcr => 'ПТР';

  @override
  String get catOther => 'Басқа зерттеулер';

  @override
  String get labPending => 'Күтілуде';

  @override
  String get labProcessing => 'Өңделуде';

  @override
  String get labReady => 'Дайын';

  @override
  String get labAttention => 'Назар аудару қажет';

  @override
  String get labNoAnalyses => 'Талдаулар әзірге жоқ';

  @override
  String get labNoAnalysesBody =>
      'Нәтижелер зертхана жариялағаннан кейін осында шығады.';

  @override
  String get labNoOrders => 'Тағайындаулар жоқ';

  @override
  String get labResultTitle => 'Нәтиже';

  @override
  String get labIndicator => 'Көрсеткіш';

  @override
  String get labReference => 'Референстік мәндер';

  @override
  String labRefRange(String max, String min) {
    return '$min – $max';
  }

  @override
  String labRefLess(String max) {
    return '$max дейін';
  }

  @override
  String labRefMore(String min) {
    return '$min бастап';
  }

  @override
  String get labOutOfRange => 'Зертхананың референс диапазонынан тыс';

  @override
  String get labInRange => 'Референс диапазонында';

  @override
  String get labLaboratory => 'Зертхана';

  @override
  String get labDate => 'Күні';

  @override
  String get labDynamics => 'Көрсеткіштер динамикасы';

  @override
  String labDynamicsFor(String name) {
    return 'Динамика: $name';
  }

  @override
  String get labDisclaimer =>
      'Көрсеткіштер зертхананың референстік мәндерімен салыстырылады. AMAN диагноз қоймайды — нәтижелерді дәрігермен талқылаңыз.';

  @override
  String get labResultPending =>
      'Нәтиже әлі дайын емес. Жарияланғанда хабарлаймыз.';

  @override
  String labPrescribedBy(String doctor) {
    return 'Тағайындаған: $doctor';
  }

  @override
  String get labOpenDocument => 'Құжатты ашу';

  @override
  String labTestCount(int count) {
    return 'Көрсеткіштер: $count';
  }

  @override
  String get recordTitle => 'Медициналық карта';

  @override
  String get recGeneral => 'Жалпы ақпарат';

  @override
  String get recVisits => 'Қабылдаулар тарихы';

  @override
  String get recDiagnoses => 'Дәрігер диагноздары';

  @override
  String get recPrescriptions => 'Тағайындаулар';

  @override
  String get recAllergies => 'Аллергиялар';

  @override
  String get recChronic => 'Созылмалы аурулар';

  @override
  String get recPast => 'Бұрынғы аурулар';

  @override
  String get recProcedures => 'Медициналық рәсімдер';

  @override
  String get recVaccinations => 'Вакцинация';

  @override
  String get recLabs => 'Зертханалық зерттеулер';

  @override
  String get recDocuments => 'Медициналық құжаттар';

  @override
  String get recAge => 'Жасы';

  @override
  String recAgeValue(int years) {
    return '$years жас';
  }

  @override
  String recConfirmedBy(String ref) {
    return 'Расталған: $ref';
  }

  @override
  String get recEmpty => 'Жазбалар әзірге жоқ';

  @override
  String get recDisclaimer =>
      'Тек дәрігерлер немесе құжаттар растаған ақпарат көрсетіледі. AMAN медициналық жазбаларды өздігінен жасамайды.';

  @override
  String get recFilterDates => 'Күндер бойынша сүзгі';

  @override
  String get recDateFrom => 'Бастап';

  @override
  String get recDateTo => 'Дейін';

  @override
  String get recTimeline => 'Хронология';

  @override
  String get documentsTitle => 'Менің құжаттарым';

  @override
  String get uploadDocument => 'Құжат жүктеу';

  @override
  String get docTitleLabel => 'Құжат атауы';

  @override
  String get docKindLabel => 'Құжат түрі';

  @override
  String get docKindLab => 'Зерттеу нәтижесі';

  @override
  String get docKindPrescription => 'Рецепт';

  @override
  String get docKindConclusion => 'Дәрігер қорытындысы';

  @override
  String get docKindReferral => 'Жолдама';

  @override
  String get docKindOther => 'Басқа';

  @override
  String get pickFile => 'Файлды таңдаңыз (PDF, JPG, PNG)';

  @override
  String get uploadHint => '10 МБ дейін. Файлдар жүктелмес бұрын тексеріледі.';

  @override
  String get uploadSuccess => 'Құжат жүктелді';

  @override
  String get deleteDocument => 'Құжатты жою';

  @override
  String get deleteDocumentConfirm =>
      'Бұл құжатты жою керек пе? Әрекет қайтарылмайды.';

  @override
  String get documentDeleted => 'Құжат жойылды';

  @override
  String get errUploadEmpty => 'Файл бос';

  @override
  String get errUploadLarge => 'Файл 10 МБ-тан үлкен';

  @override
  String get errUploadType => 'Тек PDF, JPG және PNG рұқсат етілген';

  @override
  String get noDocumentsTitle => 'Құжаттар жоқ';

  @override
  String get noDocumentsBody =>
      'Нәтижелерді, рецепттерді немесе қорытындыларды бір жерде сақтау үшін жүктеңіз.';

  @override
  String get docPdfNotice =>
      'PDF файл қорғалған қоймада сақталды. Көру үшін PDF қосымшасында ашыңыз.';

  @override
  String get docDemoNotice => 'Синтетикалық мазмұны бар демо-құжат';

  @override
  String get docUploadedBy => 'Сіз жүктедіңіз';

  @override
  String get docUploadedByClinic => 'Клиникадан';

  @override
  String get clinicsTitle => 'Клиникалар';

  @override
  String get searchClinicsHint => 'Клиника немесе мекенжай іздеу';

  @override
  String get mapView => 'Карта';

  @override
  String get listView => 'Тізім';

  @override
  String get clinicHours => 'Жұмыс кестесі';

  @override
  String get clinicContacts => 'Байланыс';

  @override
  String get buildRoute => 'Маршрут салу';

  @override
  String get clinicDoctors => 'Клиника дәрігерлері';

  @override
  String get clinicServices => 'Қызметтер мен баға';

  @override
  String get noClinicsTitle => 'Клиникалар табылмады';

  @override
  String get mapDemoNote =>
      'Демо-карта. Интерактивті карта үшін карта кілтін қосыңыз.';

  @override
  String get routeOpenFailed => 'Карта қосымшасын ашу мүмкін болмады';

  @override
  String clinicsCount(int count) {
    return 'Клиникалар: $count';
  }

  @override
  String get callFailed => 'Қоңырау бастау мүмкін болмады';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get editProfile => 'Өңдеу';

  @override
  String get editProfileTitle => 'Профильді өңдеу';

  @override
  String get personalData => 'Жеке деректер';

  @override
  String get appointmentHistory => 'Жазылулар тарихы';

  @override
  String get medicalRecordMenu => 'Медициналық карта';

  @override
  String get myAnalyses => 'Менің талдауларым';

  @override
  String get myDocuments => 'Менің құжаттарым';

  @override
  String get favoriteDoctors => 'Таңдаулы дәрігерлер';

  @override
  String get notificationsMenu => 'Хабарламалар';

  @override
  String get settingsMenu => 'Баптаулар';

  @override
  String get languageMenu => 'Қосымша тілі';

  @override
  String get securityMenu => 'Қауіпсіздік';

  @override
  String get helpMenu => 'Көмек және қолдау';

  @override
  String get logout => 'Аккаунттан шығу';

  @override
  String get logoutConfirmTitle => 'AMAN-нан шығу керек пе?';

  @override
  String get logoutConfirmBody => 'Деректерді көру үшін қайта кіру қажет.';

  @override
  String get statAppointments => 'Жазылулар';

  @override
  String get statAnalyses => 'Талдаулар';

  @override
  String get statDocuments => 'Құжаттар';

  @override
  String get statFavorites => 'Таңдаулы';

  @override
  String get profileSaved => 'Профиль сақталды';

  @override
  String get appearance => 'Көрініс';

  @override
  String get themeSystem => 'Жүйелік';

  @override
  String get themeLight => 'Жарық';

  @override
  String get themeDark => 'Қараңғы';

  @override
  String get securityTokensTitle => 'Қорғалған сессия';

  @override
  String get securityTokensBody =>
      'Қолжетімділік токендері құрылғының қорғалған қоймасында сақталады. Құпия сөздер құрылғыда сақталмайды.';

  @override
  String get securityConsentTitle => 'Деректерді өңдеуге келісім';

  @override
  String get securityConsentBody =>
      'Тіркелу кезінде жеке және медициналық деректерді өңдеуге келісім бердіңіз.';

  @override
  String get changePassword => 'Құпия сөзді өзгерту';

  @override
  String get helpFaqTitle => 'Жиі қойылатын сұрақтар';

  @override
  String get faq1Q => 'Жазылудан қалай бас тартуға немесе ауыстыруға болады?';

  @override
  String get faq1A =>
      '«Жазылулар» бөлімінде жазылуды ашып, әрекетті таңдаңыз. Өзгерту клиника белгілеген мерзімге дейін мүмкін.';

  @override
  String get faq2Q => 'Нәтижелерім қайдан келеді?';

  @override
  String get faq2A =>
      'Нәтижелер мен жазбаларды клиникалар мен зертханалар береді. Қосымша оларды өздігінен түсіндірмейді.';

  @override
  String get faq3Q => 'Деректерім қорғалған ба?';

  @override
  String get faq3A =>
      'Деректер HTTPS арқылы беріледі, әр жазбаға қолжетімділік тексеріліп, тіркеледі.';

  @override
  String get contactSupport => 'Қолдау қызметімен байланысу';

  @override
  String get supportEmail => 'support@aman.example';

  @override
  String appVersion(String version) {
    return 'Нұсқа $version';
  }

  @override
  String get demoModeNote =>
      'Демо-режим: барлық деректер синтетикалық және тек қосымша жадында сақталады.';

  @override
  String get notificationsTitle => 'Хабарламалар';

  @override
  String get markAllRead => 'Барлығын оқылған деп белгілеу';

  @override
  String get noNotificationsTitle => 'Хабарламалар жоқ';

  @override
  String get noNotificationsBody =>
      'Визиттер туралы еске салғыштар мен жаңалықтар осында шығады.';

  @override
  String get notificationDeleted => 'Хабарлама жойылды';

  @override
  String get undo => 'Қайтару';

  @override
  String get ntCreatedTitle => 'Жазылу жасалды';

  @override
  String ntCreatedBody(String doctor, String when) {
    return '$doctor, $when';
  }

  @override
  String get ntReminderTitle => 'Қабылдау туралы еске салу';

  @override
  String ntReminderBody(String doctor, String when) {
    return '$doctor — $when';
  }

  @override
  String get ntRescheduledTitle => 'Жазылу ауыстырылды';

  @override
  String ntRescheduledBody(String doctor, String when) {
    return '$doctor, жаңа уақыты: $when';
  }

  @override
  String get ntCancelledTitle => 'Жазылудан бас тартылды';

  @override
  String ntCancelledBody(String doctor, String when) {
    return '$doctor, $when';
  }

  @override
  String get ntLabReadyTitle => 'Талдау нәтижелері дайын';

  @override
  String get ntLabReadyBody => 'Нәтижелерді көру үшін қосымшаны ашыңыз.';

  @override
  String get ntPrescriptionTitle => 'Жаңа тағайындау';

  @override
  String ntPrescriptionBody(String doctor) {
    return '$doctor картаңызға тағайындау қосты.';
  }

  @override
  String get ntScheduleTitle => 'Дәрігер кестесі өзгерді';

  @override
  String ntScheduleBody(String doctor) {
    return '$doctor қабылдау кестесін жаңартты.';
  }

  @override
  String get servicesTitle => 'Сервистер';

  @override
  String get servicesSubtitle => 'Денсаулығыңызға қажеттінің бәрі бір жерде';

  @override
  String get svcDoctorsDesc => 'Мамандар каталогы';

  @override
  String get svcBookDesc => 'Бірнеше қадаммен жазылу';

  @override
  String get svcAnalysesDesc => 'Нәтижелер мен динамика';

  @override
  String get svcRecordDesc => 'Тарихыңыз бір жерде';

  @override
  String get svcDocumentsDesc => 'Файлдар мен қорытындылар';

  @override
  String get svcClinicsDesc => 'Карта және маршруттар';

  @override
  String get telemedTitle => 'Телемедицина жақында қолжетімді болады';

  @override
  String get telemedBody =>
      'Бейнекеңестер келесі жаңартуларға жоспарланған. Әзірге клиникаға жазылуға болады.';

  @override
  String get comingSoon => 'Жақында';

  @override
  String get statExperience => 'Тәжірибе';

  @override
  String yearsShort(int count) {
    return '$count ж.';
  }

  @override
  String routeSummary(String clinic) {
    return '$clinic клиникасына маршрут';
  }

  @override
  String get selectedLabel => 'Таңдалды';

  @override
  String get weekSelectHint => 'Күнді таңдаңыз';

  @override
  String get bookingCancelTitle => 'Жазылудан шығу керек пе?';

  @override
  String get bookingCancelBody => 'Таңдалған деректер сақталмайды.';

  @override
  String get leave => 'Шығу';

  @override
  String get appointmentPrice => 'Клиникадағы құны';

  @override
  String get viewDoctor => 'Дәрігер профилі';

  @override
  String get showOnMap => 'Картада көрсету';

  @override
  String get searchNothing => 'Ештеңе табылмады';

  @override
  String get reviewSubmitted => 'Пікір жіберілді';

  @override
  String get rateStars => 'Бағалау үшін жұлдызшаны басыңыз';

  @override
  String get medRecordOpen => 'Медициналық картаны ашу';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get profileStatsTitle => 'Шолу';

  @override
  String get themeTitle => 'Тақырып';

  @override
  String get languageSaved => 'Тіл өзгертілді';

  @override
  String get deleteNotification => 'Хабарламаны жою';
}
