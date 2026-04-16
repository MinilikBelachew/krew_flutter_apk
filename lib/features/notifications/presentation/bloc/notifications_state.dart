import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

enum NotificationsStatus { initial, loading, success, failure }

final class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final int page;
  final bool hasMore;
  final bool isFetchingMore;
  final int unreadCount;
  final bool isUpdating;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.page = 1,
    this.hasMore = true,
    this.isFetchingMore = false,
    this.unreadCount = 0,
    this.isUpdating = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    int? page,
    bool? hasMore,
    bool? isFetchingMore,
    int? unreadCount,
    bool? isUpdating,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      unreadCount: unreadCount ?? this.unreadCount,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    page,
    hasMore,
    isFetchingMore,
    unreadCount,
    isUpdating,
    errorMessage,
  ];
}
