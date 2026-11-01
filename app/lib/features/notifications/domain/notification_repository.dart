import 'app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> list();
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> delete(String id);
}
