import 'dart:async';
import 'package:equatable/equatable.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationsFetched extends NotificationsEvent {
  final bool isRefresh;
  final Completer<void>? completer;

  const NotificationsFetched({this.isRefresh = false, this.completer});

  @override
  List<Object?> get props => [isRefresh];
}

final class NotificationMarkedRead extends NotificationsEvent {
  final String id;
  const NotificationMarkedRead(this.id);

  @override
  List<Object?> get props => [id];
}

final class NotificationsMarkedAllRead extends NotificationsEvent {
  const NotificationsMarkedAllRead();
}

final class NotificationFavoriteToggled extends NotificationsEvent {
  final String id;
  const NotificationFavoriteToggled(this.id);

  @override
  List<Object?> get props => [id];
}

final class NotificationsLoadMore extends NotificationsEvent {
  const NotificationsLoadMore();
}
