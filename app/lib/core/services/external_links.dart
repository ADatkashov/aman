import '../config/app_config.dart';
import '../../features/appointments/domain/appointment.dart';
import '../../features/catalog/domain/clinic.dart';
import '../../features/catalog/domain/doctor.dart';

/// Builders for deep links. No API keys are required: routes open in the
/// user's maps app / browser; the in-app map is the demo adapter.
abstract final class ExternalLinks {
  /// Directions to [clinic]. Provider: `2gis` (default for KZ) or `google`.
  static Uri route(Clinic clinic, AppConfig config) {
    if (config.mapsProvider == 'google') {
      return Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '${clinic.latitude},${clinic.longitude}',
      });
    }
    return Uri.parse(
      'https://2gis.kz/routeSearch/rsType/car/to/${clinic.longitude},${clinic.latitude}',
    );
  }

  static Uri phone(Clinic clinic) => Uri(scheme: 'tel', path: clinic.phone);

  static String _calDate(DateTime d) {
    final u = d.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}00Z';
  }

  /// Google Calendar "add event" template link for an appointment.
  static Uri calendarEvent({
    required Appointment appointment,
    required Doctor doctor,
    required Clinic clinic,
    required String title,
  }) {
    return Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': title,
      'dates': '${_calDate(appointment.start)}/${_calDate(appointment.end)}',
      'details': '${doctor.fullName} · #${appointment.number}',
      'location': '${clinic.name}, ${clinic.fullAddress}',
    });
  }
}
