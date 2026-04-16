import 'package:equatable/equatable.dart';
import 'package:movers/features/home/domain/entities/job_entity.dart';
import '../../domain/entities/home_status_counts.dart';

enum HomeStatus { initial, loading, success, failure }

final class HomeState extends Equatable {
  final HomeStatus status;
  final List<JobEntity> jobs;
  final int activeTab;
  final bool isSearchActive;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final String searchQuery;
  final bool isConfirmingAvailability;
  final bool isSelectionMode;
  final Set<int> selectedCrewAssignmentIds;
  final int bulkConfirmTotal;
  final int bulkConfirmCompleted;
  final HomeStatusCounts statusCounts;
  final int? confirmingAssignmentId;
  final bool isFetchingMore;

  const HomeState({
    this.status = HomeStatus.initial,
    this.jobs = const [],
    this.activeTab = 0,
    this.isSearchActive = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.searchQuery = '',
    this.errorMessage,
    this.isConfirmingAvailability = false,
    this.isSelectionMode = false,
    this.selectedCrewAssignmentIds = const {},
    this.bulkConfirmTotal = 0,
    this.bulkConfirmCompleted = 0,
    this.statusCounts = const HomeStatusCounts(),
    this.confirmingAssignmentId,
    this.isFetchingMore = false,
  });

  @override
  List<Object?> get props => [
        status,
        jobs,
        activeTab,
        isSearchActive,
        hasReachedMax,
        currentPage,
        searchQuery,
        errorMessage,
        isConfirmingAvailability,
        isSelectionMode,
        selectedCrewAssignmentIds,
        bulkConfirmTotal,
        bulkConfirmCompleted,
        statusCounts,
        confirmingAssignmentId,
        isFetchingMore,
      ];

  HomeState copyWith({
    HomeStatus? status,
    List<JobEntity>? jobs,
    int? activeTab,
    bool? isSearchActive,
    bool? hasReachedMax,
    int? currentPage,
    String? searchQuery,
    String? errorMessage,
    bool? isConfirmingAvailability,
    bool? isSelectionMode,
    Set<int>? selectedCrewAssignmentIds,
    int? bulkConfirmTotal,
    int? bulkConfirmCompleted,
    HomeStatusCounts? statusCounts,
    int? confirmingAssignmentId,
    bool clearConfirmingId = false,
    bool? isFetchingMore,
  }) {
    return HomeState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      activeTab: activeTab ?? this.activeTab,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      isConfirmingAvailability:
          isConfirmingAvailability ?? this.isConfirmingAvailability,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedCrewAssignmentIds:
          selectedCrewAssignmentIds ?? this.selectedCrewAssignmentIds,
      bulkConfirmTotal: bulkConfirmTotal ?? this.bulkConfirmTotal,
      bulkConfirmCompleted: bulkConfirmCompleted ?? this.bulkConfirmCompleted,
      statusCounts: statusCounts ?? this.statusCounts,
      confirmingAssignmentId:
          clearConfirmingId ? null : (confirmingAssignmentId ?? this.confirmingAssignmentId),
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}
