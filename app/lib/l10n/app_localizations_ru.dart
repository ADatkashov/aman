// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'AMAN';

  @override
  String get tagline => 'AMAN — здоровье рядом';

  @override
  String get demoBadge => 'DEMO';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get save => 'Сохранить';

  @override
  String get close => 'Закрыть';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get retry => 'Повторить';

  @override
  String get done => 'Готово';

  @override
  String get search => 'Поиск';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String get all => 'Все';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get details => 'Подробнее';

  @override
  String get seeAll => 'Все';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get skip => 'Пропустить';

  @override
  String get finish => 'Завершить';

  @override
  String get submit => 'Отправить';

  @override
  String get call => 'Позвонить';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorNetwork =>
      'Нет связи с сервером. Проверьте интернет и повторите.';

  @override
  String get navHome => 'Главная';

  @override
  String get navAppointments => 'Записи';

  @override
  String get navServices => 'Сервисы';

  @override
  String get navProfile => 'Профиль';

  @override
  String get welcomeTitle => 'Здоровье —\nвсегда рядом';

  @override
  String get welcomeSubtitle =>
      'Врачи, запись на приём, анализы и медицинская история — в одном защищённом приложении.';

  @override
  String get onb1Title => 'Найдите своего врача';

  @override
  String get onb1Body =>
      'Сравнивайте рейтинг, опыт и стоимость специалистов клиник-партнёров.';

  @override
  String get onb2Title => 'Запись в несколько касаний';

  @override
  String get onb2Body =>
      'Выберите свободное время, подтвердите визит и получите напоминание.';

  @override
  String get onb3Title => 'Ваши данные под защитой';

  @override
  String get onb3Body =>
      'Анализы, документы и записи хранятся безопасно и доступны только вам.';

  @override
  String get getStarted => 'Начать';

  @override
  String get haveAccount => 'У меня уже есть аккаунт';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Создать аккаунт';

  @override
  String get phoneLabel => 'Номер телефона';

  @override
  String get phoneHint => '700 123 45 67';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get confirmPasswordLabel => 'Повторите пароль';

  @override
  String get fullNameLabel => 'ФИО';

  @override
  String get fullNameHint => 'Фамилия Имя Отчество';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get emailOptionalLabel => 'Электронная почта (необязательно)';

  @override
  String get loginTitle => 'С возвращением';

  @override
  String get loginSubtitle => 'Войдите по номеру телефона и паролю.';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get registerTitle => 'Создайте аккаунт';

  @override
  String get registerSubtitle =>
      'Мы отправим код подтверждения на ваш телефон.';

  @override
  String get consentText =>
      'Я согласен на обработку персональных и медицинских данных';

  @override
  String get consentNote =>
      'Данные обрабатываются только для работы сервиса и не передаются без вашего разрешения.';

  @override
  String get otpTitle => 'Подтвердите телефон';

  @override
  String otpSubtitle(String phone) {
    return 'Введите 4-значный код, отправленный на $phone';
  }

  @override
  String otpDemoHint(String code) {
    return 'Режим DEMO: ваш код — $code';
  }

  @override
  String get otpLabel => 'Код';

  @override
  String get resendCode => 'Отправить код ещё раз';

  @override
  String get codeResent => 'Новый код отправлен';

  @override
  String get verify => 'Подтвердить';

  @override
  String get resetTitle => 'Восстановление пароля';

  @override
  String get resetSubtitle =>
      'Укажите номер телефона — мы отправим код подтверждения.';

  @override
  String get sendCode => 'Отправить код';

  @override
  String get newPasswordLabel => 'Новый пароль';

  @override
  String get resetButton => 'Сохранить новый пароль';

  @override
  String get passwordResetDone => 'Пароль обновлён. Теперь можно войти.';

  @override
  String get profileSetupTitle => 'Расскажите о себе';

  @override
  String get profileSetupSubtitle =>
      'Это поможет врачам подготовиться к приёму. Данные можно изменить позже.';

  @override
  String get birthDateLabel => 'Дата рождения';

  @override
  String get genderLabel => 'Пол';

  @override
  String get male => 'Мужской';

  @override
  String get female => 'Женский';

  @override
  String get cityLabel => 'Город';

  @override
  String get bloodTypeLabel => 'Группа крови';

  @override
  String demoAccountHint(String password, String phone) {
    return 'DEMO-аккаунт: $phone / $password';
  }

  @override
  String get useDemoAccount => 'Подставить демо-аккаунт';

  @override
  String get errRequired => 'Обязательное поле';

  @override
  String get errPhone => 'Введите корректный номер +7';

  @override
  String get errPassword => 'Минимум 8 символов, буква и цифра';

  @override
  String get errEmail => 'Введите корректную почту';

  @override
  String get errOtp => 'Введите 4-значный код';

  @override
  String get errName => 'Укажите фамилию и имя';

  @override
  String get errMismatch => 'Пароли не совпадают';

  @override
  String get errReason => 'Опишите причину (минимум 3 символа)';

  @override
  String get errDate => 'Выберите корректную дату';

  @override
  String get errInvalidCredentials => 'Неверный номер телефона или пароль';

  @override
  String get errPhoneTaken => 'Этот номер уже зарегистрирован';

  @override
  String get errAccountNotFound => 'Аккаунт не найден';

  @override
  String get errInvalidOtp => 'Неверный код подтверждения';

  @override
  String get errConsent => 'Необходимо согласие на обработку данных';

  @override
  String greeting(String name) {
    return 'Здравствуйте, $name!';
  }

  @override
  String get nextAppointment => 'Ближайшая запись';

  @override
  String get noAppointmentsTitle => 'Нет предстоящих записей';

  @override
  String get noAppointmentsBody => 'Запишитесь к врачу в несколько касаний.';

  @override
  String get bookDoctor => 'Записаться к врачу';

  @override
  String get quickServices => 'Быстрые сервисы';

  @override
  String get qsBook => 'Запись\nк врачу';

  @override
  String get qsAnalyses => 'Анализы';

  @override
  String get qsRecord => 'Медицин-\nская карта';

  @override
  String get qsDocuments => 'Мои\nдокументы';

  @override
  String get qsClinics => 'Поиск\nклиник';

  @override
  String get qsTelemedicine => 'Телемедицина';

  @override
  String get popularDoctors => 'Популярные врачи';

  @override
  String get popularSpecialties => 'Популярные специальности';

  @override
  String get myResults => 'Мои результаты';

  @override
  String get careTitle => 'Забота о здоровье';

  @override
  String get careTip1Title => 'Ежегодный осмотр';

  @override
  String get careTip1Body =>
      'Плановый осмотр у терапевта раз в год помогает вовремя заметить изменения.';

  @override
  String get careTip2Title => 'Пейте воду';

  @override
  String get careTip2Body => 'Держите бутылку воды под рукой в течение дня.';

  @override
  String get careTip3Title => 'Напоминание о вакцинации';

  @override
  String get careTip3Body => 'Уточните график прививок у вашего врача.';

  @override
  String get statusConfirmed => 'Подтверждена';

  @override
  String get statusCompleted => 'Завершена';

  @override
  String get statusCancelled => 'Отменена';

  @override
  String inTimeDays(int days) {
    return 'через $days дн.';
  }

  @override
  String get openNotifications => 'Уведомления';

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
  String get doctorsTitle => 'Врачи';

  @override
  String get searchDoctorsHint => 'Поиск по имени или специальности';

  @override
  String get filtersTitle => 'Фильтры';

  @override
  String get sortTitle => 'Сортировка';

  @override
  String get sortPopularity => 'По популярности';

  @override
  String get sortRating => 'По рейтингу';

  @override
  String get sortPriceAsc => 'Цена: по возрастанию';

  @override
  String get sortPriceDesc => 'Цена: по убыванию';

  @override
  String get sortExperience => 'По опыту';

  @override
  String get filterClinic => 'Клиника';

  @override
  String get filterRating => 'Минимальный рейтинг';

  @override
  String get filterPrice => 'Максимальная цена';

  @override
  String get filterExperience => 'Минимальный стаж';

  @override
  String get anyOption => 'Любой';

  @override
  String get favoritesOnly => 'Только избранные';

  @override
  String get noDoctorsTitle => 'Врачи не найдены';

  @override
  String get noDoctorsBody => 'Измените запрос или фильтры.';

  @override
  String get resetFilters => 'Сбросить фильтры';

  @override
  String experienceYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
    );
    return 'Стаж $_temp0';
  }

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отзыва',
      many: '$count отзывов',
      few: '$count отзыва',
      one: '$count отзыв',
    );
    return '$_temp0';
  }

  @override
  String get consultationPrice => 'Консультация';

  @override
  String nearestSlot(String when) {
    return 'Ближайшее: $when';
  }

  @override
  String get noSlotsSoon => 'Нет свободного времени';

  @override
  String get bookButton => 'Записаться';

  @override
  String get doctorAbout => 'О враче';

  @override
  String get doctorEducation => 'Образование';

  @override
  String get doctorQualification => 'Квалификация';

  @override
  String get doctorLanguages => 'Языки обслуживания';

  @override
  String get doctorServices => 'Услуги';

  @override
  String get doctorWorkplace => 'Место работы';

  @override
  String get doctorReviews => 'Отзывы пациентов';

  @override
  String get doctorSchedule => 'Доступное расписание';

  @override
  String get addFavorite => 'В избранное';

  @override
  String get removeFavorite => 'Убрать из избранного';

  @override
  String get favoriteAdded => 'Добавлено в избранное';

  @override
  String get favoriteRemoved => 'Удалено из избранного';

  @override
  String get favoritesTitle => 'Избранные врачи';

  @override
  String get noFavoritesTitle => 'Пока нет избранных врачей';

  @override
  String get noFavoritesBody =>
      'Нажмите на сердечко в профиле врача, чтобы сохранить его здесь.';

  @override
  String get langName_kk => 'Казахский';

  @override
  String get langName_ru => 'Русский';

  @override
  String get langName_en => 'Английский';

  @override
  String get verifiedDemoNote => 'Демо-профиль — вымышленный специалист';

  @override
  String get bookingTitle => 'Запись к врачу';

  @override
  String get stepSpecialty => 'Специальность';

  @override
  String get stepDoctor => 'Врач';

  @override
  String get stepClinic => 'Клиника';

  @override
  String get stepDate => 'Дата';

  @override
  String get stepTime => 'Время';

  @override
  String get stepReason => 'Причина обращения';

  @override
  String get stepConfirm => 'Подтверждение';

  @override
  String stepOf(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get chooseSpecialty => 'Выберите специальность';

  @override
  String get chooseDoctor => 'Выберите врача';

  @override
  String get chooseClinic => 'Клиника приёма';

  @override
  String get chooseDate => 'Выберите дату';

  @override
  String get chooseTime => 'Выберите время';

  @override
  String get availableTime => 'Доступное время';

  @override
  String get noSlotsOnDay => 'В этот день нет свободного времени';

  @override
  String get reasonLabel => 'Причина обращения';

  @override
  String get reasonHint => 'Кратко опишите жалобы или цель визита';

  @override
  String get reasonChipCheckup => 'Профилактический осмотр';

  @override
  String get reasonChipConsult => 'Консультация';

  @override
  String get reasonChipFollowUp => 'Повторный приём';

  @override
  String get reasonChipResults => 'Обсуждение анализов';

  @override
  String get bookingSummary => 'Данные записи';

  @override
  String get confirmBooking => 'Подтвердить запись';

  @override
  String get priceLabel => 'Стоимость';

  @override
  String get payAtClinicNote => 'Оплата производится в клинике после приёма.';

  @override
  String get bookingSuccessTitle => 'Вы записаны!';

  @override
  String get bookingSuccessBody => 'Мы напомним вам о визите заранее.';

  @override
  String get bookingNumber => 'Номер записи';

  @override
  String get addToCalendar => 'Добавить в календарь';

  @override
  String get calendarOpenFailed => 'Не удалось открыть календарь';

  @override
  String get goToAppointments => 'Мои записи';

  @override
  String get backHome => 'На главную';

  @override
  String get errSlotTaken =>
      'Это время только что заняли. Выберите другой слот.';

  @override
  String get errSlotPast => 'Это время уже недоступно.';

  @override
  String get errOutsideSchedule => 'Это время вне расписания врача.';

  @override
  String get errBookingGeneric => 'Не удалось оформить запись';

  @override
  String errTooLate(int hours) {
    return 'Изменить запись можно не позднее чем за $hours ч. до приёма.';
  }

  @override
  String get errNotFound => 'Не найдено';

  @override
  String get errAlreadyReviewed => 'Вы уже оставили отзыв об этом приёме';

  @override
  String get errNotCompleted => 'Отзыв можно оставить после приёма';

  @override
  String get noDoctorsForSpecialty => 'Для этой специальности пока нет врачей';

  @override
  String get appointmentsTitle => 'Мои записи';

  @override
  String get tabUpcoming => 'Предстоящие';

  @override
  String get tabCompleted => 'Завершённые';

  @override
  String get tabCancelled => 'Отменённые';

  @override
  String get periodAll => 'Всё время';

  @override
  String get period30 => '30 дней';

  @override
  String get period90 => '3 месяца';

  @override
  String get period365 => 'Год';

  @override
  String get noUpcomingTitle => 'Нет предстоящих записей';

  @override
  String get noCompletedTitle => 'Нет завершённых приёмов';

  @override
  String get noCancelledTitle => 'Нет отменённых записей';

  @override
  String get noAppointmentsInPeriod => 'За выбранный период ничего нет.';

  @override
  String get appointmentDetails => 'Запись';

  @override
  String get cancelAppointment => 'Отменить запись';

  @override
  String get rescheduleAppointment => 'Перенести запись';

  @override
  String get repeatAppointment => 'Повторить запись';

  @override
  String get leaveReview => 'Оставить отзыв';

  @override
  String get cancelConfirmTitle => 'Отменить запись?';

  @override
  String get cancelConfirmBody =>
      'Время будет освобождено для других пациентов.';

  @override
  String get cancelReasonHint => 'Причина (необязательно)';

  @override
  String get keepAppointment => 'Оставить';

  @override
  String get appointmentCancelledSnack => 'Запись отменена';

  @override
  String get appointmentRescheduledSnack => 'Запись перенесена';

  @override
  String get rescheduleTitle => 'Выберите новое время';

  @override
  String get rescheduleConfirm => 'Подтвердить перенос';

  @override
  String changePolicy(int hours) {
    return 'Бесплатное изменение — не позднее чем за $hours ч. до приёма';
  }

  @override
  String get reviewTitle => 'Как прошёл приём?';

  @override
  String get reviewCommentHint => 'Комментарий (необязательно)';

  @override
  String get reviewThanks => 'Спасибо за отзыв!';

  @override
  String yourRating(String value) {
    return 'Ваша оценка: $value';
  }

  @override
  String get doctorLabel => 'Врач';

  @override
  String get clinicLabel => 'Клиника';

  @override
  String get dateTimeLabel => 'Дата и время';

  @override
  String get statusLabel => 'Статус';

  @override
  String get cancelledReasonLabel => 'Причина отмены';

  @override
  String get analysesTitle => 'Анализы и исследования';

  @override
  String get tabMyAnalyses => 'Мои анализы';

  @override
  String get tabOrders => 'Назначения';

  @override
  String get catAll => 'Все';

  @override
  String get catCbc => 'Общий анализ крови';

  @override
  String get catBiochemistry => 'Биохимия';

  @override
  String get catUrine => 'Анализ мочи';

  @override
  String get catHormones => 'Гормоны';

  @override
  String get catVitamins => 'Витамины';

  @override
  String get catImmunology => 'Иммунология';

  @override
  String get catPcr => 'ПЦР';

  @override
  String get catOther => 'Другие исследования';

  @override
  String get labPending => 'Ожидается';

  @override
  String get labProcessing => 'В обработке';

  @override
  String get labReady => 'Готов';

  @override
  String get labAttention => 'Требует внимания';

  @override
  String get labNoAnalyses => 'Анализов пока нет';

  @override
  String get labNoAnalysesBody =>
      'Результаты появятся здесь, как только лаборатория их опубликует.';

  @override
  String get labNoOrders => 'Назначений нет';

  @override
  String get labResultTitle => 'Результат';

  @override
  String get labIndicator => 'Показатель';

  @override
  String get labReference => 'Референсные значения';

  @override
  String labRefRange(String max, String min) {
    return '$min – $max';
  }

  @override
  String labRefLess(String max) {
    return 'до $max';
  }

  @override
  String labRefMore(String min) {
    return 'от $min';
  }

  @override
  String get labOutOfRange => 'Вне референсного диапазона лаборатории';

  @override
  String get labInRange => 'В пределах референсного диапазона';

  @override
  String get labLaboratory => 'Лаборатория';

  @override
  String get labDate => 'Дата';

  @override
  String get labDynamics => 'Динамика показателей';

  @override
  String labDynamicsFor(String name) {
    return 'Динамика: $name';
  }

  @override
  String get labDisclaimer =>
      'Показатели сравниваются с референсными значениями лаборатории. AMAN не ставит диагнозов — обсудите результаты с врачом.';

  @override
  String get labResultPending =>
      'Результат ещё не готов. Мы уведомим, когда он будет опубликован.';

  @override
  String labPrescribedBy(String doctor) {
    return 'Назначил(а): $doctor';
  }

  @override
  String get labOpenDocument => 'Открыть документ';

  @override
  String labTestCount(int count) {
    return 'Показателей: $count';
  }

  @override
  String get recordTitle => 'Медицинская карта';

  @override
  String get recGeneral => 'Общая информация';

  @override
  String get recVisits => 'История посещений';

  @override
  String get recDiagnoses => 'Диагнозы врачей';

  @override
  String get recPrescriptions => 'Назначения';

  @override
  String get recAllergies => 'Аллергии';

  @override
  String get recChronic => 'Хронические заболевания';

  @override
  String get recPast => 'Перенесённые заболевания';

  @override
  String get recProcedures => 'Медицинские процедуры';

  @override
  String get recVaccinations => 'Вакцинация';

  @override
  String get recLabs => 'Лабораторные исследования';

  @override
  String get recDocuments => 'Медицинские документы';

  @override
  String get recAge => 'Возраст';

  @override
  String recAgeValue(int years) {
    return '$years лет';
  }

  @override
  String recConfirmedBy(String ref) {
    return 'Подтверждено: $ref';
  }

  @override
  String get recEmpty => 'Записей пока нет';

  @override
  String get recDisclaimer =>
      'Показана только информация, подтверждённая врачами или документами. AMAN не создаёт медицинские записи самостоятельно.';

  @override
  String get recFilterDates => 'Фильтр по датам';

  @override
  String get recDateFrom => 'С';

  @override
  String get recDateTo => 'По';

  @override
  String get recTimeline => 'Хронология';

  @override
  String get documentsTitle => 'Мои документы';

  @override
  String get uploadDocument => 'Загрузить документ';

  @override
  String get docTitleLabel => 'Название документа';

  @override
  String get docKindLabel => 'Тип документа';

  @override
  String get docKindLab => 'Результат исследования';

  @override
  String get docKindPrescription => 'Рецепт';

  @override
  String get docKindConclusion => 'Заключение врача';

  @override
  String get docKindReferral => 'Направление';

  @override
  String get docKindOther => 'Другое';

  @override
  String get pickFile => 'Выберите файл (PDF, JPG, PNG)';

  @override
  String get uploadHint => 'До 10 МБ. Файлы проверяются перед загрузкой.';

  @override
  String get uploadSuccess => 'Документ загружен';

  @override
  String get deleteDocument => 'Удалить документ';

  @override
  String get deleteDocumentConfirm =>
      'Удалить этот документ? Действие необратимо.';

  @override
  String get documentDeleted => 'Документ удалён';

  @override
  String get errUploadEmpty => 'Файл пустой';

  @override
  String get errUploadLarge => 'Файл больше 10 МБ';

  @override
  String get errUploadType => 'Допустимы только PDF, JPG и PNG';

  @override
  String get noDocumentsTitle => 'Документов нет';

  @override
  String get noDocumentsBody =>
      'Загрузите результаты, рецепты или заключения, чтобы хранить их в одном месте.';

  @override
  String get docPdfNotice =>
      'PDF-файл сохранён в защищённом хранилище. Для просмотра откройте его в PDF-приложении.';

  @override
  String get docDemoNotice => 'Демо-документ с синтетическим содержимым';

  @override
  String get docUploadedBy => 'Загружено вами';

  @override
  String get docUploadedByClinic => 'От клиники';

  @override
  String get clinicsTitle => 'Клиники';

  @override
  String get searchClinicsHint => 'Поиск клиники или адреса';

  @override
  String get mapView => 'Карта';

  @override
  String get listView => 'Список';

  @override
  String get clinicHours => 'График работы';

  @override
  String get clinicContacts => 'Контакты';

  @override
  String get buildRoute => 'Построить маршрут';

  @override
  String get clinicDoctors => 'Врачи клиники';

  @override
  String get clinicServices => 'Услуги и стоимость';

  @override
  String get noClinicsTitle => 'Клиники не найдены';

  @override
  String get mapDemoNote =>
      'Демонстрационная карта. Подключите ключ карт для интерактивной карты.';

  @override
  String get routeOpenFailed => 'Не удалось открыть приложение карт';

  @override
  String clinicsCount(int count) {
    return 'Клиник: $count';
  }

  @override
  String get callFailed => 'Не удалось начать звонок';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get editProfile => 'Редактировать';

  @override
  String get editProfileTitle => 'Редактирование профиля';

  @override
  String get personalData => 'Личные данные';

  @override
  String get appointmentHistory => 'История записей';

  @override
  String get medicalRecordMenu => 'Медицинская карта';

  @override
  String get myAnalyses => 'Мои анализы';

  @override
  String get myDocuments => 'Мои документы';

  @override
  String get favoriteDoctors => 'Избранные врачи';

  @override
  String get notificationsMenu => 'Уведомления';

  @override
  String get settingsMenu => 'Настройки';

  @override
  String get languageMenu => 'Язык приложения';

  @override
  String get securityMenu => 'Безопасность';

  @override
  String get helpMenu => 'Помощь и поддержка';

  @override
  String get logout => 'Выйти из аккаунта';

  @override
  String get logoutConfirmTitle => 'Выйти из AMAN?';

  @override
  String get logoutConfirmBody =>
      'Чтобы увидеть данные, потребуется снова войти.';

  @override
  String get statAppointments => 'Записи';

  @override
  String get statAnalyses => 'Анализы';

  @override
  String get statDocuments => 'Документы';

  @override
  String get statFavorites => 'Избранное';

  @override
  String get profileSaved => 'Профиль сохранён';

  @override
  String get appearance => 'Оформление';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get securityTokensTitle => 'Защищённая сессия';

  @override
  String get securityTokensBody =>
      'Токены доступа хранятся в защищённом хранилище устройства. Пароли на устройстве не сохраняются.';

  @override
  String get securityConsentTitle => 'Согласие на обработку данных';

  @override
  String get securityConsentBody =>
      'Вы дали согласие на обработку персональных и медицинских данных при регистрации.';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get helpFaqTitle => 'Частые вопросы';

  @override
  String get faq1Q => 'Как отменить или перенести запись?';

  @override
  String get faq1A =>
      'Откройте запись в разделе «Записи» и выберите действие. Изменения возможны до срока, установленного клиникой.';

  @override
  String get faq2Q => 'Откуда берутся мои результаты?';

  @override
  String get faq2A =>
      'Результаты и записи передают клиники и лаборатории. Приложение не интерпретирует их самостоятельно.';

  @override
  String get faq3Q => 'Защищены ли мои данные?';

  @override
  String get faq3A =>
      'Данные передаются по HTTPS, доступ к каждой записи проверяется и фиксируется.';

  @override
  String get contactSupport => 'Связаться с поддержкой';

  @override
  String get supportEmail => 'support@aman.example';

  @override
  String appVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get demoModeNote =>
      'Демо-режим: все данные синтетические и хранятся только в памяти приложения.';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get markAllRead => 'Прочитать все';

  @override
  String get noNotificationsTitle => 'Уведомлений нет';

  @override
  String get noNotificationsBody =>
      'Напоминания и новости о ваших визитах появятся здесь.';

  @override
  String get notificationDeleted => 'Уведомление удалено';

  @override
  String get undo => 'Отменить';

  @override
  String get ntCreatedTitle => 'Запись создана';

  @override
  String ntCreatedBody(String doctor, String when) {
    return '$doctor, $when';
  }

  @override
  String get ntReminderTitle => 'Напоминание о приёме';

  @override
  String ntReminderBody(String doctor, String when) {
    return '$doctor — $when';
  }

  @override
  String get ntRescheduledTitle => 'Запись перенесена';

  @override
  String ntRescheduledBody(String doctor, String when) {
    return '$doctor, новое время: $when';
  }

  @override
  String get ntCancelledTitle => 'Запись отменена';

  @override
  String ntCancelledBody(String doctor, String when) {
    return '$doctor, $when';
  }

  @override
  String get ntLabReadyTitle => 'Результаты анализов готовы';

  @override
  String get ntLabReadyBody =>
      'Откройте приложение, чтобы посмотреть результаты.';

  @override
  String get ntPrescriptionTitle => 'Новое назначение';

  @override
  String ntPrescriptionBody(String doctor) {
    return '$doctor добавил(а) назначение в вашу карту.';
  }

  @override
  String get ntScheduleTitle => 'Изменение расписания врача';

  @override
  String ntScheduleBody(String doctor) {
    return '$doctor обновил(а) график приёма.';
  }

  @override
  String get servicesTitle => 'Сервисы';

  @override
  String get servicesSubtitle => 'Всё для вашего здоровья в одном месте';

  @override
  String get svcDoctorsDesc => 'Каталог специалистов';

  @override
  String get svcBookDesc => 'Запись за несколько шагов';

  @override
  String get svcAnalysesDesc => 'Результаты и динамика';

  @override
  String get svcRecordDesc => 'История в одном месте';

  @override
  String get svcDocumentsDesc => 'Файлы и заключения';

  @override
  String get svcClinicsDesc => 'Карта и маршруты';

  @override
  String get telemedTitle => 'Телемедицина скоро появится';

  @override
  String get telemedBody =>
      'Видеоконсультации запланированы в одном из следующих обновлений. Пока доступна запись на очный приём.';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get statExperience => 'Стаж';

  @override
  String yearsShort(int count) {
    return '$count л.';
  }

  @override
  String routeSummary(String clinic) {
    return 'Маршрут до $clinic';
  }

  @override
  String get selectedLabel => 'Выбрано';

  @override
  String get weekSelectHint => 'Выберите день';

  @override
  String get bookingCancelTitle => 'Выйти из записи?';

  @override
  String get bookingCancelBody => 'Выбранные данные не сохранятся.';

  @override
  String get leave => 'Выйти';

  @override
  String get appointmentPrice => 'Стоимость в клинике';

  @override
  String get viewDoctor => 'Профиль врача';

  @override
  String get showOnMap => 'Показать на карте';

  @override
  String get searchNothing => 'Ничего не найдено';

  @override
  String get reviewSubmitted => 'Отзыв отправлен';

  @override
  String get rateStars => 'Нажмите на звезду для оценки';

  @override
  String get medRecordOpen => 'Открыть медицинскую карту';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get profileStatsTitle => 'Обзор';

  @override
  String get themeTitle => 'Тема';

  @override
  String get languageSaved => 'Язык изменён';

  @override
  String get deleteNotification => 'Удалить уведомление';
}
