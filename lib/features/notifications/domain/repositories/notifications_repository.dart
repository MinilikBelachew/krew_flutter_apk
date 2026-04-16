import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<NotificationsPageResult> getNotifications({
    int page = 1,
    int limit = 20,
  });

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> toggleFavorite(String id);
}

final class NotificationsPageResult {
  final List<NotificationEntity> notifications;
  final int total;
  final int page;
  final int limit;
  final int unreadCount;

  const NotificationsPageResult({
    required this.notifications,
    required this.total,
    required this.page,
    required this.limit,
    required this.unreadCount,
  });
}
