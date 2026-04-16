import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final bool isFavorite;
  final DateTime? createdAt;
  final Map<String, dynamic> data;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.isFavorite,
    required this.createdAt,
    required this.data,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    body,
    read,
    isFavorite,
    createdAt,
    data,
  ];
}
