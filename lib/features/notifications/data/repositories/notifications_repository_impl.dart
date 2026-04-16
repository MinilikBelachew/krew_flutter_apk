import '../../domain/repositories/notifications_repository.dart';
import '../../domain/entities/notification_entity.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remote;

  NotificationsRepositoryImpl(this._remote);

  @override
  Future<NotificationsPageResult> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _remote.getNotifications(page: page, limit: limit);

    final data = (res['data'] as List?) ?? const [];
    final meta = (res['meta'] as Map?) ?? const {};

    final List<NotificationEntity> notifications = data
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return NotificationsPageResult(
      notifications: notifications,
      total: (meta['total'] as num?)?.toInt() ?? notifications.length,
      page: (meta['page'] as num?)?.toInt() ?? page,
      limit: (meta['limit'] as num?)?.toInt() ?? limit,
      unreadCount: (meta['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<void> markAsRead(String id) => _remote.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _remote.markAllAsRead();

  @override
  Future<void> toggleFavorite(String id) => _remote.toggleFavorite(id);
}
