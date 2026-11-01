package kz.aman.service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import kz.aman.domain.DoctorSchedule;

/**
 * Pure slot arithmetic (no I/O): turns a doctor's weekly pattern into the
 * concrete start instants of a day in the clinic time zone.
 */
public final class ScheduleCalculator {

    private ScheduleCalculator() {}

    public static List<Instant> templateStarts(Collection<DoctorSchedule> weekly, LocalDate date, ZoneId zone) {
        int weekday = date.getDayOfWeek().getValue();
        List<Instant> result = new ArrayList<>();
        for (DoctorSchedule s : weekly) {
            if (s.getWeekday() != weekday) {
                continue;
            }
            for (int m = s.getStartMinute(); m + s.getSlotMinutes() <= s.getEndMinute(); m += s.getSlotMinutes()) {
                Integer bs = s.getBreakStartMinute();
                Integer be = s.getBreakEndMinute();
                boolean overlapsBreak = bs != null && be != null && m < be && m + s.getSlotMinutes() > bs;
                if (!overlapsBreak) {
                    result.add(date.atStartOfDay(zone).plusMinutes(m).toInstant());
                }
            }
        }
        return result;
    }

    public static boolean isOffered(Collection<DoctorSchedule> weekly, Instant start, ZoneId zone) {
        ZonedDateTime local = start.atZone(zone);
        return templateStarts(weekly, local.toLocalDate(), zone).contains(start);
    }

    public static String slotKey(long doctorId, Instant start) {
        return doctorId + ":" + start.getEpochSecond();
    }
}
