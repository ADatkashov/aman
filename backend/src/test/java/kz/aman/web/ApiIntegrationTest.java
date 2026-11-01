package kz.aman.web;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicInteger;
import kz.aman.domain.Appointment;
import kz.aman.domain.AppointmentStatus;
import kz.aman.domain.Clinic;
import kz.aman.domain.Doctor;
import kz.aman.domain.DoctorSchedule;
import kz.aman.domain.LabIndicator;
import kz.aman.domain.LabResult;
import kz.aman.domain.Loc;
import kz.aman.domain.Patient;
import kz.aman.domain.Role;
import kz.aman.domain.Specialty;
import kz.aman.domain.UserAccount;
import kz.aman.repo.AppointmentRepository;
import kz.aman.repo.AuditLogRepository;
import kz.aman.repo.ClinicRepository;
import kz.aman.repo.DoctorRepository;
import kz.aman.repo.DoctorScheduleRepository;
import kz.aman.repo.LabResultRepository;
import kz.aman.repo.PatientRepository;
import kz.aman.repo.SpecialtyRepository;
import kz.aman.repo.UserRepository;
import kz.aman.security.JwtService;
import kz.aman.service.AppointmentLifecycleJob;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class ApiIntegrationTest {

    private static final ZoneId ZONE = ZoneId.of("Asia/Almaty");
    private static final String PASSWORD = "Secret123";

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @Autowired SpecialtyRepository specialties;
    @Autowired ClinicRepository clinics;
    @Autowired DoctorRepository doctors;
    @Autowired DoctorScheduleRepository schedules;
    @Autowired AppointmentRepository appointments;
    @Autowired LabResultRepository labs;
    @Autowired PatientRepository patients;
    @Autowired UserRepository users;
    @Autowired AuditLogRepository audit;
    @Autowired JwtService jwt;
    @Autowired AppointmentLifecycleJob lifecycle;

    long doctorId;
    long clinicId;
    private int phoneSeq = 0;

    @BeforeAll
    void fixtures() {
        Specialty sp = new Specialty();
        sp.setCode("therapist");
        sp.setNameRu("Терапевт");
        sp.setNameEn("Therapist");
        sp.setNameKk("Терапевт");
        specialties.save(sp);

        Clinic c = new Clinic();
        c.setName("Test Clinic · DEMO");
        c.setCity("Astana");
        c.setAddress("Test st. 1");
        c.setLatitude(51.1);
        c.setLongitude(71.4);
        c.setPhone("+77170000000");
        c.setRating(4.5);
        c.setReviewsCount(1);
        c.setWorkingHours(Loc.plain("09:00-18:00"));
        c.setChangeDeadlineHours(2);
        c.setDemo(true);
        clinics.save(c);
        clinicId = c.getId();

        Doctor d = newDoctor(sp, c, "Тестов Тест Тестович");
        doctorId = d.getId();
    }

    private Doctor newDoctor(Specialty sp, Clinic c, String name) {
        Doctor d = new Doctor();
        d.setFullName(name);
        d.setSpecialty(sp);
        d.setClinic(c);
        d.setExperienceYears(10);
        d.setRating(4.8);
        d.setReviewsCount(10);
        d.setPriceKzt(12000);
        d.setEducation(Loc.plain("edu"));
        d.setQualification(Loc.plain("q"));
        d.setAbout(Loc.plain("about"));
        d.setLanguages("ru,kk");
        doctors.save(d);
        for (int wd = 1; wd <= 7; wd++) {
            DoctorSchedule s = new DoctorSchedule();
            s.setDoctor(d);
            s.setWeekday(wd);
            s.setStartMinute(8 * 60);
            s.setEndMinute(20 * 60);
            s.setSlotMinutes(30);
            schedules.save(s);
        }
        return d;
    }

    // --- helpers ---------------------------------------------------------

    record Session(String access, String refresh, long patientId, String phone) {}

    private String nextPhone() {
        return String.format("+7701%07d", 1000000 + (++phoneSeq));
    }

    /** Registers a patient, confirms the phone with the OTP and returns the session. */
    private Session signUp() throws Exception {
        String phone = nextPhone();
        JsonNode reg = body(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("fullName", "Иванов Иван", "phone", phone, "password", PASSWORD, "consentAccepted", true))),
                201);
        String code = reg.get("demoOtp").asText();
        JsonNode auth = body(post("/api/v1/auth/otp/verify").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", phone, "code", code))), 200);
        return new Session(auth.get("accessToken").asText(), auth.get("refreshToken").asText(), auth.get("patient").get("id").asLong(), phone);
    }

    private JsonNode body(org.springframework.test.web.servlet.RequestBuilder rb, int expectedStatus) throws Exception {
        var result = mvc.perform(rb).andReturn().getResponse();
        assertThat(result.getStatus()).as(result.getContentAsString(java.nio.charset.StandardCharsets.UTF_8)).isEqualTo(expectedStatus);
        String content = result.getContentAsString(java.nio.charset.StandardCharsets.UTF_8);
        return content.isBlank() ? json.createObjectNode() : json.readTree(content);
    }

    private static org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder auth(
            org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder rb, Session s) {
        return rb.header("Authorization", "Bearer " + s.access());
    }

    private Instant slot(int daysAhead, int hour, int minute) {
        return LocalDate.now(ZONE).plusDays(daysAhead).atTime(hour, minute).atZone(ZONE).toInstant();
    }

    private ResultActions book(Session s, long doctor, Instant start) throws Exception {
        return mvc.perform(auth(post("/api/v1/appointments"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("doctorId", doctor, "start", start.toString(), "reason", "Check-up"))));
    }

    // --- authentication --------------------------------------------------

    @Test
    void registrationRequiresConsentAndStrongPassword() throws Exception {
        JsonNode noConsent = body(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("fullName", "Иванов Иван", "phone", nextPhone(), "password", PASSWORD, "consentAccepted", false))),
                400);
        assertThat(noConsent.get("code").asText()).isEqualTo("CONSENT_REQUIRED");

        JsonNode weak = body(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("fullName", "Иванов Иван", "phone", nextPhone(), "password", "weak", "consentAccepted", true))), 400);
        assertThat(weak.get("code").asText()).isEqualTo("VALIDATION_ERROR");
        assertThat(weak.get("details").toString()).contains("password");

        JsonNode badPhone = body(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("fullName", "Иванов Иван", "phone", "123", "password", PASSWORD, "consentAccepted", true))), 400);
        assertThat(badPhone.get("details").toString()).contains("phone");
    }

    @Test
    void phoneMustBeVerifiedBeforeLoginAndPasswordIsNotReturned() throws Exception {
        String phone = nextPhone();
        JsonNode reg = body(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("fullName", "Иванов Иван", "phone", phone, "password", PASSWORD, "consentAccepted", true))), 201);
        // not verified yet
        body(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", phone, "password", PASSWORD))), 401);
        // wrong code
        JsonNode wrong = body(post("/api/v1/auth/otp/verify").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", phone, "code", "0000".equals(reg.get("demoOtp").asText()) ? "1111" : "0000"))), 400);
        assertThat(wrong.get("code").asText()).isEqualTo("INVALID_OTP");
        // right code
        JsonNode ok = body(post("/api/v1/auth/otp/verify").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", phone, "code", reg.get("demoOtp").asText()))), 200);
        assertThat(ok.toString()).doesNotContain("passwordHash").doesNotContain(PASSWORD);
        // a consumed code cannot be reused
        body(post("/api/v1/auth/otp/verify").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", phone, "code", reg.get("demoOtp").asText()))), 400);
        // login works and phone cannot be registered again
        body(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", phone, "password", PASSWORD))), 200);
        JsonNode taken = body(post("/api/v1/auth/register").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("fullName", "Иванов Иван", "phone", phone, "password", PASSWORD, "consentAccepted", true))), 409);
        assertThat(taken.get("code").asText()).isEqualTo("PHONE_TAKEN");
    }

    @Test
    void loginFailuresAreIndistinguishable() throws Exception {
        Session s = signUp();
        JsonNode wrongPassword = body(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", s.phone(), "password", "Wrong1234"))), 401);
        JsonNode unknownPhone = body(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", "+77019998877", "password", "Wrong1234"))), 401);
        assertThat(wrongPassword.get("code").asText()).isEqualTo("INVALID_CREDENTIALS");
        assertThat(wrongPassword.get("message")).isEqualTo(unknownPhone.get("message"));
    }

    @Test
    void refreshTokensRotateAndReuseIsDetected() throws Exception {
        Session s = signUp();
        JsonNode next = body(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("refreshToken", s.refresh()))), 200);
        assertThat(next.get("refreshToken").asText()).isNotEqualTo(s.refresh());
        // the old token is dead...
        body(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("refreshToken", s.refresh()))), 401);
        // ...and re-use revoked the whole family, including the new token.
        body(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("refreshToken", next.get("refreshToken").asText()))), 401);
    }

    @Test
    void logoutRevokesTheRefreshToken() throws Exception {
        Session s = signUp();
        mvc.perform(post("/api/v1/auth/logout").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("refreshToken", s.refresh())))).andExpect(status().isNoContent());
        body(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("refreshToken", s.refresh()))), 401);
    }

    @Test
    void passwordResetWithOtp() throws Exception {
        Session s = signUp();
        JsonNode forgot = body(post("/api/v1/auth/password/forgot").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", s.phone()))), 200);
        mvc.perform(post("/api/v1/auth/password/reset").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", s.phone(), "code", forgot.get("demoOtp").asText(), "newPassword", "NewSecret456"))))
                .andExpect(status().isNoContent());
        body(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", s.phone(), "password", PASSWORD))), 401);
        body(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("phone", s.phone(), "password", "NewSecret456"))), 200);
        // old refresh tokens were revoked by the reset
        body(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("refreshToken", s.refresh()))), 401);
    }

    // --- authorization / RBAC -------------------------------------------

    @Test
    void anonymousAndWrongRoleCallersAreRejected() throws Exception {
        mvc.perform(get("/api/v1/appointments")).andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
        mvc.perform(get("/api/v1/doctors")).andExpect(status().isUnauthorized());
        mvc.perform(get("/api/v1/appointments").header("Authorization", "Bearer not.a.jwt")).andExpect(status().isUnauthorized());

        UserAccount doctorUser = users.save(new UserAccount(nextPhone(), "x", Role.DOCTOR));
        String doctorToken = jwt.createAccessToken(doctorUser.getId(), Role.DOCTOR);
        mvc.perform(get("/api/v1/appointments").header("Authorization", "Bearer " + doctorToken))
                .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));

        Session patient = signUp();
        mvc.perform(auth(get("/api/v1/admin/users"), patient)).andExpect(status().isForbidden());
        mvc.perform(auth(get("/api/v1/doctor/patients"), patient)).andExpect(status().isForbidden());
        mvc.perform(auth(get("/api/v1/clinic/staff"), patient)).andExpect(status().isForbidden());
    }

    @Test
    void refreshTokenCannotBeUsedAsAccessToken() throws Exception {
        Session s = signUp();
        mvc.perform(get("/api/v1/appointments").header("Authorization", "Bearer " + s.refresh())).andExpect(status().isUnauthorized());
    }

    // --- patient profile -------------------------------------------------

    @Test
    void patientCanReadAndUpdateOwnProfile() throws Exception {
        Session s = signUp();
        JsonNode me = body(auth(get("/api/v1/patients/me"), s), 200);
        assertThat(me.get("phone").asText()).isEqualTo(s.phone());

        JsonNode updated = body(auth(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put("/api/v1/patients/me"), s)
                .contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("fullName", "Иванов Иван Иванович", "email", "i@example.com", "gender", "male", "city", "Астана"))), 200);
        assertThat(updated.get("fullName").asText()).isEqualTo("Иванов Иван Иванович");
        assertThat(updated.get("gender").asText()).isEqualTo("MALE");

        body(auth(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put("/api/v1/patients/me"), s)
                .contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("fullName", "Иванов Иван", "email", "not-an-email"))), 400);
    }

    // --- catalog ---------------------------------------------------------

    @Test
    void catalogListsDoctorsClinicsAndFreeSlots() throws Exception {
        Session s = signUp();
        JsonNode list = body(auth(get("/api/v1/doctors").param("specialty", "therapist"), s), 200);
        assertThat(list.size()).isGreaterThanOrEqualTo(1);
        assertThat(list.get(0).get("specialty").asText()).isEqualTo("therapist");
        assertThat(list.get(0).get("education").get("ru").asText()).isEqualTo("edu");
        assertThat(body(auth(get("/api/v1/doctors").param("q", "zzzz-none"), s), 200).size()).isZero();
        assertThat(body(auth(get("/api/v1/clinics"), s), 200).size()).isGreaterThanOrEqualTo(1);
        mvc.perform(auth(get("/api/v1/doctors/999999"), s)).andExpect(status().isNotFound());

        LocalDate day = LocalDate.now(ZONE).plusDays(3);
        JsonNode slots = body(auth(get("/api/v1/doctors/" + doctorId + "/schedule").param("date", day.toString()), s), 200);
        assertThat(slots.size()).isEqualTo(24);
        assertThat(slots.get(0).get("available").asBoolean()).isTrue();
        // the past is never offered
        assertThat(body(auth(get("/api/v1/doctors/" + doctorId + "/schedule").param("date", LocalDate.now(ZONE).minusDays(1).toString()), s), 200).size()).isZero();
        JsonNode next = body(auth(get("/api/v1/doctors/" + doctorId + "/next-slot"), s), 200);
        assertThat(next.get("start").asText()).isNotBlank();
    }

    // --- booking ---------------------------------------------------------

    @Test
    void bookingLifecycleIsReflectedInSlotsAndNotifications() throws Exception {
        Session s = signUp();
        Instant start = slot(4, 10, 0);
        JsonNode created = body(auth(post("/api/v1/appointments"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("doctorId", doctorId, "start", start.toString(), "reason", "Плановый осмотр"))), 201);
        assertThat(created.get("number").asText()).startsWith("AM-");
        assertThat(created.get("status").asText()).isEqualTo("CONFIRMED");
        long id = created.get("id").asLong();

        // the slot is now unavailable
        JsonNode slots = body(auth(get("/api/v1/doctors/" + doctorId + "/schedule").param("date", LocalDate.now(ZONE).plusDays(4).toString()), s), 200);
        for (JsonNode slotNode : slots) {
            if (Instant.parse(slotNode.get("start").asText()).equals(start)) {
                assertThat(slotNode.get("available").asBoolean()).isFalse();
            }
        }
        // notification created
        JsonNode notes = body(auth(get("/api/v1/notifications"), s), 200);
        assertThat(notes.get(0).get("type").asText()).isEqualTo("APPOINTMENT_CREATED");
        assertThat(notes.get(0).get("read").asBoolean()).isFalse();

        // reschedule to another slot, then cancel
        Instant moved = slot(4, 11, 0);
        JsonNode r = body(auth(patch("/api/v1/appointments/" + id + "/reschedule"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("start", moved.toString()))), 200);
        assertThat(Instant.parse(r.get("start").asText())).isEqualTo(moved);
        assertThat(r.get("rescheduledCount").asInt()).isEqualTo(1);
        JsonNode cancelled = body(auth(patch("/api/v1/appointments/" + id + "/cancel"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("reason", "Plans changed"))), 200);
        assertThat(cancelled.get("status").asText()).isEqualTo("CANCELLED");
        // both slots are free again and the patient can book the original again
        book(s, doctorId, start).andExpect(status().isCreated());
        // cancelled visits cannot be cancelled again
        body(auth(patch("/api/v1/appointments/" + id + "/cancel"), s), 409);
    }

    private JsonNode bookExpecting(Session s, Object doctor, Instant start, String reason, int expectedStatus) throws Exception {
        return body(auth(post("/api/v1/appointments"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("doctorId", doctor, "start", start.toString(), "reason", reason))), expectedStatus);
    }

    @Test
    void bookingRejectsInvalidSlots() throws Exception {
        Session s = signUp();
        assertThat(bookExpecting(s, doctorId, slot(5, 7, 0), "Visit", 422).get("code").asText()).isEqualTo("OUTSIDE_SCHEDULE");
        assertThat(bookExpecting(s, doctorId, slot(5, 10, 15), "Visit", 422).get("code").asText()).isEqualTo("OUTSIDE_SCHEDULE");
        assertThat(bookExpecting(s, doctorId, slot(-1, 10, 0), "Visit", 422).get("code").asText()).isEqualTo("SLOT_IN_PAST");
        assertThat(bookExpecting(s, doctorId, slot(200, 10, 0), "Visit", 422).get("code").asText()).isEqualTo("OUTSIDE_SCHEDULE");
        assertThat(bookExpecting(s, doctorId, slot(5, 10, 0), " ", 400).get("code").asText()).isEqualTo("VALIDATION_ERROR");
        assertThat(bookExpecting(s, 999999, slot(5, 10, 0), "Visit", 404).get("code").asText()).isEqualTo("NOT_FOUND");
        assertThat(appointmentsOf(s).size()).isZero();
    }

    private JsonNode appointmentsOf(Session s) throws Exception {
        return body(auth(get("/api/v1/appointments"), s), 200);
    }

    @Test
    void secondPatientCannotTakeABookedSlot() throws Exception {
        Session a = signUp();
        Session b = signUp();
        Instant start = slot(6, 14, 0);
        book(a, doctorId, start).andExpect(status().isCreated());
        book(b, doctorId, start).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("SLOT_TAKEN"));
    }

    @Test
    void concurrentBookingOfTheSameSlotHasExactlyOneWinner() throws Exception {
        int n = 8;
        List<Session> sessions = new ArrayList<>();
        for (int i = 0; i < n; i++) {
            sessions.add(signUp());
        }
        Instant start = slot(7, 15, 30);
        ExecutorService pool = Executors.newFixedThreadPool(n);
        try {
            List<Callable<Integer>> tasks = new ArrayList<>();
            for (Session s : sessions) {
                tasks.add(() -> book(s, doctorId, start).andReturn().getResponse().getStatus());
            }
            AtomicInteger created = new AtomicInteger();
            AtomicInteger conflicts = new AtomicInteger();
            for (Future<Integer> f : pool.invokeAll(tasks)) {
                int status = f.get();
                if (status == 201) {
                    created.incrementAndGet();
                } else if (status == 409) {
                    conflicts.incrementAndGet();
                }
            }
            assertThat(created.get()).isEqualTo(1);
            assertThat(conflicts.get()).isEqualTo(n - 1);
            long active = appointments.findAll().stream()
                    .filter(x -> x.getDoctor().getId() == doctorId && x.getStartAt().equals(start) && x.getActiveSlotKey() != null).count();
            assertThat(active).isEqualTo(1);
        } finally {
            pool.shutdownNow();
        }
    }

    @Test
    void changesAreRefusedInsideTheClinicDeadline() throws Exception {
        Session s = signUp();
        Patient p = patients.findById(s.patientId()).orElseThrow();
        Doctor d = doctors.findWithDetailsById(doctorId).orElseThrow();
        Appointment near = new Appointment();
        near.setNumber("AM-TEST-NEAR-" + s.patientId());
        near.setPatient(p);
        near.setDoctor(d);
        near.setClinic(d.getClinic());
        near.setStartAt(Instant.now().plus(Duration.ofHours(1)));
        near.setDurationMinutes(30);
        near.setStatus(AppointmentStatus.CONFIRMED);
        near.setReason("Soon");
        near.setPriceKzt(1);
        near.setCreatedAt(Instant.now());
        near.setActiveSlotKey("near:" + s.patientId());
        appointments.save(near);

        JsonNode e = body(auth(patch("/api/v1/appointments/" + near.getId() + "/cancel"), s), 409);
        assertThat(e.get("code").asText()).isEqualTo("TOO_LATE_TO_CHANGE");
        body(auth(patch("/api/v1/appointments/" + near.getId() + "/reschedule"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("start", slot(8, 10, 0).toString()))), 409);
    }

    @Test
    void reviewsRequireACompletedVisitAndAreAcceptedOnce() throws Exception {
        Session s = signUp();
        book(s, doctorId, slot(9, 9, 0)).andExpect(status().isCreated());
        long futureId = appointmentsOf(s).get(0).get("id").asLong();
        body(auth(post("/api/v1/appointments/" + futureId + "/review"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("rating", 5))), 409);

        Patient p = patients.findById(s.patientId()).orElseThrow();
        Doctor d = doctors.findWithDetailsById(doctorId).orElseThrow();
        Appointment done = new Appointment();
        done.setNumber("AM-TEST-DONE-" + s.patientId());
        done.setPatient(p);
        done.setDoctor(d);
        done.setClinic(d.getClinic());
        done.setStartAt(Instant.now().minus(Duration.ofDays(3)));
        done.setDurationMinutes(30);
        done.setStatus(AppointmentStatus.COMPLETED);
        done.setPriceKzt(1);
        done.setCreatedAt(Instant.now().minus(Duration.ofDays(8)));
        done.setActiveSlotKey("done:" + s.patientId());
        appointments.save(done);

        body(auth(post("/api/v1/appointments/" + done.getId() + "/review"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("rating", 6))), 400);
        JsonNode ok = body(auth(post("/api/v1/appointments/" + done.getId() + "/review"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("rating", 4, "text", "Good"))), 200);
        assertThat(ok.get("reviewRating").asInt()).isEqualTo(4);
        JsonNode again = body(auth(post("/api/v1/appointments/" + done.getId() + "/review"), s).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("rating", 5))), 409);
        assertThat(again.get("code").asText()).isEqualTo("ALREADY_REVIEWED");
        assertThat(body(auth(get("/api/v1/doctors/" + doctorId + "/reviews"), s), 200).size()).isGreaterThanOrEqualTo(1);
    }

    @Test
    void lifecycleJobCompletesPastVisitsAndCreatesOneReminder() throws Exception {
        Session s = signUp();
        Patient p = patients.findById(s.patientId()).orElseThrow();
        Doctor d = doctors.findWithDetailsById(doctorId).orElseThrow();
        Appointment past = new Appointment();
        past.setNumber("AM-TEST-PAST-" + s.patientId());
        past.setPatient(p);
        past.setDoctor(d);
        past.setClinic(d.getClinic());
        past.setStartAt(Instant.now().minus(Duration.ofHours(5)));
        past.setDurationMinutes(30);
        past.setStatus(AppointmentStatus.CONFIRMED);
        past.setPriceKzt(1);
        past.setCreatedAt(Instant.now().minus(Duration.ofDays(1)));
        past.setActiveSlotKey("past:" + s.patientId());
        appointments.save(past);
        Appointment soon = new Appointment();
        soon.setNumber("AM-TEST-SOON-" + s.patientId());
        soon.setPatient(p);
        soon.setDoctor(d);
        soon.setClinic(d.getClinic());
        soon.setStartAt(Instant.now().plus(Duration.ofHours(10)));
        soon.setDurationMinutes(30);
        soon.setStatus(AppointmentStatus.CONFIRMED);
        soon.setPriceKzt(1);
        soon.setCreatedAt(Instant.now());
        soon.setActiveSlotKey("soon:" + s.patientId());
        appointments.save(soon);

        lifecycle.runAt(Instant.now());
        lifecycle.runAt(Instant.now()); // idempotent

        assertThat(appointments.findById(past.getId()).orElseThrow().getStatus()).isEqualTo(AppointmentStatus.COMPLETED);
        JsonNode notes = body(auth(get("/api/v1/notifications"), s), 200);
        long reminders = 0;
        for (JsonNode n : notes) {
            if (n.get("type").asText().equals("APPOINTMENT_REMINDER")) {
                reminders++;
            }
        }
        assertThat(reminders).isEqualTo(1);
    }

    // --- data isolation --------------------------------------------------

    @Test
    void patientsCannotSeeEachOthersAppointmentsOrDocuments() throws Exception {
        Session a = signUp();
        Session b = signUp();
        book(a, doctorId, slot(10, 10, 0)).andExpect(status().isCreated());
        long apptId = appointmentsOf(a).get(0).get("id").asLong();

        mvc.perform(auth(get("/api/v1/appointments/" + apptId), b)).andExpect(status().isNotFound());
        mvc.perform(auth(patch("/api/v1/appointments/" + apptId + "/cancel"), b)).andExpect(status().isNotFound());
        assertThat(body(auth(get("/api/v1/appointments"), b), 200).size()).isZero();

        MockMultipartFile pdf = new MockMultipartFile("file", "scan.pdf", "application/pdf", "%PDF-1.4 demo".getBytes());
        long docId = body(auth(multipart("/api/v1/documents").file(pdf).param("title", "My scan").param("kind", "labReport"), a), 201).get("id").asLong();
        mvc.perform(auth(get("/api/v1/documents/" + docId), b)).andExpect(status().isNotFound());
        mvc.perform(auth(get("/api/v1/documents/" + docId + "/content"), b)).andExpect(status().isNotFound());
        mvc.perform(auth(delete("/api/v1/documents/" + docId), b)).andExpect(status().isNotFound());
        assertThat(body(auth(get("/api/v1/documents"), b), 200).size()).isZero();
        mvc.perform(auth(get("/api/v1/documents/" + docId + "/content"), a)).andExpect(status().isOk());
    }

    // --- laboratory and audit -------------------------------------------

    @Test
    void labResultsAreFlaggedAgainstTheLaboratoryRangeAndAccessIsAudited() throws Exception {
        Session s = signUp();
        Session other = signUp();
        Patient p = patients.findById(s.patientId()).orElseThrow();
        LabResult r = new LabResult();
        r.setPatient(p);
        r.setTestCode("vitd");
        r.setCategory("VITAMINS");
        r.setName(Loc.plain("Vitamin D"));
        r.setResultDate(LocalDate.now(ZONE));
        r.setLaboratory("Lab DEMO");
        r.setStatus("READY");
        LabIndicator i = new LabIndicator();
        i.setResult(r);
        i.setName(Loc.plain("25-OH"));
        i.setValue(22);
        i.setUnit("ng/mL");
        i.setRefMin(30.0);
        i.setRefMax(100.0);
        r.getIndicators().add(i);
        labs.save(r);

        long before = audit.count();
        JsonNode list = body(auth(get("/api/v1/laboratory/results"), s), 200);
        assertThat(list.get(0).get("status").asText()).isEqualTo("ATTENTION");
        assertThat(list.get(0).get("category").asText()).isEqualTo("vitamins");
        assertThat(list.get(0).get("indicators").get(0).get("refMin").asDouble()).isEqualTo(30.0);
        body(auth(get("/api/v1/laboratory/results/" + r.getId()), s), 200);
        assertThat(audit.count()).isGreaterThanOrEqualTo(before + 2);
        // audit rows hold identifiers only
        assertThat(audit.findAll()).allSatisfy(a -> assertThat(a.getResourceType()).isNotBlank());
        // isolation
        mvc.perform(auth(get("/api/v1/laboratory/results/" + r.getId()), other)).andExpect(status().isNotFound());
        assertThat(body(auth(get("/api/v1/laboratory/results"), other), 200).size()).isZero();
    }

    // --- documents -------------------------------------------------------

    @Test
    void documentUploadsAreValidated() throws Exception {
        Session s = signUp();
        JsonNode ok = body(auth(multipart("/api/v1/documents")
                .file(new MockMultipartFile("file", "../../evil/report.pdf", "application/pdf", "%PDF-1.7 hello".getBytes()))
                .param("title", "Report").param("kind", "conclusion"), s), 201);
        assertThat(ok.get("fileName").asText()).isEqualTo("report.pdf");
        assertThat(ok.get("mimeType").asText()).isEqualTo("application/pdf");
        assertThat(ok.get("kind").asText()).isEqualTo("CONCLUSION");
        assertThat(ok.get("uploadedByPatient").asBoolean()).isTrue();

        // wrong type, wrong content, empty, oversized
        assertThat(body(auth(multipart("/api/v1/documents").file(new MockMultipartFile("file", "run.exe", "application/octet-stream", "MZ".getBytes())), s), 415)
                .get("code").asText()).isEqualTo("FILE_TYPE_NOT_ALLOWED");
        assertThat(body(auth(multipart("/api/v1/documents").file(new MockMultipartFile("file", "fake.pdf", "application/pdf", "MZ-not-a-pdf".getBytes())), s), 415)
                .get("code").asText()).isEqualTo("FILE_TYPE_NOT_ALLOWED");
        assertThat(body(auth(multipart("/api/v1/documents").file(new MockMultipartFile("file", "empty.pdf", "application/pdf", new byte[0])), s), 400)
                .get("code").asText()).isEqualTo("FILE_EMPTY");
        byte[] big = new byte[10 * 1024 * 1024 + 1];
        System.arraycopy("%PDF-".getBytes(), 0, big, 0, 5);
        assertThat(body(auth(multipart("/api/v1/documents").file(new MockMultipartFile("file", "big.pdf", "application/pdf", big)), s), 413)
                .get("code").asText()).isEqualTo("FILE_TOO_LARGE");

        // owner can delete own uploads
        long id = ok.get("id").asLong();
        mvc.perform(auth(delete("/api/v1/documents/" + id), s)).andExpect(status().isNoContent());
        mvc.perform(auth(get("/api/v1/documents/" + id), s)).andExpect(status().isNotFound());
    }

    // --- favorites and notifications -------------------------------------

    @Test
    void favoritesAndNotificationsLifecycle() throws Exception {
        Session s = signUp();
        mvc.perform(auth(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put("/api/v1/patients/me/favorites/" + doctorId), s))
                .andExpect(status().isNoContent());
        mvc.perform(auth(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put("/api/v1/patients/me/favorites/" + doctorId), s))
                .andExpect(status().isNoContent()); // idempotent
        assertThat(body(auth(get("/api/v1/patients/me/favorites"), s), 200).get(0).asLong()).isEqualTo(doctorId);
        mvc.perform(auth(delete("/api/v1/patients/me/favorites/" + doctorId), s)).andExpect(status().isNoContent());
        assertThat(body(auth(get("/api/v1/patients/me/favorites"), s), 200).size()).isZero();
        mvc.perform(auth(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put("/api/v1/patients/me/favorites/999999"), s))
                .andExpect(status().isNotFound());

        book(s, doctorId, slot(11, 10, 0)).andExpect(status().isCreated());
        book(s, doctorId, slot(11, 11, 0)).andExpect(status().isCreated());
        JsonNode notes = body(auth(get("/api/v1/notifications"), s), 200);
        long first = notes.get(0).get("id").asLong();
        mvc.perform(auth(patch("/api/v1/notifications/" + first + "/read"), s)).andExpect(status().isNoContent());
        mvc.perform(auth(patch("/api/v1/notifications/read-all"), s)).andExpect(status().isNoContent());
        for (JsonNode n : body(auth(get("/api/v1/notifications"), s), 200)) {
            assertThat(n.get("read").asBoolean()).isTrue();
        }
        mvc.perform(auth(delete("/api/v1/notifications/" + first), s)).andExpect(status().isNoContent());
        assertThat(body(auth(get("/api/v1/notifications"), s), 200).size()).isEqualTo(1);
    }

    @Test
    void errorsUseTheUniformFormatWithoutLeakingInternals() throws Exception {
        Session s = signUp();
        JsonNode malformed = body(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON).content("{not json"), 400);
        assertThat(malformed.get("code").asText()).isEqualTo("VALIDATION_ERROR");
        assertThat(malformed.has("timestamp")).isTrue();
        assertThat(malformed.toString()).doesNotContain("Exception").doesNotContain("at kz.aman");
        JsonNode notFound = body(auth(get("/api/v1/appointments/99999999"), s), 404);
        assertThat(notFound.get("code").asText()).isEqualTo("NOT_FOUND");
        assertThat(notFound.get("status").asInt()).isEqualTo(404);
    }
}
