package kz.aman.domain;

/** Platform roles. Access rules per role are enforced in {@code SecurityConfig}. */
public enum Role {
    PATIENT,
    DOCTOR,
    CLINIC_ADMIN,
    SUPER_ADMIN
}
