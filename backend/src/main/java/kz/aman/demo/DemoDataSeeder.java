package kz.aman.demo;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import kz.aman.config.AppProperties;
import kz.aman.domain.Appointment;
import kz.aman.domain.AppointmentStatus;
import kz.aman.domain.Doctor;
import kz.aman.domain.DoctorSchedule;
import kz.aman.domain.FavoriteDoctor;
import kz.aman.domain.LabIndicator;
import kz.aman.domain.LabOrder;
import kz.aman.domain.LabResult;
import kz.aman.domain.Loc;
import kz.aman.domain.MedicalDocument;
import kz.aman.domain.MedicalRecordEntry;
import kz.aman.domain.Notification;
import kz.aman.domain.Patient;
import kz.aman.domain.Role;
import kz.aman.domain.UserAccount;
import kz.aman.repo.AppointmentRepository;
import kz.aman.repo.DoctorRepository;
import kz.aman.repo.DoctorScheduleRepository;
import kz.aman.repo.FavoriteDoctorRepository;
import kz.aman.repo.LabOrderRepository;
import kz.aman.repo.LabResultRepository;
import kz.aman.repo.MedicalDocumentRepository;
import kz.aman.repo.MedicalRecordRepository;
import kz.aman.repo.NotificationRepository;
import kz.aman.repo.PatientRepository;
import kz.aman.repo.UserRepository;
import kz.aman.service.ScheduleCalculator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Seeds a synthetic demo patient (profile {@code demo} only).
 * Everything here is fictional and labelled DEMO; no real personal or medical data.
 */
@Component
@Profile("demo")
public class DemoDataSeeder implements ApplicationRunner {

    public static final String PHONE = "+77000000001";
    public static final String PASSWORD = "Demo1234";
    private static final Logger log = LoggerFactory.getLogger(DemoDataSeeder.class);

    private final UserRepository users;
    private final PatientRepository patients;
    private final DoctorRepository doctors;
    private final DoctorScheduleRepository schedules;
    private final AppointmentRepository appointments;
    private final LabResultRepository labs;
    private final LabOrderRepository orders;
    private final MedicalRecordRepository records;
    private final MedicalDocumentRepository documents;
    private final NotificationRepository notifications;
    private final FavoriteDoctorRepository favorites;
    private final PasswordEncoder encoder;
    private final AppProperties props;
    private final ObjectMapper mapper;

    public DemoDataSeeder(UserRepository users, PatientRepository patients, DoctorRepository doctors,
            DoctorScheduleRepository schedules, AppointmentRepository appointments, LabResultRepository labs,
            LabOrderRepository orders, MedicalRecordRepository records, MedicalDocumentRepository documents,
            NotificationRepository notifications, FavoriteDoctorRepository favorites, PasswordEncoder encoder,
            AppProperties props, ObjectMapper mapper) {
        this.users = users;
        this.patients = patients;
        this.doctors = doctors;
        this.schedules = schedules;
        this.appointments = appointments;
        this.labs = labs;
        this.orders = orders;
        this.records = records;
        this.documents = documents;
        this.notifications = notifications;
        this.favorites = favorites;
        this.encoder = encoder;
        this.props = props;
        this.mapper = mapper;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (users.findByPhone(PHONE).isPresent()) {
            return;
        }
        UserAccount user = new UserAccount(PHONE, encoder.encode(PASSWORD), Role.PATIENT);
        user.setPhoneVerified(true);
        user.setConsentAcceptedAt(Instant.now());
        users.save(user);
        Patient p = new Patient(user, "Петров Алексей Сергеевич");
        p.setEmail("demo.patient@example.com");
        p.setBirthDate(LocalDate.of(1993, 4, 17));
        p.setBloodType("A(II) Rh+");
        p.setCity("Астана");
        p.setAvatarSeed(101);
        patients.save(p);

        List<Appointment> appts = seedAppointments(p);
        Map<String, Long> docIds = seedDocuments(p);
        seedLabs(p, docIds.get("ecg"));
        seedRecords(p, appts, docIds);
        seedNotifications(p, appts.get(0));
        for (long id : new long[] {1, 2, 5}) {
            FavoriteDoctor f = new FavoriteDoctor();
            f.setPatient(p);
            f.setDoctor(doctors.getReferenceById(id));
            favorites.save(f);
        }
        log.info("Demo patient seeded (phone {}).", PHONE);
    }

    // --- appointments ----------------------------------------------------

    private ZoneId zone() {
        return props.booking().zone();
    }

    /** Nearest offered slot at/after {@code hour:minute} on the closest working day. */
    private Instant slot(long doctorId, int dayOffset, int hour, int minute) {
        List<DoctorSchedule> weekly = schedules.findByDoctorId(doctorId);
        LocalDate day = LocalDate.now(zone()).plusDays(dayOffset);
        int step = dayOffset >= 0 ? 1 : -1;
        for (int i = 0; i < 14; i++, day = day.plusDays(step)) {
            Instant wanted = LocalDateTime.of(day, java.time.LocalTime.of(hour, minute)).atZone(zone()).toInstant();
            List<Instant> starts = ScheduleCalculator.templateStarts(weekly, day, zone());
            if (starts.isEmpty()) {
                continue;
            }
            return starts.stream().filter(s -> !s.isBefore(wanted)).findFirst().orElse(starts.get(starts.size() - 1));
        }
        throw new IllegalStateException("No working day for doctor " + doctorId);
    }

    private Appointment appt(Patient p, long doctorId, Instant start, AppointmentStatus status, String reason,
            Integer rating, String cancelReason) {
        Doctor d = doctors.findWithDetailsById(doctorId).orElseThrow();
        int slot = schedules.findByDoctorId(doctorId).get(0).getSlotMinutes();
        Appointment a = new Appointment();
        a.setNumber("TMP-" + UUID.randomUUID().toString().replace("-", "").substring(0, 20));
        a.setPatient(p);
        a.setDoctor(d);
        a.setClinic(d.getClinic());
        a.setStartAt(start);
        a.setDurationMinutes(slot);
        a.setStatus(status);
        a.setReason(reason);
        a.setPriceKzt(d.getPriceKzt());
        a.setCreatedAt(start.minus(java.time.Duration.ofDays(5)));
        a.setReviewRating(rating);
        a.setCancelReason(cancelReason);
        a.setActiveSlotKey(status == AppointmentStatus.CANCELLED ? null : ScheduleCalculator.slotKey(doctorId, start));
        appointments.saveAndFlush(a);
        a.setNumber("AM-" + LocalDate.ofInstant(start, zone()).format(java.time.format.DateTimeFormatter.ofPattern("yyMMdd")) + "-" + (1000 + a.getId()));
        return a;
    }

    private List<Appointment> seedAppointments(Patient p) {
        List<Appointment> list = new ArrayList<>();
        list.add(appt(p, 1, slot(1, 1, 10, 30), AppointmentStatus.CONFIRMED, "Плановый осмотр", null, null));
        list.add(appt(p, 2, slot(2, 6, 15, 0), AppointmentStatus.CONFIRMED, "Консультация по давлению", null, null));
        list.add(appt(p, 3, slot(3, -12, 11, 20), AppointmentStatus.COMPLETED, "Головные боли", 5, null));
        list.add(appt(p, 1, slot(1, -40, 9, 30), AppointmentStatus.COMPLETED, "Общее недомогание", null, null));
        list.add(appt(p, 4, slot(4, -90, 16, 0), AppointmentStatus.COMPLETED, "Контроль щитовидной железы", 4, null));
        list.add(appt(p, 6, slot(6, -8, 12, 0), AppointmentStatus.CANCELLED, "Профилактический осмотр", null, "Изменились планы"));
        return list;
    }

    // --- documents -------------------------------------------------------

    private Map<String, Long> seedDocuments(Patient p) {
        Long neuro = doc(p, "Заключение невролога (DEMO)", "CONCLUSION", "neurologist_conclusion_demo.pdf", 12);
        Long ecg = doc(p, "ЭКГ в покое (DEMO)", "LAB_REPORT", "ecg_demo.pdf", 12);
        Long rx = doc(p, "Рецепт (DEMO)", "PRESCRIPTION", "prescription_demo.pdf", 40);
        doc(p, "Направление на анализы (DEMO)", "REFERRAL", "referral_demo.pdf", 1);
        return Map.of("neuro", neuro, "ecg", ecg, "rx", rx);
    }

    private Long doc(Patient p, String title, String kind, String fileName, int daysAgo) {
        byte[] pdf = demoPdf(title);
        String key = UUID.randomUUID().toString().replace("-", "");
        try {
            Path dir = Path.of(props.storage().dir()).toAbsolutePath().normalize();
            Files.createDirectories(dir);
            Files.write(dir.resolve(key), pdf);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        MedicalDocument d = new MedicalDocument();
        d.setPatient(p);
        d.setTitle(title);
        d.setKind(kind);
        d.setFileName(fileName);
        d.setMimeType("application/pdf");
        d.setSizeBytes(pdf.length);
        d.setStorageKey(key);
        d.setSha256(kz.aman.security.JwtService.sha256(new String(pdf, StandardCharsets.ISO_8859_1)));
        d.setUploadedAt(Instant.now().minus(java.time.Duration.ofDays(daysAgo)));
        d.setUploadedByPatient(false);
        return documents.save(d).getId();
    }

    /** Smallest valid single-page PDF with a DEMO banner. */
    private static byte[] demoPdf(String title) {
        String text = title.replaceAll("[^\\p{ASCII}]", "?").replace("(", "").replace(")", "");
        String stream = "BT /F1 18 Tf 72 720 Td (DEMO DOCUMENT - synthetic data) Tj 0 -28 Td (" + text + ") Tj ET";
        String body = "%PDF-1.4\n"
                + "1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n"
                + "2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n"
                + "3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 595 842]/Contents 4 0 R/Resources<</Font<</F1 5 0 R>>>>>>endobj\n"
                + "4 0 obj<</Length " + stream.length() + ">>stream\n" + stream + "\nendstream endobj\n"
                + "5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj\n"
                + "trailer<</Root 1 0 R/Size 6>>\n%%EOF\n";
        return body.getBytes(StandardCharsets.ISO_8859_1);
    }

    // --- laboratory ------------------------------------------------------

    private LabIndicator ind(LabResult r, String ru, String en, String kk, double v, String unit, Double min, Double max) {
        LabIndicator i = new LabIndicator();
        i.setResult(r);
        i.setName(Loc.of(ru, en, kk));
        i.setValue(v);
        i.setUnit(unit);
        i.setRefMin(min);
        i.setRefMax(max);
        return i;
    }

    private LabResult lab(Patient p, String code, String category, Loc name, int daysAgo, String status, Long documentId) {
        LabResult r = new LabResult();
        r.setPatient(p);
        r.setTestCode(code);
        r.setCategory(category.toUpperCase());
        r.setName(name);
        r.setResultDate(LocalDate.now(zone()).minusDays(daysAgo));
        r.setLaboratory("Лаборатория «Аналит» · DEMO");
        r.setStatus(status);
        r.setDocumentId(documentId);
        return r;
    }

    private void seedLabs(Patient p, Long ecgDocId) {
        Loc cbc = Loc.of("Общий анализ крови", "Complete blood count", "Қанның жалпы талдауы");
        double[][] cbcValues = {{138, 6.8, 240, 9}, {142, 7.4, 255, 11}, {146, 6.2, 262, 17}};
        int[] days = {200, 90, 14};
        for (int k = 0; k < 3; k++) {
            LabResult r = lab(p, "cbc", "cbc", cbc, days[k], "READY", null);
            double[] v = cbcValues[k];
            r.getIndicators().add(ind(r, "Гемоглобин", "Hemoglobin", "Гемоглобин", v[0], "г/л", 130.0, 170.0));
            r.getIndicators().add(ind(r, "Лейкоциты", "Leukocytes", "Лейкоциттер", v[1], "10⁹/л", 4.0, 9.0));
            r.getIndicators().add(ind(r, "Тромбоциты", "Platelets", "Тромбоциттер", v[2], "10⁹/л", 150.0, 400.0));
            r.getIndicators().add(ind(r, "СОЭ", "ESR", "ЭТЖ", v[3], "мм/ч", 2.0, 15.0));
            labs.save(r);
        }
        LabResult bio = lab(p, "biochem", "biochemistry",
                Loc.of("Биохимический анализ крови", "Blood chemistry panel", "Қанның биохимиялық талдауы"), 14, "READY", null);
        bio.getIndicators().add(ind(bio, "Глюкоза", "Glucose", "Глюкоза", 5.2, "ммоль/л", 3.9, 5.6));
        bio.getIndicators().add(ind(bio, "Общий холестерин", "Total cholesterol", "Жалпы холестерин", 5.9, "ммоль/л", null, 5.2));
        bio.getIndicators().add(ind(bio, "АЛТ", "ALT", "АЛТ", 28, "Ед/л", null, 41.0));
        bio.getIndicators().add(ind(bio, "Креатинин", "Creatinine", "Креатинин", 84, "мкмоль/л", 62.0, 106.0));
        labs.save(bio);

        LabResult urine = lab(p, "urine", "urine", Loc.of("Общий анализ мочи", "Urinalysis", "Несептің жалпы талдауы"), 30, "READY", null);
        urine.getIndicators().add(ind(urine, "Удельный вес", "Specific gravity", "Меншікті салмақ", 1.016, "", 1.010, 1.025));
        urine.getIndicators().add(ind(urine, "pH", "pH", "pH", 6.0, "", 5.0, 7.0));
        labs.save(urine);

        LabResult tsh = lab(p, "tsh", "hormones", Loc.of("Гормоны щитовидной железы", "Thyroid hormones", "Қалқанша без гормондары"), 60, "READY", null);
        tsh.getIndicators().add(ind(tsh, "ТТГ", "TSH", "ТТГ", 2.1, "мМЕ/л", 0.4, 4.0));
        labs.save(tsh);

        Loc vitD = Loc.of("Витамин D (25-OH)", "Vitamin D (25-OH)", "D витамині (25-OH)");
        for (int[] x : new int[][] {{200, 28}, {20, 22}}) {
            LabResult r = lab(p, "vitd", "vitamins", vitD, x[0], "READY", null);
            r.getIndicators().add(ind(r, "25-OH витамин D", "25-OH vitamin D", "25-OH D витамині", x[1], "нг/мл", 30.0, 100.0));
            labs.save(r);
        }
        LabResult ige = lab(p, "ige", "immunology", Loc.of("Иммуноглобулин E общий", "Total immunoglobulin E", "Жалпы иммуноглобулин E"), 45, "READY", null);
        ige.getIndicators().add(ind(ige, "IgE общий", "Total IgE", "Жалпы IgE", 45, "МЕ/мл", null, 100.0));
        labs.save(ige);
        labs.save(lab(p, "pcr-flu", "pcr", Loc.of("ПЦР: грипп A/B", "PCR: influenza A/B", "ПТР: грипп A/B"), 1, "PROCESSING", null));
        labs.save(lab(p, "ecg", "other", Loc.of("ЭКГ в покое", "Resting ECG", "Тыныштықтағы ЭКГ"), 12, "READY", ecgDocId));

        order(p, Loc.of("Липидный профиль", "Lipid profile", "Липидті профиль"), "biochemistry", "Смирнов А. И.", 1, "PENDING");
        order(p, Loc.of("Гликированный гемоглобин (HbA1c)", "Glycated hemoglobin (HbA1c)", "Гликирленген гемоглобин (HbA1c)"), "hormones", "Орлова Е. А.", 3, "PROCESSING");
        order(p, Loc.of("Ферритин", "Ferritin", "Ферритин"), "vitamins", "Смирнов А. И.", 1, "PENDING");
    }

    private void order(Patient p, Loc name, String category, String doctor, int daysAgo, String status) {
        LabOrder o = new LabOrder();
        o.setPatient(p);
        o.setName(name);
        o.setCategory(category.toUpperCase());
        o.setDoctorName(doctor);
        o.setOrderDate(LocalDate.now(zone()).minusDays(daysAgo));
        o.setStatus(status);
        orders.save(o);
    }

    // --- record, notifications ------------------------------------------

    private void entry(Patient p, String type, LocalDate date, Loc title, Loc details, String doctor, String ref) {
        MedicalRecordEntry e = new MedicalRecordEntry();
        e.setPatient(p);
        e.setType(type);
        e.setEntryDate(date);
        e.setTitle(title);
        e.setDetails(details);
        e.setDoctorName(doctor);
        e.setSourceRef(ref);
        records.save(e);
    }

    private void seedRecords(Patient p, List<Appointment> a, Map<String, Long> docs) {
        ZoneId z = zone();
        entry(p, "VISIT", LocalDate.ofInstant(a.get(2).getStartAt(), z), Loc.of("Приём невролога", "Neurologist visit", "Невролог қабылдауы"), null, "Кузнецов П. В.", a.get(2).getNumber());
        entry(p, "DIAGNOSIS", LocalDate.ofInstant(a.get(2).getStartAt(), z), Loc.of("Головная боль напряжения (G44.2)", "Tension-type headache (G44.2)", "Шиеленіс бас ауруы (G44.2)"), null, "Кузнецов П. В.", a.get(2).getNumber());
        entry(p, "VISIT", LocalDate.ofInstant(a.get(3).getStartAt(), z), Loc.of("Приём терапевта", "GP visit", "Терапевт қабылдауы"), null, "Смирнов А. И.", a.get(3).getNumber());
        entry(p, "PRESCRIPTION", LocalDate.ofInstant(a.get(3).getStartAt(), z), Loc.of("Витамин D3 — по назначению врача", "Vitamin D3 as directed by the doctor", "D3 витамині — дәрігер тағайындауымен"), null, "Смирнов А. И.", "doc" + docs.get("rx"));
        entry(p, "VISIT", LocalDate.ofInstant(a.get(4).getStartAt(), z), Loc.of("Приём эндокринолога", "Endocrinologist visit", "Эндокринолог қабылдауы"), null, "Орлова Е. А.", a.get(4).getNumber());
        entry(p, "ALLERGY", LocalDate.of(2019, 5, 12), Loc.of("Аллергия: пыльца берёзы", "Allergy: birch pollen", "Аллергия: қайың тозаңы"), null, null, "doc" + docs.get("neuro"));
        entry(p, "CHRONIC", LocalDate.of(2021, 9, 3), Loc.of("Хронический гастрит (K29.5)", "Chronic gastritis (K29.5)", "Созылмалы гастрит (K29.5)"), null, "Волкова О. Д.", "doc" + docs.get("neuro"));
        entry(p, "PAST_ILLNESS", LocalDate.of(2012, 2, 20), Loc.of("Острый бронхит", "Acute bronchitis", "Жедел бронхит"), null, null, "doc" + docs.get("neuro"));
        entry(p, "PROCEDURE", LocalDate.now(z).minusDays(12), Loc.of("ЭКГ в покое", "Resting ECG", "Тыныштықтағы ЭКГ"), null, "Иванова М. С.", "doc" + docs.get("ecg"));
        entry(p, "VACCINATION", LocalDate.of(2024, 10, 8), Loc.of("Вакцинация против гриппа", "Influenza vaccination", "Тұмауға қарсы вакцинация"), null, null, "doc" + docs.get("neuro"));
        entry(p, "DOCUMENT", LocalDate.now(z).minusDays(12), Loc.of("Заключение невролога", "Neurologist conclusion", "Невролог қорытындысы"), null, "Кузнецов П. В.", "doc" + docs.get("neuro"));
    }

    private void seedNotifications(Patient p, Appointment next) {
        notification(p, "APPOINTMENT_REMINDER", Map.of("doctor", "Смирнов А. И.", "start", next.getStartAt().toString()), "/appointments/" + next.getId(), false, 0);
        notification(p, "LAB_READY", Map.of("test", "biochem"), "/analyses", false, 24);
        notification(p, "NEW_PRESCRIPTION", Map.of("doctor", "Смирнов А. И."), "/medical-record", true, 72);
        notification(p, "SCHEDULE_CHANGED", Map.of("doctor", "Иванова М. С."), "/doctors/2", true, 120);
    }

    private void notification(Patient p, String type, Map<String, String> params, String route, boolean read, int hoursAgo) {
        Notification n = new Notification();
        n.setPatient(p);
        n.setType(type);
        n.setCreatedAt(Instant.now().minus(java.time.Duration.ofHours(hoursAgo)));
        n.setRead(read);
        n.setRoute(route);
        try {
            n.setParamsJson(mapper.writeValueAsString(params));
        } catch (com.fasterxml.jackson.core.JsonProcessingException e) {
            throw new IllegalStateException(e);
        }
        notifications.save(n);
    }
}
