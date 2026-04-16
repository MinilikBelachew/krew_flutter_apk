import '../../domain/entities/notification_entity.dart';

final class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.read,
    required super.isFavorite,
    required super.createdAt,
    required super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      read: json['read'] == true,
      isFavorite: json['isFavorite'] == true,
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw.toString())
          : null,
      data: (json['data'] is Map)
          ? Map<String, dynamic>.from(json['data'] as Map)
          : <String, dynamic>{},
    );
  }
}
