import 'package:aman/features/appointments/application/appointments_controller.dart';
import 'package:aman/features/appointments/domain/appointment.dart';
import 'package:aman/features/catalog/presentation/doctor_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('full booking: specialty → doctor → clinic → date → time → reason → confirm', (tester) async {
    final env = await pumpApp(tester, signedIn: true);
    expect(find.text('Здравствуйте, Алексей!'), findsOneWidget);
    final before = env.store.appointments.length;

    await tapText(tester, 'Запись\nк врачу');
    expect(find.text('Выберите специальность'), findsOneWidget);
    await tapText(tester, 'Терапевт'); // auto-advances to doctors
    expect(find.text('Выберите врача'), findsOneWidget);
    await tapText(tester, 'Смирнов Алексей Иванович');
    expect(find.text('Клиника приёма'), findsOneWidget);
    await tapPrimary(tester);

    expect(find.text('Выберите дату'), findsOneWidget);
    await tapText(tester, '4'); // Wed, 4 Nov
    expect(find.text('Выберите время'), findsOneWidget);

    final free = env.store.slots('d1', DateTime(2026, 11, 4)).where((s) => s.available).first.start;
    final label = '${free.hour.toString().padLeft(2, '0')}:${free.minute.toString().padLeft(2, '0')}';
    await tapText(tester, label);
    await tapPrimary(tester);

    expect(find.text('Причина обращения'), findsWidgets);
    // Continue stays disabled until a reason is typed.
    await tester.enterText(find.byType(TextFormField), 'Плановый осмотр');
    await tester.pump(const Duration(milliseconds: 400));
    await tapPrimary(tester);

    expect(find.text('Данные записи'), findsOneWidget);
    expect(find.text('Плановый осмотр'), findsOneWidget);
    await tapPrimary(tester);

    expect(find.text('Вы записаны!'), findsOneWidget);
    expect(env.store.appointments.length, before + 1);
    final created = env.store.appointments.first;
    expect(created.start, free);
    expect(find.text(created.number), findsOneWidget);

    // Add to calendar opens a calendar link with the visit data.
    await tapText(tester, 'Добавить в календарь');
    expect(env.opener.opened.single.host, 'calendar.google.com');
    expect(env.opener.opened.single.queryParameters['text'], contains('Терапевт'));

    // The visit is listed in "Записи".
    await tapText(tester, 'Мои записи');
    expect(find.textContaining(created.number), findsOneWidget);
  });

  testWidgets('a slot taken in the meantime is rejected and the user returns to time selection', (tester) async {
    final env = await pumpApp(tester, signedIn: true);
    final doctor = env.store.doctorById('d1');
    final slot = env.store.slots('d1', DateTime(2026, 11, 4)).where((s) => s.available).first.start;

    await goTo(env, tester, '/doctors/d1');
    await tapText(tester, 'Записаться');
    // Doctor preselected: wizard starts at the date step.
    expect(find.text('Выберите дату'), findsOneWidget);
    await tapText(tester, '4');
    final label = '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';
    await tapText(tester, label);
    await tapPrimary(tester);
    await tester.enterText(find.byType(TextFormField), 'Консультация');
    await tester.pump(const Duration(milliseconds: 400));
    await tapPrimary(tester);

    // Somebody else books the slot before we confirm.
    env.store.book(doctorId: doctor.id, start: slot, reason: 'Other patient');
    await tapPrimary(tester);

    expect(find.textContaining('только что заняли'), findsOneWidget);
    expect(find.text('Выберите время'), findsOneWidget);
    // The taken slot is now disabled.
    final chip = tester.widget<TimeChip>(find.widgetWithText(TimeChip, label));
    expect(chip.enabled, isFalse);
    expect(env.store.appointments.where((a) => a.start == slot && a.reason == 'Консультация'), isEmpty);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('doctor profile lets the user pick a free slot and jump to the reason step', (tester) async {
    final env = await pumpApp(tester, signedIn: true);
    await goTo(env, tester, '/doctors/d1');
    expect(find.text('О враче'), findsOneWidget);
    final slot = env.store.slots('d1', DateTime(2026, 11, 2)).where((s) => s.available);
    if (slot.isNotEmpty) {
      final t = slot.first.start;
      final label = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      await tester.scrollUntilVisible(find.text(label), 300, scrollable: find.byType(Scrollable).first);
      await tapText(tester, label);
      expect(find.text('Причина обращения'), findsWidgets);
    }
  });

  testWidgets('cancel, reschedule and review from "My appointments"', (tester) async {
    final env = await pumpApp(tester, signedIn: true);
    await tapText(tester, 'Записи');
    expect(find.text('Предстоящие'), findsOneWidget);

    // Cancel the first upcoming visit.
    await tapText(tester, 'Отменить');
    expect(find.text('Отменить запись?'), findsOneWidget);
    await tapText(tester, 'Отменить запись', last: true);
    expect(find.text('Запись отменена'), findsOneWidget);
    expect(env.store.appointments.firstWhere((a) => a.id == 'a1').status, AppointmentStatus.cancelled);
    await tester.pump(const Duration(seconds: 6));

    // It appears in the "Отменённые" tab.
    await tapText(tester, 'Отменённые');
    expect(find.textContaining('AM-'), findsWidgets);

    // Reschedule a1 is impossible now; reschedule a2 via the detail screen.
    await tapText(tester, 'Предстоящие');
    await tapText(tester, 'Перенести');
    expect(find.text('Выберите новое время'), findsOneWidget);
    final old = env.store.appointmentById('a2').start;
    final day = DateTime(old.year, old.month, old.day + 1);
    final target = env.store.slots('d2', day).firstWhere((s) => s.available).start;
    await scrollHorizontallyTo(tester, find.text('${target.day}'));
    await tapText(tester, '${target.day}');
    await tapText(tester, '${target.hour.toString().padLeft(2, '0')}:${target.minute.toString().padLeft(2, '0')}');
    await tapPrimary(tester);
    expect(env.store.appointmentById('a2').start, target);
    expect(env.store.appointmentById('a2').rescheduledCount, 1);
    await tester.pump(const Duration(seconds: 6));

    // Leave a review for a completed visit without a rating (a4).
    await tapText(tester, 'Завершённые');
    await tapText(tester, 'Оставить отзыв');
    await tester.tap(find.byTooltip('4'));
    await tester.pump();
    await tapPrimary(tester);
    expect(env.store.appointmentById('a4').reviewRating, 4);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('changes are blocked inside the clinic deadline', (tester) async {
    final env = await pumpApp(tester, signedIn: true);
    final near = env.store.appointmentById('a1').copyWith(start: testNow.add(const Duration(hours: 1)));
    env.store.appointments = [near, ...env.store.appointments.skip(1)];
    await env.container.read(appointmentsProvider.notifier).refresh();
    await tapText(tester, 'Записи');
    expect(find.textContaining('не позднее чем за 2 ч'), findsOneWidget);
    final cancel = tester.widgetList<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Отменить')).first;
    expect(cancel.onPressed, isNull, reason: 'visit starts in 1h, clinic requires 2h');
    final second = tester.widgetList<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Отменить')).last;
    expect(second.onPressed, isNotNull);
  });
}
