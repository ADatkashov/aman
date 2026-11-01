package kz.aman.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import kz.aman.domain.DoctorSchedule;
import org.junit.jupiter.api.Test;

class ScheduleCalculatorTest {

    private static final ZoneId ZONE = ZoneId.of("Asia/Almaty");

    private static DoctorSchedule schedule(int weekday, int start, int end, int slot, Integer bs, Integer be) {
        DoctorSchedule s = new DoctorSchedule();
        s.setWeekday(weekday);
        s.setStartMinute(start);
        s.setEndMinute(end);
        s.setSlotMinutes(slot);
        s.setBreakStartMinute(bs);
        s.setBreakEndMinute(be);
        return s;
    }

    @Test
    void generatesSlotsAndSkipsBreak() {
        // Monday 09:00-16:00, 30 min, break 12:00-14:00
        var weekly = List.of(schedule(1, 540, 960, 30, 720, 840));
        LocalDate monday = LocalDate.of(2026, 11, 2);

        List<Instant> starts = ScheduleCalculator.templateStarts(weekly, monday, ZONE);

        assertThat(starts).hasSize(10);
        assertThat(starts.get(0)).isEqualTo(monday.atTime(9, 0).atZone(ZONE).toInstant());
        assertThat(starts.get(starts.size() - 1)).isEqualTo(monday.atTime(15, 30).atZone(ZONE).toInstant());
        assertThat(starts).noneMatch(s -> s.atZone(ZONE).getHour() == 12 || s.atZone(ZONE).getHour() == 13);
    }

    @Test
    void noSlotsOnNonWorkingDay() {
        var weekly = List.of(schedule(1, 540, 960, 30, null, null));
        assertThat(ScheduleCalculator.templateStarts(weekly, LocalDate.of(2026, 11, 7), ZONE)).isEmpty();
    }

    @Test
    void offeredSlotMustBeAlignedAndInsideSchedule() {
        var weekly = List.of(schedule(1, 540, 960, 30, 720, 840));
        LocalDate monday = LocalDate.of(2026, 11, 2);
        assertThat(ScheduleCalculator.isOffered(weekly, monday.atTime(9, 30).atZone(ZONE).toInstant(), ZONE)).isTrue();
        assertThat(ScheduleCalculator.isOffered(weekly, monday.atTime(9, 15).atZone(ZONE).toInstant(), ZONE)).isFalse();
        assertThat(ScheduleCalculator.isOffered(weekly, monday.atTime(12, 30).atZone(ZONE).toInstant(), ZONE)).isFalse();
        assertThat(ScheduleCalculator.isOffered(weekly, monday.atTime(16, 0).atZone(ZONE).toInstant(), ZONE)).isFalse();
    }

    @Test
    void slotKeyIsStablePerDoctorAndInstant() {
        Instant t = Instant.parse("2026-11-04T05:00:00Z");
        assertThat(ScheduleCalculator.slotKey(7, t)).isEqualTo("7:" + t.getEpochSecond());
        assertThat(ScheduleCalculator.slotKey(8, t)).isNotEqualTo(ScheduleCalculator.slotKey(7, t));
    }
}
