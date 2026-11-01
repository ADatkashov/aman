package kz.aman.service;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import kz.aman.common.ApiException;
import kz.aman.common.ErrorCode;
import org.springframework.stereotype.Component;

/**
 * Sliding-window limiter for credential / OTP endpoints (per key, in memory).
 * A multi-instance deployment should back this with Redis; the interface used
 * by the services stays the same.
 */
@Component
public class RateLimiter {

    private final Map<String, Deque<Instant>> hits = new ConcurrentHashMap<>();

    public void check(String key, int maxHits, Duration window) {
        Instant now = Instant.now();
        Deque<Instant> q = hits.computeIfAbsent(key, k -> new ArrayDeque<>());
        synchronized (q) {
            while (!q.isEmpty() && q.peekFirst().isBefore(now.minus(window))) {
                q.pollFirst();
            }
            if (q.size() >= maxHits) {
                throw new ApiException(ErrorCode.TOO_MANY_REQUESTS, "Too many attempts, try again later");
            }
            q.addLast(now);
        }
    }

    public void reset(String key) {
        hits.remove(key);
    }
}
