package kz.aman.service;

import kz.aman.common.ApiException;
import kz.aman.common.ErrorCode;
import kz.aman.domain.Patient;
import kz.aman.repo.PatientRepository;
import kz.aman.security.AmanPrincipal;
import org.springframework.stereotype.Component;

/** Resolves the patient profile of the authenticated caller. */
@Component
public class CurrentPatient {

    private final PatientRepository patients;

    public CurrentPatient(PatientRepository patients) {
        this.patients = patients;
    }

    public Patient of(AmanPrincipal principal) {
        return patients.findByUserId(principal.userId())
                .orElseThrow(() -> new ApiException(ErrorCode.FORBIDDEN, "No patient profile"));
    }
}
