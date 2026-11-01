import '../../core/utils/formatters.dart';
import '../../core/utils/localized_text.dart';
import '../../features/analyses/domain/lab_result.dart';
import '../../features/appointments/domain/appointment.dart';
import '../../features/auth/domain/patient_profile.dart';
import '../../features/documents/domain/medical_document.dart';
import '../../features/medical_record/domain/medical_entry.dart';
import '../../features/notifications/domain/app_notification.dart';
import 'demo_catalog_seed.dart';

/// Credentials of the pre-created demo account (shown on the login screen).
abstract final class DemoAccount {
  static const phone = '+77000000001';
  static const password = 'Demo1234';
  static const otp = '1111';
}

LocalizedText _t(String ru, String en, String kk) => LocalizedText(ru: ru, en: en, kk: kk);

PatientProfile demoPatient() => PatientProfile(
      id: 'p1',
      fullName: 'Петров Алексей Сергеевич',
      phone: DemoAccount.phone,
      email: 'demo.patient@example.com',
      birthDate: DateTime(1993, 4, 17),
      gender: Gender.male,
      bloodType: 'A(II) Rh+',
      city: 'Астана',
      avatarSeed: 101,
    );

/// Moves [day] to the closest working day of [doctorId] in [direction].
DateTime _onWorkday(String doctorId, DateTime day, int direction) {
  final schedule = demoSchedules[doctorId]!;
  var d = day;
  while (!schedule.workDays.contains(d.weekday)) {
    d = d.add(Duration(days: direction));
  }
  return d;
}

DateTime _at(String doctorId, DateTime now, int dayOffset, int hour, int minute) {
  final base = Dates.dateOnly(now).add(Duration(days: dayOffset));
  final d = _onWorkday(doctorId, base, dayOffset >= 0 ? 1 : -1);
  return DateTime(d.year, d.month, d.day, hour, minute);
}

class PatientSeed {
  PatientSeed(this.now);
  final DateTime now;

  late final List<Appointment> appointments = _appointments();
  late final List<LabResult> labs = _labs();
  late final List<LabOrder> orders = _orders();
  late final List<MedicalDocument> documents = _documents();
  late final List<MedicalEntry> entries = _entries();
  late final List<AppNotification> notifications = _notifications();
  final Set<String> favorites = {'d1', 'd2', 'd5'};

  Appointment _appt(
    int n,
    String doctorId,
    DateTime start,
    AppointmentStatus status,
    String reason, {
    int? rating,
    String? cancelReason,
  }) {
    final doctor = demoDoctors.firstWhere((d) => d.id == doctorId);
    final schedule = demoSchedules[doctorId]!;
    return Appointment(
      id: 'a$n',
      number: 'AM-${_ymd(start)}-${(1000 + n).toString()}',
      doctorId: doctorId,
      clinicId: doctor.clinicId,
      start: start,
      durationMinutes: schedule.slotMinutes,
      status: status,
      reason: reason,
      priceKzt: doctor.priceKzt,
      createdAt: start.subtract(const Duration(days: 5)),
      reviewRating: rating,
      cancelReason: cancelReason,
    );
  }

  static String _ymd(DateTime d) =>
      '${(d.year % 100).toString().padLeft(2, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  List<Appointment> _appointments() => [
        _appt(1, 'd1', _at('d1', now, 1, 10, 30), AppointmentStatus.confirmed, 'Плановый осмотр'),
        _appt(2, 'd2', _at('d2', now, 6, 15, 0), AppointmentStatus.confirmed, 'Консультация по давлению'),
        _appt(3, 'd3', _at('d3', now, -12, 11, 20), AppointmentStatus.completed, 'Головные боли', rating: 5),
        _appt(4, 'd1', _at('d1', now, -40, 9, 30), AppointmentStatus.completed, 'Общее недомогание'),
        _appt(5, 'd4', _at('d4', now, -90, 16, 0), AppointmentStatus.completed, 'Контроль щитовидной железы', rating: 4),
        _appt(6, 'd6', _at('d6', now, -8, 12, 0), AppointmentStatus.cancelled, 'Профилактический осмотр',
            cancelReason: 'Изменились планы'),
      ];

  DateTime _daysAgo(int days) => Dates.dateOnly(now).subtract(Duration(days: days));

  LabIndicator _i(String ru, String en, String kk, double v, String unit, {double? min, double? max}) =>
      LabIndicator(name: _t(ru, en, kk), value: v, unit: unit, refMin: min, refMax: max);

  LabStatus _statusFor(List<LabIndicator> ind) =>
      ind.any((i) => i.isOutOfRange) ? LabStatus.attention : LabStatus.ready;

  LabResult _lab(
    String id,
    String code,
    LabCategory cat,
    LocalizedText name,
    int daysAgo,
    String lab,
    List<LabIndicator> ind, {
    String? documentId,
  }) =>
      LabResult(
        id: id,
        testCode: code,
        category: cat,
        name: name,
        date: _daysAgo(daysAgo),
        laboratory: lab,
        status: _statusFor(ind),
        indicators: ind,
        documentId: documentId,
      );

  List<LabResult> _labs() {
    const cbcName = LocalizedText(ru: 'Общий анализ крови', en: 'Complete blood count', kk: 'Қанның жалпы талдауы');
    List<LabIndicator> cbc(double hb, double wbc, double plt, double esr) => [
          _i('Гемоглобин', 'Hemoglobin', 'Гемоглобин', hb, 'г/л', min: 130, max: 170),
          _i('Лейкоциты', 'Leukocytes', 'Лейкоциттер', wbc, '10⁹/л', min: 4, max: 9),
          _i('Тромбоциты', 'Platelets', 'Тромбоциттер', plt, '10⁹/л', min: 150, max: 400),
          _i('СОЭ', 'ESR', 'ЭТЖ', esr, 'мм/ч', min: 2, max: 15),
        ];
    return [
      _lab('l1', 'cbc', LabCategory.cbc, cbcName, 200, 'Лаборатория «Аналит» · DEMO', cbc(138, 6.8, 240, 9)),
      _lab('l2', 'cbc', LabCategory.cbc, cbcName, 90, 'Лаборатория «Аналит» · DEMO', cbc(142, 7.4, 255, 11)),
      _lab('l3', 'cbc', LabCategory.cbc, cbcName, 14, 'Лаборатория «Аналит» · DEMO', cbc(146, 6.2, 262, 17)),
      _lab(
        'l4', 'biochem', LabCategory.biochemistry,
        _t('Биохимический анализ крови', 'Blood chemistry panel', 'Қанның биохимиялық талдауы'),
        14, 'Лаборатория «Аналит» · DEMO',
        [
          _i('Глюкоза', 'Glucose', 'Глюкоза', 5.2, 'ммоль/л', min: 3.9, max: 5.6),
          _i('Общий холестерин', 'Total cholesterol', 'Жалпы холестерин', 5.9, 'ммоль/л', max: 5.2),
          _i('АЛТ', 'ALT', 'АЛТ', 28, 'Ед/л', max: 41),
          _i('Креатинин', 'Creatinine', 'Креатинин', 84, 'мкмоль/л', min: 62, max: 106),
        ],
      ),
      _lab(
        'l5', 'urine', LabCategory.urine,
        _t('Общий анализ мочи', 'Urinalysis', 'Несептің жалпы талдауы'),
        30, 'Лаборатория «Аналит» · DEMO',
        [
          _i('Удельный вес', 'Specific gravity', 'Меншікті салмақ', 1.016, '', min: 1.010, max: 1.025),
          _i('pH', 'pH', 'pH', 6.0, '', min: 5.0, max: 7.0),
          _i('Белок', 'Protein', 'Ақуыз', 0.0, 'г/л', max: 0.033),
        ],
      ),
      _lab(
        'l6', 'tsh', LabCategory.hormones,
        _t('Гормоны щитовидной железы', 'Thyroid hormones', 'Қалқанша без гормондары'),
        60, 'Лаборатория «Аналит» · DEMO',
        [
          _i('ТТГ', 'TSH', 'ТТГ', 2.1, 'мМЕ/л', min: 0.4, max: 4.0),
          _i('Свободный Т4', 'Free T4', 'Бос Т4', 14.8, 'пмоль/л', min: 9, max: 19),
        ],
      ),
      _lab(
        'l7', 'vitd', LabCategory.vitamins,
        _t('Витамин D (25-OH)', 'Vitamin D (25-OH)', 'D витамині (25-OH)'),
        200, 'Лаборатория «Аналит» · DEMO',
        [_i('25-OH витамин D', '25-OH vitamin D', '25-OH D витамині', 28, 'нг/мл', min: 30, max: 100)],
      ),
      _lab(
        'l8', 'vitd', LabCategory.vitamins,
        _t('Витамин D (25-OH)', 'Vitamin D (25-OH)', 'D витамині (25-OH)'),
        20, 'Лаборатория «Аналит» · DEMO',
        [_i('25-OH витамин D', '25-OH vitamin D', '25-OH D витамині', 22, 'нг/мл', min: 30, max: 100)],
      ),
      _lab(
        'l9', 'ige', LabCategory.immunology,
        _t('Иммуноглобулин E общий', 'Total immunoglobulin E', 'Жалпы иммуноглобулин E'),
        45, 'Лаборатория «Аналит» · DEMO',
        [_i('IgE общий', 'Total IgE', 'Жалпы IgE', 45, 'МЕ/мл', max: 100)],
      ),
      LabResult(
        id: 'l10', testCode: 'pcr-flu', category: LabCategory.pcr,
        name: _t('ПЦР: грипп A/B', 'PCR: influenza A/B', 'ПТР: грипп A/B'),
        date: _daysAgo(1), laboratory: 'Лаборатория «Аналит» · DEMO', status: LabStatus.processing,
      ),
      LabResult(
        id: 'l11', testCode: 'ecg', category: LabCategory.other,
        name: _t('ЭКГ в покое', 'Resting ECG', 'Тыныштықтағы ЭКГ'),
        date: _daysAgo(12), laboratory: 'Диагностический центр · DEMO', status: LabStatus.ready,
        documentId: 'doc2',
      ),
    ];
  }

  List<LabOrder> _orders() => [
        LabOrder(
          id: 'o1', category: LabCategory.biochemistry,
          name: _t('Липидный профиль', 'Lipid profile', 'Липидті профиль'),
          doctorName: 'Смирнов А. И.', date: _daysAgo(1), status: LabStatus.pending,
        ),
        LabOrder(
          id: 'o2', category: LabCategory.hormones,
          name: _t('Гликированный гемоглобин (HbA1c)', 'Glycated hemoglobin (HbA1c)', 'Гликирленген гемоглобин (HbA1c)'),
          doctorName: 'Орлова Е. А.', date: _daysAgo(3), status: LabStatus.processing,
        ),
        LabOrder(
          id: 'o3', category: LabCategory.vitamins,
          name: _t('Ферритин', 'Ferritin', 'Ферритин'),
          doctorName: 'Смирнов А. И.', date: _daysAgo(1), status: LabStatus.pending,
        ),
      ];

  List<MedicalDocument> _documents() => [
        MedicalDocument(
          id: 'doc1', title: 'Заключение невролога (DEMO)', kind: DocumentKind.conclusion,
          fileName: 'neurologist_conclusion_demo.pdf', mimeType: 'application/pdf', sizeBytes: 182400,
          uploadedAt: _daysAgo(12),
          previewText: _t(
            'ДЕМО-ДОКУМЕНТ. Синтетические данные.\nКонсультация невролога. Жалобы: головные боли напряжения. Осмотр без очаговой симптоматики. Рекомендации: режим сна, повторная консультация через 4 недели.',
            'DEMO DOCUMENT. Synthetic data.\nNeurologist consultation. Complaint: tension-type headaches. No focal findings. Recommendations: sleep routine, follow-up in 4 weeks.',
            'ДЕМО-ҚҰЖАТ. Синтетикалық деректер.\nНевролог кеңесі. Шағым: шиеленіс бас ауруы. Ошақтық белгілер жоқ. Ұсыныс: ұйқы режимі, 4 аптадан кейін қайта кеңес.',
          ),
        ),
        MedicalDocument(
          id: 'doc2', title: 'ЭКГ в покое (DEMO)', kind: DocumentKind.labReport,
          fileName: 'ecg_demo.pdf', mimeType: 'application/pdf', sizeBytes: 421000,
          uploadedAt: _daysAgo(12),
          previewText: _t(
            'ДЕМО-ДОКУМЕНТ. Синтетические данные.\nЭКГ в покое. ЧСС 68 уд/мин. Заключение даёт врач при очном приёме.',
            'DEMO DOCUMENT. Synthetic data.\nResting ECG. Heart rate 68 bpm. The conclusion is provided by the doctor at the visit.',
            'ДЕМО-ҚҰЖАТ. Синтетикалық деректер.\nТыныштықтағы ЭКГ. ЖСЖ 68 соғу/мин. Қорытындыны дәрігер қабылдауда береді.',
          ),
        ),
        MedicalDocument(
          id: 'doc3', title: 'Рецепт (DEMO)', kind: DocumentKind.prescription,
          fileName: 'prescription_demo.pdf', mimeType: 'application/pdf', sizeBytes: 90300,
          uploadedAt: _daysAgo(40),
          previewText: _t(
            'ДЕМО-ДОКУМЕНТ. Синтетические данные.\nЭлектронный рецепт: витамин D3, по назначению врача. Не является реальным рецептом.',
            'DEMO DOCUMENT. Synthetic data.\nElectronic prescription: vitamin D3 as directed by the doctor. Not a real prescription.',
            'ДЕМО-ҚҰЖАТ. Синтетикалық деректер.\nЭлектрондық рецепт: D3 витамині, дәрігер тағайындауымен. Нақты рецепт емес.',
          ),
        ),
        MedicalDocument(
          id: 'doc4', title: 'Направление на анализы (DEMO)', kind: DocumentKind.referral,
          fileName: 'referral_demo.pdf', mimeType: 'application/pdf', sizeBytes: 64800,
          uploadedAt: _daysAgo(1),
          previewText: _t(
            'ДЕМО-ДОКУМЕНТ. Синтетические данные.\nНаправление: липидный профиль, ферритин.',
            'DEMO DOCUMENT. Synthetic data.\nReferral: lipid profile, ferritin.',
            'ДЕМО-ҚҰЖАТ. Синтетикалық деректер.\nЖолдама: липидті профиль, ферритин.',
          ),
        ),
      ];

  List<MedicalEntry> _entries() {
    final a = appointments;
    MedicalEntry e(String id, MedicalEntryType type, DateTime date, LocalizedText title, String ref,
            {LocalizedText? details, String? doctor}) =>
        MedicalEntry(id: id, type: type, date: date, title: title, sourceRef: ref, details: details, doctorName: doctor);
    return [
      e('m1', MedicalEntryType.visit, a[2].start, _t('Приём невролога', 'Neurologist visit', 'Невролог қабылдауы'), a[2].number,
          details: _t('Жалобы на головные боли.', 'Complaints of headaches.', 'Бас ауруына шағым.'), doctor: 'Кузнецов П. В.'),
      e('m2', MedicalEntryType.diagnosis, a[2].start, _t('Головная боль напряжения (G44.2)', 'Tension-type headache (G44.2)', 'Шиеленіс бас ауруы (G44.2)'),
          a[2].number, doctor: 'Кузнецов П. В.'),
      e('m3', MedicalEntryType.visit, a[3].start, _t('Приём терапевта', 'GP visit', 'Терапевт қабылдауы'), a[3].number,
          doctor: 'Смирнов А. И.'),
      e('m4', MedicalEntryType.prescription, a[3].start, _t('Витамин D3 — по назначению врача', 'Vitamin D3 as directed by the doctor', 'D3 витамині — дәрігер тағайындауымен'),
          'doc3', details: _t('Приём согласно рецепту.', 'Take according to the prescription.', 'Рецепт бойынша қабылдау.'), doctor: 'Смирнов А. И.'),
      e('m5', MedicalEntryType.visit, a[4].start, _t('Приём эндокринолога', 'Endocrinologist visit', 'Эндокринолог қабылдауы'), a[4].number,
          doctor: 'Орлова Е. А.'),
      e('m6', MedicalEntryType.allergy, DateTime(2019, 5, 12), _t('Аллергия: пыльца берёзы', 'Allergy: birch pollen', 'Аллергия: қайың тозаңы'),
          'doc1', details: _t('Сезонные проявления весной.', 'Seasonal symptoms in spring.', 'Көктемде маусымдық көріністер.')),
      e('m7', MedicalEntryType.chronic, DateTime(2021, 9, 3), _t('Хронический гастрит (K29.5)', 'Chronic gastritis (K29.5)', 'Созылмалы гастрит (K29.5)'),
          'doc1', doctor: 'Волкова О. Д.'),
      e('m8', MedicalEntryType.pastIllness, DateTime(2012, 2, 20), _t('Острый бронхит', 'Acute bronchitis', 'Жедел бронхит'), 'doc1'),
      e('m9', MedicalEntryType.procedure, _daysAgo(12), _t('ЭКГ в покое', 'Resting ECG', 'Тыныштықтағы ЭКГ'), 'doc2', doctor: 'Иванова М. С.'),
      e('m10', MedicalEntryType.vaccination, DateTime(2024, 10, 8), _t('Вакцинация против гриппа', 'Influenza vaccination', 'Тұмауға қарсы вакцинация'), 'doc1'),
      e('m11', MedicalEntryType.vaccination, DateTime(2023, 3, 15), _t('Ревакцинация АКДС-Адс-М', 'Td booster', 'АКДС-Адс-М ревакцинациясы'), 'doc1'),
      e('m12', MedicalEntryType.lab, _daysAgo(14), _t('Биохимический анализ крови', 'Blood chemistry panel', 'Қанның биохимиялық талдауы'), 'l4'),
      e('m13', MedicalEntryType.document, _daysAgo(12), _t('Заключение невролога', 'Neurologist conclusion', 'Невролог қорытындысы'), 'doc1', doctor: 'Кузнецов П. В.'),
    ];
  }

  List<AppNotification> _notifications() {
    final next = appointments[0];
    return [
      AppNotification(
        id: 'n1', type: NotificationType.appointmentReminder,
        createdAt: now.subtract(const Duration(hours: 2)),
        params: {'doctor': 'Смирнов А. И.', 'start': next.start.toIso8601String()},
        route: '/appointments/${next.id}',
      ),
      AppNotification(
        id: 'n2', type: NotificationType.labReady, createdAt: now.subtract(const Duration(days: 1)),
        params: {'test': 'l4'}, route: '/analyses/l4',
      ),
      AppNotification(
        id: 'n3', type: NotificationType.newPrescription, createdAt: now.subtract(const Duration(days: 3)),
        params: {'doctor': 'Смирнов А. И.'}, route: '/medical-record', read: true,
      ),
      AppNotification(
        id: 'n4', type: NotificationType.scheduleChanged, createdAt: now.subtract(const Duration(days: 5)),
        params: {'doctor': 'Иванова М. С.'}, route: '/doctors/d2', read: true,
      ),
    ];
  }
}
