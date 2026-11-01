import '../../core/utils/localized_text.dart';
import '../../features/catalog/domain/clinic.dart';
import '../../features/catalog/domain/doctor.dart';
import '../../features/catalog/domain/specialty.dart';

/// Synthetic demo catalog. Every entity is fictional (DEMO) and must never
/// be presented as real people or institutions.
LocalizedText _t(String ru, String en, String kk) => LocalizedText(ru: ru, en: en, kk: kk);

ClinicService _s(String ru, String en, String kk, int price) =>
    ClinicService(name: _t(ru, en, kk), priceKzt: price);

final List<Clinic> demoClinics = [
  Clinic(
    id: 'c1',
    name: 'Медицинский центр «Здоровье» · DEMO',
    city: 'Астана',
    address: 'ул. Достык, 12',
    latitude: 51.1282,
    longitude: 71.4304,
    phone: '+77172000001',
    rating: 4.8,
    reviewsCount: 412,
    workingHours: _t('Пн–Пт 08:00–20:00, Сб 09:00–15:00', 'Mon–Fri 08:00–20:00, Sat 09:00–15:00',
        'Дс–Жм 08:00–20:00, Сб 09:00–15:00'),
    services: [
      _s('Приём терапевта', 'General practitioner visit', 'Терапевт қабылдауы', 12000),
      _s('ЭКГ', 'ECG', 'ЭКГ', 6000),
      _s('УЗИ брюшной полости', 'Abdominal ultrasound', 'Құрсақ қуысының УДЗ', 9000),
    ],
    imageSeed: 1,
  ),
  Clinic(
    id: 'c2',
    name: 'Клиника «Алатау» · DEMO',
    city: 'Алматы',
    address: 'пр. Аль-Фараби, 77',
    latitude: 43.2220,
    longitude: 76.9286,
    phone: '+77272000002',
    rating: 4.7,
    reviewsCount: 288,
    workingHours: _t('Ежедневно 08:00–21:00', 'Daily 08:00–21:00', 'Күн сайын 08:00–21:00'),
    services: [
      _s('Консультация кардиолога', 'Cardiologist consultation', 'Кардиолог кеңесі', 18000),
      _s('Эхокардиография', 'Echocardiography', 'Эхокардиография', 15000),
      _s('Холтер-мониторинг', 'Holter monitoring', 'Холтер-мониторинг', 17000),
    ],
    imageSeed: 2,
  ),
  Clinic(
    id: 'c3',
    name: 'Семейная клиника «Сункар» · DEMO',
    city: 'Астана',
    address: 'ул. Кенесары, 40',
    latitude: 51.1655,
    longitude: 71.4272,
    phone: '+77172000003',
    rating: 4.6,
    reviewsCount: 175,
    workingHours: _t('Пн–Сб 09:00–19:00', 'Mon–Sat 09:00–19:00', 'Дс–Сб 09:00–19:00'),
    services: [
      _s('Приём педиатра', 'Pediatrician visit', 'Педиатр қабылдауы', 10000),
      _s('Вакцинация', 'Vaccination', 'Вакцинация', 5000),
      _s('Консультация невролога', 'Neurologist consultation', 'Невролог кеңесі', 16000),
    ],
    imageSeed: 3,
  ),
  Clinic(
    id: 'c4',
    name: 'Центр «Нұр Мед» · DEMO',
    city: 'Алматы',
    address: 'ул. Толе би, 101',
    latitude: 43.2550,
    longitude: 76.9300,
    phone: '+77272000004',
    rating: 4.5,
    reviewsCount: 132,
    workingHours: _t('Пн–Пт 08:30–18:30', 'Mon–Fri 08:30–18:30', 'Дс–Жм 08:30–18:30'),
    services: [
      _s('Консультация эндокринолога', 'Endocrinologist consultation', 'Эндокринолог кеңесі', 17000),
      _s('УЗИ щитовидной железы', 'Thyroid ultrasound', 'Қалқанша безінің УДЗ', 8000),
    ],
    imageSeed: 4,
  ),
  Clinic(
    id: 'c5',
    name: 'Диагностический центр «Жібек жолы» · DEMO',
    city: 'Астана',
    address: 'пр. Туран, 37',
    latitude: 51.1198,
    longitude: 71.4180,
    phone: '+77172000005',
    rating: 4.9,
    reviewsCount: 520,
    workingHours: _t('Ежедневно 07:30–20:00', 'Daily 07:30–20:00', 'Күн сайын 07:30–20:00'),
    services: [
      _s('Консультация офтальмолога', 'Ophthalmologist consultation', 'Офтальмолог кеңесі', 15000),
      _s('Проверка зрения', 'Vision test', 'Көру тексеруі', 7000),
      _s('Консультация дерматолога', 'Dermatologist consultation', 'Дерматолог кеңесі', 14000),
    ],
    imageSeed: 5,
  ),
  Clinic(
    id: 'c6',
    name: 'Клиника «Эдельвейс» · DEMO',
    city: 'Алматы',
    address: 'ул. Сатпаева, 22',
    latitude: 43.2380,
    longitude: 76.9450,
    phone: '+77272000006',
    rating: 4.6,
    reviewsCount: 204,
    workingHours: _t('Пн–Сб 09:00–20:00', 'Mon–Sat 09:00–20:00', 'Дс–Сб 09:00–20:00'),
    services: [
      _s('Приём стоматолога', 'Dentist visit', 'Стоматолог қабылдауы', 9000),
      _s('Профессиональная гигиена', 'Professional cleaning', 'Кәсіби гигиена', 18000),
      _s('Приём педиатра', 'Pediatrician visit', 'Педиатр қабылдауы', 12000),
    ],
    imageSeed: 6,
  ),
];

Doctor _d({
  required String id,
  required String name,
  required Specialty sp,
  required String clinic,
  required int exp,
  required double rating,
  required int reviews,
  required int price,
  required LocalizedText education,
  required LocalizedText qualification,
  required LocalizedText about,
  required List<String> languages,
  required List<ClinicService> services,
  bool female = false,
}) =>
    Doctor(
      id: id,
      fullName: name,
      specialty: sp,
      clinicId: clinic,
      experienceYears: exp,
      rating: rating,
      reviewsCount: reviews,
      priceKzt: price,
      education: education,
      qualification: qualification,
      about: about,
      languages: languages,
      services: services,
      avatarSeed: int.parse(id.substring(1)),
      isFemale: female,
    );

final List<Doctor> demoDoctors = [
  _d(
    id: 'd1', name: 'Смирнов Алексей Иванович', sp: Specialty.therapist, clinic: 'c1',
    exp: 12, rating: 4.9, reviews: 128, price: 12000,
    education: _t('Национальный медицинский университет, лечебное дело', 'National Medical University, General Medicine', 'Ұлттық медицина университеті, емдеу ісі'),
    qualification: _t('Врач высшей категории', 'Highest category physician', 'Жоғары санатты дәрігер'),
    about: _t('Профилактика, диагностика и лечение заболеваний внутренних органов. Индивидуальный подход к каждому пациенту.', 'Prevention, diagnostics and treatment of internal diseases. An individual approach to every patient.', 'Ішкі ағза ауруларының алдын алу, диагностикасы және емдеу. Әр пациентке жеке көзқарас.'),
    languages: ['ru', 'kk', 'en'],
    services: [
      _s('Первичный приём терапевта', 'Initial GP consultation', 'Терапевттің алғашқы қабылдауы', 12000),
      _s('Повторный приём', 'Follow-up visit', 'Қайта қабылдау', 9000),
      _s('Профилактический осмотр', 'Preventive check-up', 'Профилактикалық тексеру', 14000),
    ],
  ),
  _d(
    id: 'd2', name: 'Иванова Мария Сергеевна', sp: Specialty.cardiologist, clinic: 'c2',
    exp: 15, rating: 4.8, reviews: 96, price: 18000, female: true,
    education: _t('Казахский национальный медицинский университет, кардиология', 'Kazakh National Medical University, Cardiology', 'Қазақ ұлттық медицина университеті, кардиология'),
    qualification: _t('Кандидат медицинских наук', 'Candidate of Medical Sciences', 'Медицина ғылымдарының кандидаты'),
    about: _t('Диагностика и наблюдение пациентов с нарушениями ритма и артериальной гипертензией.', 'Diagnostics and follow-up of patients with rhythm disorders and arterial hypertension.', 'Ырғақ бұзылыстары мен артериялық гипертензиясы бар пациенттерді диагностикалау және бақылау.'),
    languages: ['ru', 'en'],
    services: [
      _s('Консультация кардиолога', 'Cardiologist consultation', 'Кардиолог кеңесі', 18000),
      _s('ЭКГ с расшифровкой', 'ECG with report', 'ЭКГ қорытындымен', 8000),
    ],
  ),
  _d(
    id: 'd3', name: 'Кузнецов Пётр Васильевич', sp: Specialty.neurologist, clinic: 'c3',
    exp: 10, rating: 4.7, reviews: 74, price: 16000,
    education: _t('Медицинский университет Астана, неврология', 'Astana Medical University, Neurology', 'Астана медицина университеті, неврология'),
    qualification: _t('Врач первой категории', 'First category physician', 'Бірінші санатты дәрігер'),
    about: _t('Консультирует пациентов с головными болями, нарушениями сна и болями в спине.', 'Consults patients with headaches, sleep disorders and back pain.', 'Бас ауруы, ұйқы бұзылыстары және арқа ауруы бар пациенттерге кеңес береді.'),
    languages: ['ru', 'kk'],
    services: [
      _s('Консультация невролога', 'Neurologist consultation', 'Невролог кеңесі', 16000),
      _s('Повторная консультация', 'Follow-up consultation', 'Қайта кеңес', 11000),
    ],
  ),
  _d(
    id: 'd4', name: 'Орлова Елена Андреевна', sp: Specialty.endocrinologist, clinic: 'c4',
    exp: 9, rating: 4.9, reviews: 52, price: 17000, female: true,
    education: _t('Алматинский государственный медицинский институт', 'Almaty State Medical Institute', 'Алматы мемлекеттік медицина институты'),
    qualification: _t('Врач высшей категории', 'Highest category physician', 'Жоғары санатты дәрігер'),
    about: _t('Наблюдение пациентов с заболеваниями щитовидной железы и нарушениями обмена веществ.', 'Follow-up of patients with thyroid conditions and metabolic disorders.', 'Қалқанша безі аурулары мен зат алмасу бұзылыстары бар пациенттерді бақылау.'),
    languages: ['ru', 'en'],
    services: [
      _s('Консультация эндокринолога', 'Endocrinologist consultation', 'Эндокринолог кеңесі', 17000),
      _s('УЗИ щитовидной железы', 'Thyroid ultrasound', 'Қалқанша безінің УДЗ', 8000),
    ],
  ),
  _d(
    id: 'd5', name: 'Нурланова Айгерим Булатовна', sp: Specialty.pediatrician, clinic: 'c3',
    exp: 8, rating: 4.9, reviews: 210, price: 10000, female: true,
    education: _t('Казахский национальный медицинский университет, педиатрия', 'Kazakh National Medical University, Pediatrics', 'Қазақ ұлттық медицина университеті, педиатрия'),
    qualification: _t('Врач первой категории', 'First category physician', 'Бірінші санатты дәрігер'),
    about: _t('Ведёт детей с рождения: профилактические осмотры, вакцинация, консультации для родителей.', 'Cares for children from birth: check-ups, vaccination and parent guidance.', 'Балаларды туғаннан бақылайды: профилактикалық тексеру, вакцинация, ата-анаға кеңес.'),
    languages: ['kk', 'ru'],
    services: [
      _s('Приём педиатра', 'Pediatrician visit', 'Педиатр қабылдауы', 10000),
      _s('Вакцинация', 'Vaccination', 'Вакцинация', 5000),
    ],
  ),
  _d(
    id: 'd6', name: 'Сейтқали Данияр Маратұлы', sp: Specialty.dentist, clinic: 'c6',
    exp: 11, rating: 4.8, reviews: 143, price: 15000,
    education: _t('Казахский национальный медицинский университет, стоматология', 'Kazakh National Medical University, Dentistry', 'Қазақ ұлттық медицина университеті, стоматология'),
    qualification: _t('Врач-стоматолог-терапевт', 'Restorative dentist', 'Тіс емдеу дәрігері'),
    about: _t('Лечение кариеса, эстетическая реставрация, профессиональная гигиена полости рта.', 'Caries treatment, aesthetic restoration, professional oral hygiene.', 'Тіс жегісін емдеу, эстетикалық қалпына келтіру, ауыз қуысының кәсіби гигиенасы.'),
    languages: ['kk', 'ru', 'en'],
    services: [
      _s('Осмотр и консультация', 'Examination and consultation', 'Қарау және кеңес', 9000),
      _s('Лечение кариеса', 'Caries treatment', 'Тіс жегісін емдеу', 25000),
      _s('Профессиональная гигиена', 'Professional cleaning', 'Кәсіби гигиена', 18000),
    ],
  ),
  _d(
    id: 'd7', name: 'Ахметова Динара Ерлановна', sp: Specialty.dermatologist, clinic: 'c5',
    exp: 7, rating: 4.6, reviews: 61, price: 14000, female: true,
    education: _t('Медицинский университет Караганды', 'Karaganda Medical University', 'Қарағанды медицина университеті'),
    qualification: _t('Врач-дерматовенеролог', 'Dermatovenerologist', 'Дерматовенеролог'),
    about: _t('Диагностика кожных заболеваний, осмотр родинок, консультации по уходу за кожей.', 'Diagnostics of skin conditions, mole examination, skin care guidance.', 'Тері ауруларын диагностикалау, меңдерді қарау, тері күтімі бойынша кеңес.'),
    languages: ['ru', 'kk'],
    services: [
      _s('Консультация дерматолога', 'Dermatologist consultation', 'Дерматолог кеңесі', 14000),
      _s('Дерматоскопия', 'Dermatoscopy', 'Дерматоскопия', 8000),
    ],
  ),
  _d(
    id: 'd8', name: 'Беков Асхат Нурланович', sp: Specialty.ophthalmologist, clinic: 'c5',
    exp: 14, rating: 4.8, reviews: 88, price: 15000,
    education: _t('Казахский национальный медицинский университет, офтальмология', 'Kazakh National Medical University, Ophthalmology', 'Қазақ ұлттық медицина университеті, офтальмология'),
    qualification: _t('Кандидат медицинских наук', 'Candidate of Medical Sciences', 'Медицина ғылымдарының кандидаты'),
    about: _t('Подбор очков и линз, диагностика заболеваний глаз, наблюдение при глаукоме.', 'Glasses and lens fitting, eye disease diagnostics, glaucoma follow-up.', 'Көзілдірік пен линза таңдау, көз ауруларын диагностикалау, глаукомада бақылау.'),
    languages: ['ru', 'kk', 'en'],
    services: [
      _s('Консультация офтальмолога', 'Ophthalmologist consultation', 'Офтальмолог кеңесі', 15000),
      _s('Проверка зрения', 'Vision test', 'Көру тексеруі', 7000),
    ],
  ),
  _d(
    id: 'd9', name: 'Волкова Ольга Дмитриевна', sp: Specialty.therapist, clinic: 'c1',
    exp: 20, rating: 4.7, reviews: 301, price: 9000, female: true,
    education: _t('Первый медицинский институт, лечебное дело', 'First Medical Institute, General Medicine', 'Бірінші медицина институты, емдеу ісі'),
    qualification: _t('Врач высшей категории', 'Highest category physician', 'Жоғары санатты дәрігер'),
    about: _t('Многолетний опыт ведения пациентов с хроническими заболеваниями и диспансеризации.', 'Many years of experience managing chronic conditions and routine health screening.', 'Созылмалы ауруларды жүргізу және диспансерлеу бойынша көпжылдық тәжірибе.'),
    languages: ['ru'],
    services: [
      _s('Приём терапевта', 'GP consultation', 'Терапевт қабылдауы', 9000),
      _s('Диспансеризация', 'Health screening', 'Диспансеризация', 15000),
    ],
  ),
  _d(
    id: 'd10', name: 'Жумабаев Ерлан Кайратович', sp: Specialty.cardiologist, clinic: 'c2',
    exp: 18, rating: 4.9, reviews: 177, price: 22000,
    education: _t('Национальный научный кардиохирургический центр, ординатура', 'National Scientific Cardiac Surgery Center, residency', 'Ұлттық ғылыми кардиохирургия орталығы, ординатура'),
    qualification: _t('Доктор медицинских наук', 'Doctor of Medical Sciences', 'Медицина ғылымдарының докторы'),
    about: _t('Эксперт по сложным нарушениям ритма и сердечной недостаточности.', 'Expert in complex rhythm disorders and heart failure.', 'Күрделі ырғақ бұзылыстары мен жүрек жеткіліксіздігі бойынша сарапшы.'),
    languages: ['kk', 'ru', 'en'],
    services: [
      _s('Консультация кардиолога', 'Cardiologist consultation', 'Кардиолог кеңесі', 22000),
      _s('Эхокардиография', 'Echocardiography', 'Эхокардиография', 15000),
    ],
  ),
  _d(
    id: 'd11', name: 'Тулеубекова Мадина Алибековна', sp: Specialty.neurologist, clinic: 'c3',
    exp: 6, rating: 4.5, reviews: 33, price: 13000, female: true,
    education: _t('Медицинский университет Семей', 'Semey Medical University', 'Семей медицина университеті'),
    qualification: _t('Врач-невролог', 'Neurologist', 'Невропатолог'),
    about: _t('Консультации при головокружениях, мигрени и последствиях травм.', 'Consultations for dizziness, migraine and post-injury recovery.', 'Бас айналу, мигрень және жарақаттан кейінгі жағдайлар бойынша кеңес.'),
    languages: ['kk', 'ru'],
    services: [_s('Консультация невролога', 'Neurologist consultation', 'Невролог кеңесі', 13000)],
  ),
  _d(
    id: 'd12', name: 'Попов Игорь Николаевич', sp: Specialty.dentist, clinic: 'c6',
    exp: 5, rating: 4.4, reviews: 27, price: 9000,
    education: _t('Медицинский университет Астана, стоматология', 'Astana Medical University, Dentistry', 'Астана медицина университеті, стоматология'),
    qualification: _t('Врач-стоматолог', 'Dentist', 'Тіс дәрігері'),
    about: _t('Первичные осмотры, лечение и профилактика заболеваний зубов.', 'Initial examinations, treatment and prevention of dental disease.', 'Алғашқы қарау, тіс ауруларын емдеу және алдын алу.'),
    languages: ['ru', 'en'],
    services: [_s('Осмотр', 'Examination', 'Қарау', 9000)],
  ),
  _d(
    id: 'd13', name: 'Касымова Сауле Омаровна', sp: Specialty.pediatrician, clinic: 'c6',
    exp: 16, rating: 4.8, reviews: 190, price: 12000, female: true,
    education: _t('Казахский национальный медицинский университет, педиатрия', 'Kazakh National Medical University, Pediatrics', 'Қазақ ұлттық медицина университеті, педиатрия'),
    qualification: _t('Врач высшей категории', 'Highest category physician', 'Жоғары санатты дәрігер'),
    about: _t('Наблюдение здоровых и часто болеющих детей, подготовка к школе и детскому саду.', 'Care for healthy and frequently ill children, school and kindergarten check-ups.', 'Дені сау және жиі ауыратын балаларды бақылау, мектепке дайындық.'),
    languages: ['kk', 'ru'],
    services: [_s('Приём педиатра', 'Pediatrician visit', 'Педиатр қабылдауы', 12000)],
  ),
  _d(
    id: 'd14', name: 'Лим Виктория Эдуардовна', sp: Specialty.dermatologist, clinic: 'c5',
    exp: 10, rating: 4.7, reviews: 84, price: 16000, female: true,
    education: _t('Российский университет дружбы народов, дерматовенерология', 'Peoples’ Friendship University, Dermatovenerology', 'Халықтар достығы университеті, дерматовенерология'),
    qualification: _t('Врач-дерматолог-косметолог', 'Dermatologist-cosmetologist', 'Дерматолог-косметолог'),
    about: _t('Лечение акне, экземы и аллергических реакций кожи.', 'Treatment of acne, eczema and allergic skin reactions.', 'Безеу, экзема және теріге аллергиялық реакцияларды емдеу.'),
    languages: ['ru', 'en'],
    services: [_s('Консультация дерматолога', 'Dermatologist consultation', 'Дерматолог кеңесі', 16000)],
  ),
];

/// Weekly patterns; kept explicit so that every doctor has a distinct schedule.
final Map<String, DoctorSchedule> demoSchedules = {
  'd1': const DoctorSchedule(doctorId: 'd1', workDays: {1, 2, 3, 4, 5}, startMinutes: 540, endMinutes: 1080, slotMinutes: 30, breakStartMinutes: 780, breakEndMinutes: 840),
  'd2': const DoctorSchedule(doctorId: 'd2', workDays: {1, 2, 3, 4, 5, 6}, startMinutes: 600, endMinutes: 1140, slotMinutes: 30, breakStartMinutes: 840, breakEndMinutes: 900),
  'd3': const DoctorSchedule(doctorId: 'd3', workDays: {2, 3, 4, 5, 6}, startMinutes: 540, endMinutes: 960, slotMinutes: 40, breakStartMinutes: 720, breakEndMinutes: 780),
  'd4': const DoctorSchedule(doctorId: 'd4', workDays: {1, 3, 5}, startMinutes: 570, endMinutes: 1020, slotMinutes: 30),
  'd5': const DoctorSchedule(doctorId: 'd5', workDays: {1, 2, 3, 4, 5, 6}, startMinutes: 540, endMinutes: 1020, slotMinutes: 20, breakStartMinutes: 780, breakEndMinutes: 840),
  'd6': const DoctorSchedule(doctorId: 'd6', workDays: {1, 2, 3, 4, 5, 6}, startMinutes: 600, endMinutes: 1200, slotMinutes: 60, breakStartMinutes: 780, breakEndMinutes: 840),
  'd7': const DoctorSchedule(doctorId: 'd7', workDays: {1, 2, 4, 5}, startMinutes: 600, endMinutes: 1080, slotMinutes: 30),
  'd8': const DoctorSchedule(doctorId: 'd8', workDays: {1, 2, 3, 4, 5, 6, 7}, startMinutes: 480, endMinutes: 960, slotMinutes: 30, breakStartMinutes: 720, breakEndMinutes: 780),
  'd9': const DoctorSchedule(doctorId: 'd9', workDays: {1, 2, 3, 4, 5}, startMinutes: 480, endMinutes: 840, slotMinutes: 20),
  'd10': const DoctorSchedule(doctorId: 'd10', workDays: {2, 4, 6}, startMinutes: 600, endMinutes: 1020, slotMinutes: 45),
  'd11': const DoctorSchedule(doctorId: 'd11', workDays: {1, 2, 3, 4, 5}, startMinutes: 600, endMinutes: 1080, slotMinutes: 40),
  'd12': const DoctorSchedule(doctorId: 'd12', workDays: {1, 2, 3, 4, 5, 6}, startMinutes: 660, endMinutes: 1200, slotMinutes: 60),
  'd13': const DoctorSchedule(doctorId: 'd13', workDays: {1, 2, 3, 4, 5, 6}, startMinutes: 540, endMinutes: 1020, slotMinutes: 20),
  'd14': const DoctorSchedule(doctorId: 'd14', workDays: {1, 3, 4, 5}, startMinutes: 600, endMinutes: 1080, slotMinutes: 30),
};


/// Deterministic synthetic reviews.
List<DoctorReview> demoReviewsFor(Doctor d, DateTime now) {
  const authors = ['Айгүл К.', 'Сергей М.', 'Динара А.', 'Ерлан Б.', 'Ольга П.', 'Марат Т.'];
  const texts = [
    'Внимательный врач, всё подробно объяснил(а). Рекомендую.',
    'Приём прошёл вовремя, назначения понятные.',
    'Спасибо за профессиональный подход и чуткое отношение.',
    'Хороший специалист, запись через приложение очень удобна.',
    'Приятная атмосфера, без очередей.',
  ];
  return List.generate(3, (i) {
    final k = (d.avatarSeed * 7 + i * 3) % texts.length;
    return DoctorReview(
      id: 'r${d.id}_$i',
      doctorId: d.id,
      author: '${authors[(d.avatarSeed + i) % authors.length]} · DEMO',
      rating: i == 2 ? 4 : 5,
      text: texts[k],
      date: now.subtract(Duration(days: 12 + i * 23 + d.avatarSeed)),
    );
  });
}
