import 'package:equatable/equatable.dart';

class HomeStatusCounts extends Equatable {
  final int all;
  final int upcoming;
  final int completed;
  final int today;

  const HomeStatusCounts({
    this.all = 0,
    this.upcoming = 0,
    this.completed = 0,
    this.today = 0,
  });

  factory HomeStatusCounts.fromJson(Map<String, dynamic> json) {
    return HomeStatusCounts(
      all: json['all'] ?? 0,
      upcoming: json['upcoming'] ?? 0,
      completed: json['completed'] ?? 0,
      today: json['today'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [all, upcoming, completed, today];
}
