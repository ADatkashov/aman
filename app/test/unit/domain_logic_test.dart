import 'package:aman/core/router/app_router.dart';
import 'package:aman/data/demo/demo_repositories.dart';
import 'package:aman/features/analyses/application/lab_providers.dart';
import 'package:aman/features/analyses/domain/lab_result.dart';
import 'package:aman/features/appointments/application/appointments_controller.dart';
import 'package:aman/features/documents/domain/medical_document.dart';
import 'package:aman/features/medical_record/application/medical_record_providers.dart';
import 'package:aman/features/medical_record/domain/medical_entry.dart';
import 'package:aman/core/utils/localized_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  group('lab results', () {
    final store = newStore();

    test('indicator range check uses the laboratory interval only', () {
      final low = LabIndicator(
        name: LocalizedText.plain('x'),
        value: 22,
        unit: 'x',
        refMin: 30,
        refMax: 100,
      );
      final ok = LabIndicator(
        name: LocalizedText.plain('x'),
        value: 50,
        unit: 'x',
        refMin: 30,
        refMax: 100,
      );
      final high = LabIndicator(
        name: LocalizedText.plain('x'),
        value: 5.9,
        unit: 'x',
        refMax: 5.2,
      );
      final noRef = LabIndicator(
        name: LocalizedText.plain('x'),
        value: 5,
        unit: 'x',
      );
      expect(low.isOutOfRange, isTrue);
      expect(ok.isOutOfRange, isFalse);
      expect(high.isOutOfRange, isTrue);
      expect(noRef.isOutOfRange, isFalse);
      expect(noRef.hasReference, isFalse);
    });

    test(
      'status is "attention" exactly when a value is out of range',
      () async {
        final results = await DemoLabRepository(store).results();
        for (final r in results.where((r) => r.hasValues)) {
          expect(
            r.status == LabStatus.attention,
            r.indicators.any((i) => i.isOutOfRange),
            reason: r.id,
          );
        }
        expect(
          results
              .where((r) => !r.hasValues)
              .every((r) => r.status != LabStatus.attention),
          isTrue,
        );
      },
    );

    test('every category and status of the spec is represented', () async {
      final results = await DemoLabRepository(store).results();
      final orders = await DemoLabRepository(store).orders();
      expect(
        {...results.map((r) => r.category)}.length,
        LabCategory.values.length,
      );
      expect({
        ...results.map((r) => r.status),
        ...orders.map((o) => o.status),
      }, containsAll(LabStatus.values));
    });

    test('trend collects the same test over time, oldest first', () async {
      final repo = DemoLabRepository(store);
      final all = await repo.results();
      final latestCbc = await repo.result('l3');
      final trend = trendFor(all, latestCbc, 0);
      expect(trend.map((e) => e.value), [138, 142, 146]);
      expect(trend.first.date.isBefore(trend.last.date), isTrue);
      expect(trendFor(all, latestCbc, 99), isEmpty);
    });
  });

  group('appointments selection', () {
    final store = newStore();

    test('tabs and periods', () {
      final all = store.appointments;
      final up = selectAppointments(
        all,
        tab: AppointmentTab.upcoming,
        period: AppointmentPeriod.all,
        now: testNow,
      );
      expect(up.map((a) => a.id), ['a1', 'a2']);
      final done = selectAppointments(
        all,
        tab: AppointmentTab.completed,
        period: AppointmentPeriod.all,
        now: testNow,
      );
      expect(done.map((a) => a.id), ['a3', 'a4', 'a5'], reason: 'newest first');
      final cancelled = selectAppointments(
        all,
        tab: AppointmentTab.cancelled,
        period: AppointmentPeriod.all,
        now: testNow,
      );
      expect(cancelled.map((a) => a.id), ['a6']);
      final recent = selectAppointments(
        all,
        tab: AppointmentTab.completed,
        period: AppointmentPeriod.days30,
        now: testNow,
      );
      expect(recent.map((a) => a.id), ['a3']);
    });

    test('a confirmed visit in the past counts as completed', () {
      final past = store.appointments.first.copyWith(
        start: testNow.subtract(const Duration(days: 2)),
      );
      expect(past.isUpcoming(testNow), isFalse);
      expect(past.isCompleted(testNow), isTrue);
    });
  });

  group('medical record', () {
    final entries = newStore().entries;

    test('every entry cites a confirming source', () {
      expect(entries.every((e) => e.sourceRef.isNotEmpty), isTrue);
    });

    test('filters by type and date range', () {
      expect(
        filterEntries(entries, type: MedicalEntryType.vaccination).length,
        2,
      );
      final recent = filterEntries(entries, from: DateTime(2026, 9, 1));
      expect(
        recent.every((e) => !e.date.isBefore(DateTime(2026, 9, 1))),
        isTrue,
      );
      final sorted = filterEntries(entries);
      for (var i = 1; i < sorted.length; i++) {
        expect(
          sorted[i - 1].date.isAfter(sorted[i].date) ||
              sorted[i - 1].date == sorted[i].date,
          isTrue,
        );
      }
    });
  });

  group('documents repository', () {
    test(
      'upload validates and stores, delete only removes own uploads',
      () async {
        final repo = DemoDocumentRepository(newStore());
        final doc = await repo.upload(
          fileName: 'analysis.pdf',
          bytes: bytes(2048),
          title: 'My result',
        );
        expect(doc.uploadedByPatient, isTrue);
        expect(doc.isPdf, isTrue);
        expect((await repo.list()).first.id, doc.id);
        await expectLater(
          repo.upload(fileName: 'x.exe', bytes: bytes(10), title: 'bad'),
          throwsA(isA<UploadException>()),
        );
        await repo.delete('doc1'); // clinic document: protected
        expect((await repo.list()).any((d) => d.id == 'doc1'), isTrue);
        await repo.delete(doc.id);
        expect((await repo.list()).any((d) => d.id == doc.id), isFalse);
      },
    );
  });

  group('router redirects', () {
    String? r(
      String loc, {
      bool booting = false,
      bool signedIn = false,
      bool onboarded = false,
    }) => redirectFor(
      location: loc,
      booting: booting,
      signedIn: signedIn,
      onboarded: onboarded,
    );

    test('splash while booting', () {
      expect(r('/home', booting: true), '/splash');
      expect(r('/splash', booting: true), isNull);
    });

    test('unauthenticated users are sent to welcome / login', () {
      expect(r('/home'), '/welcome');
      expect(r('/home', onboarded: true), '/login');
      expect(r('/login'), isNull);
      expect(r('/register'), isNull);
      expect(r('/otp'), isNull);
      expect(r('/doctors/d1'), '/welcome');
    });

    test(
      'authenticated users leave the auth screens but may finish the profile',
      () {
        expect(r('/login', signedIn: true), '/home');
        expect(r('/splash', signedIn: true), '/home');
        expect(r('/profile-setup', signedIn: true), isNull);
        expect(r('/otp', signedIn: true), isNull);
        expect(r('/appointments', signedIn: true), isNull);
      },
    );
  });

  test('notifications are created for booking events', () {
    final store = newStore();
    final slot = store
        .slots('d1', DateTime(2026, 11, 5))
        .firstWhere((s) => s.available)
        .start;
    final a = store.book(doctorId: 'd1', start: slot, reason: 'Visit');
    store.cancel(a.id);
    final types = store.notifications.map((n) => n.type.name).toList();
    expect(types.take(2), ['appointmentCancelled', 'appointmentCreated']);
  });

  test('document sizes', () {
    expect(DocumentPolicy.maxBytes, 10 * 1024 * 1024);
  });
}
