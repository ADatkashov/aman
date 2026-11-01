package kz.aman.common;

import org.springframework.http.HttpStatus;

/** Stable machine-readable error codes returned in {@link ApiError#code()}. */
public enum ErrorCode {
    VALIDATION_ERROR(HttpStatus.BAD_REQUEST),
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED),
    FORBIDDEN(HttpStatus.FORBIDDEN),
    NOT_FOUND(HttpStatus.NOT_FOUND),
    CONFLICT(HttpStatus.CONFLICT),
    TOO_MANY_REQUESTS(HttpStatus.TOO_MANY_REQUESTS),
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED),
    PHONE_TAKEN(HttpStatus.CONFLICT),
    ACCOUNT_NOT_FOUND(HttpStatus.NOT_FOUND),
    INVALID_OTP(HttpStatus.BAD_REQUEST),
    CONSENT_REQUIRED(HttpStatus.BAD_REQUEST),
    SLOT_TAKEN(HttpStatus.CONFLICT),
    SLOT_IN_PAST(HttpStatus.UNPROCESSABLE_ENTITY),
    OUTSIDE_SCHEDULE(HttpStatus.UNPROCESSABLE_ENTITY),
    TOO_LATE_TO_CHANGE(HttpStatus.CONFLICT),
    ALREADY_REVIEWED(HttpStatus.CONFLICT),
    NOT_COMPLETED(HttpStatus.CONFLICT),
    FILE_EMPTY(HttpStatus.BAD_REQUEST),
    FILE_TOO_LARGE(HttpStatus.PAYLOAD_TOO_LARGE),
    FILE_TYPE_NOT_ALLOWED(HttpStatus.UNSUPPORTED_MEDIA_TYPE),
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR);

    private final HttpStatus status;

    ErrorCode(HttpStatus status) {
        this.status = status;
    }

    public HttpStatus status() {
        return status;
    }
}
