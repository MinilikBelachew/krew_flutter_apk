import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/entities/notification_entity.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsBloc(this._repository) : super(const NotificationsState()) {
    on<NotificationsFetched>(_onFetched);
    on<NotificationsLoadMore>(_onLoadMore);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationsMarkedAllRead>(_onMarkedAllRead);
    on<NotificationFavoriteToggled>(_onFavoriteToggled);
  }

  Future<void> _onFetched(
    NotificationsFetched event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(
        status: NotificationsStatus.loading,
        errorMessage: null,
        page: 1,
        hasMore: true,
      ));
    }

    try {
      final result = await _repository.getNotifications(page: 1, limit: 20);
      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: result.notifications,
          unreadCount: result.unreadCount,
          page: 1,
          hasMore: result.notifications.length >= 20,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: NotificationsStatus.failure, errorMessage: e.toString()));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onLoadMore(
    NotificationsLoadMore event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isFetchingMore || !state.hasMore) return;

    emit(state.copyWith(isFetchingMore: true));

    try {
      final nextPage = state.page + 1;
      final result = await _repository.getNotifications(page: nextPage, limit: 20);
      
      final currentNotifications = List<NotificationEntity>.from(state.notifications);
      currentNotifications.addAll(result.notifications);

      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: currentNotifications,
          unreadCount: result.unreadCount,
          page: nextPage,
          hasMore: result.notifications.length >= 20,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isFetchingMore: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));
    try {
      await _repository.markAsRead(event.id);
      add(const NotificationsFetched(isRefresh: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isUpdating: false));
    }
  }

  Future<void> _onMarkedAllRead(
    NotificationsMarkedAllRead event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));
    try {
      await _repository.markAllAsRead();
      add(const NotificationsFetched(isRefresh: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isUpdating: false));
    }
  }

  Future<void> _onFavoriteToggled(
    NotificationFavoriteToggled event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));
    try {
      await _repository.toggleFavorite(event.id);
      add(const NotificationsFetched(isRefresh: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isUpdating: false));
    }
  }
}
