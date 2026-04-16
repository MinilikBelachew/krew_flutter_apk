import 'package:equatable/equatable.dart';
import 'package:movers/features/home/domain/entities/job_entity.dart';

enum HistoryStatus { initial, loading, success, failure }

final class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<JobEntity> jobs;
  final bool hasReachedMax;
  final int currentPage;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.jobs = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<JobEntity>? jobs,
    bool? hasReachedMax,
    int? currentPage,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, jobs, hasReachedMax, currentPage, errorMessage];
}
