package kz.aman.repo;

import java.util.Optional;
import kz.aman.domain.OtpCode;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OtpCodeRepository extends JpaRepository<OtpCode, Long> {
    Optional<OtpCode> findFirstByPhoneAndConsumedFalseOrderByIdDesc(String phone);
}
