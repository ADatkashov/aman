# Database ER diagram

PostgreSQL schema created by `backend/src/main/resources/db/migration/V1__init_schema.sql`.

```mermaid
erDiagram
  USERS ||--o| PATIENTS : "has profile"
  USERS ||--o{ REFRESH_TOKENS : issues
  PATIENTS ||--o{ APPOINTMENTS : books
  PATIENTS ||--o{ LAB_RESULTS : owns
  PATIENTS ||--o{ LAB_ORDERS : owns
  PATIENTS ||--o{ MEDICAL_RECORD_ENTRIES : owns
  PATIENTS ||--o{ MEDICAL_DOCUMENTS : owns
  PATIENTS ||--o{ NOTIFICATIONS : receives
  PATIENTS ||--o{ FAVORITE_DOCTORS : marks
  PATIENTS ||--o{ REVIEWS : writes
  SPECIALTIES ||--o{ DOCTORS : classifies
  CLINICS ||--o{ DOCTORS : employs
  CLINICS ||--o{ CLINIC_SERVICES : offers
  CLINICS ||--o{ APPOINTMENTS : hosts
  DOCTORS ||--o{ DOCTOR_SERVICES : prices
  DOCTORS ||--o{ DOCTOR_SCHEDULES : "works (per weekday)"
  DOCTORS ||--o{ APPOINTMENTS : receives
  DOCTORS ||--o{ REVIEWS : "rated by"
  DOCTORS ||--o{ FAVORITE_DOCTORS : "favorited in"
  APPOINTMENTS ||--o| REVIEWS : "reviewed once"
  LAB_RESULTS ||--o{ LAB_INDICATORS : contains

  USERS {
    bigint id PK
    varchar phone UK
    varchar password_hash
    varchar role "PATIENT|DOCTOR|CLINIC_ADMIN|SUPER_ADMIN"
    boolean phone_verified
    timestamptz consent_accepted_at
  }
  APPOINTMENTS {
    bigint id PK
    varchar number UK
    bigint patient_id FK
    bigint doctor_id FK
    bigint clinic_id FK
    timestamptz start_at
    varchar status "CONFIRMED|COMPLETED|CANCELLED"
    varchar active_slot_key UK "doctorId:epoch, NULL when cancelled"
  }
  DOCTOR_SCHEDULES {
    bigint id PK
    bigint doctor_id FK
    int weekday "1..7, UNIQUE with doctor_id"
    int start_minute
    int end_minute
    int slot_minutes
  }
  LAB_RESULTS {
    bigint id PK
    bigint patient_id FK
    varchar test_code
    varchar status "PENDING|PROCESSING|READY|ATTENTION"
    date result_date
  }
  LAB_INDICATORS {
    bigint id PK
    bigint result_id FK
    double value
    double ref_min "from the laboratory"
    double ref_max "from the laboratory"
  }
  MEDICAL_DOCUMENTS {
    bigint id PK
    bigint patient_id FK
    varchar storage_key "random, server-side"
    varchar sha256
    bigint size_bytes "<= 10 MB"
  }
  AUDIT_LOG {
    bigint id PK
    bigint user_id
    varchar action
    varchar resource_type
    varchar resource_id
    timestamptz at
  }
```

Notable constraints: `CHECK` on ratings / prices / weekday / schedule ranges, `ck_active_slot` (an active appointment always has a
slot key, a cancelled one never), unique `(patient_id, doctor_id)` favorites, unique `(doctor_id, weekday)` schedules,
indexes on all foreign keys and the hot paths `(patient_id, start_at)`, `(doctor_id, start_at)`, `(patient_id, result_date)`.
`audit_log` has no foreign keys on purpose so that audit history survives account deletion.
