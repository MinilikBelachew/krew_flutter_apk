import 'package:dio/dio.dart';
import 'package:movers/core/network/dio_client.dart';

class NotificationsRemoteDataSource {
  final DioClient _dioClient;

  NotificationsRemoteDataSource(this._dioClient);

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dioClient.dio.get(
      '/api/v1/notifications',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch notifications',
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) return data;

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Invalid notifications response',
    );
  }

  Future<void> markAsRead(String id) async {
    final response = await _dioClient.dio.patch('/api/v1/notifications/$id/read');
    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to mark notification as read',
      );
    }
  }

  Future<void> markAllAsRead() async {
    final response = await _dioClient.dio.patch('/api/v1/notifications/read-all');
    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to mark all notifications as read',
      );
    }
  }

  Future<void> toggleFavorite(String id) async {
    final response = await _dioClient.dio.patch('/api/v1/notifications/$id/favorite');
    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to toggle favorite',
      );
    }
  }
}
