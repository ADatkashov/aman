enum NotificationType {
  appointmentCreated,
  appointmentReminder,
  appointmentRescheduled,
  appointmentCancelled,
  labReady,
  newPrescription,
  scheduleChanged;

  static NotificationType fromId(String id) => NotificationType.values.firstWhere(
        (c) => c.name.toLowerCase() == id.toLowerCase().replaceAll('_', ''),
        orElse: () => NotificationType.appointmentCreated,
      );
}

/// A notification stores only the event type and its parameters; the text is
/// rendered from localized templates so it follows the current app language.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.createdAt,
    this.read = false,
    this.params = const {},
    this.route,
  });

  final String id;
  final NotificationType type;
  final DateTime createdAt;
  final bool read;

  /// Template parameters, e.g. `doctor`, `start` (ISO-8601), `number`, `test`.
  final Map<String, String> params;

  /// In-app location the notification leads to (go_router path).
  final String? route;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        createdAt: createdAt,
        read: read ?? this.read,
        params: params,
        route: route,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'].toString(),
        type: NotificationType.fromId(json['type'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        read: json['read'] as bool? ?? false,
        params: ((json['params'] ?? const {}) as Map).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ),
        route: json['route'] as String?,
      );
}
