package kz.aman.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.Instant;
import java.util.List;

/**
 * Uniform error body: {@code {"timestamp","status","code","message","details"}}.
 * Messages never contain personal or medical data.
 */
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public record ApiError(Instant timestamp, int status, String code, String message, List<FieldViolation> details) {

    public record FieldViolation(String field, String message) {}

    public static ApiError of(ErrorCode code, String message) {
        return new ApiError(Instant.now(), code.status().value(), code.name(), message, List.of());
    }
}
