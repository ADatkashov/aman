package kz.aman.service;

import java.util.List;
import kz.aman.common.ApiException;
import kz.aman.domain.Doctor;
import kz.aman.domain.FavoriteDoctor;
import kz.aman.domain.Patient;
import kz.aman.dto.PatientDto;
import kz.aman.dto.UpdatePatientRequest;
import kz.aman.repo.DoctorRepository;
import kz.aman.repo.FavoriteDoctorRepository;
import kz.aman.repo.PatientRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PatientService {

    private final PatientRepository patients;
    private final DoctorRepository doctors;
    private final FavoriteDoctorRepository favorites;

    public PatientService(PatientRepository patients, DoctorRepository doctors, FavoriteDoctorRepository favorites) {
        this.patients = patients;
        this.doctors = doctors;
        this.favorites = favorites;
    }

    @Transactional(readOnly = true)
    public PatientDto me(Long patientId) {
        return PatientDto.from(patients.findById(patientId).orElseThrow(() -> ApiException.notFound("Patient")));
    }

    @Transactional
    public PatientDto update(Long patientId, UpdatePatientRequest req) {
        Patient p = patients.findById(patientId).orElseThrow(() -> ApiException.notFound("Patient"));
        p.setFullName(req.fullName().trim());
        p.setEmail(blankToNull(req.email()));
        p.setBirthDate(req.birthDate());
        p.setGender(req.gender() == null ? p.getGender() : req.gender().toUpperCase());
        p.setBloodType(blankToNull(req.bloodType()));
        p.setCity(blankToNull(req.city()));
        return PatientDto.from(p);
    }

    @Transactional(readOnly = true)
    public List<Long> favoriteDoctorIds(Long patientId) {
        return favorites.doctorIds(patientId);
    }

    @Transactional
    public void addFavorite(Long patientId, Long doctorId) {
        if (favorites.existsByPatientIdAndDoctorId(patientId, doctorId)) {
            return;
        }
        Doctor doctor = doctors.findById(doctorId).orElseThrow(() -> ApiException.notFound("Doctor"));
        FavoriteDoctor f = new FavoriteDoctor();
        f.setPatient(patients.getReferenceById(patientId));
        f.setDoctor(doctor);
        favorites.save(f);
    }

    @Transactional
    public void removeFavorite(Long patientId, Long doctorId) {
        favorites.deleteByPatientIdAndDoctorId(patientId, doctorId);
    }

    private static String blankToNull(String v) {
        return v == null || v.isBlank() ? null : v.trim();
    }
}
