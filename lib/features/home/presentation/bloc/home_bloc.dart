import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movers/features/home/domain/repositories/home_repository.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/home_status_counts.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  static const int _limit = 10;

  HomeBloc(this._homeRepository) : super(const HomeState()) {
    on<HomeJobsFetched>(_onJobsFetched);
    on<HomeLoadMoreJobs>(_onLoadMoreJobs);
    on<HomeTabChanged>(_onTabChanged);
    on<HomeSearchToggled>(_onSearchToggled);
    on<HomeSearchQueryChanged>(_onSearchQueryChanged);
    on<HomeJobConfirmed>(_onJobConfirmed);
    on<HomeSelectionModeEnabled>(_onSelectionModeEnabled);
    on<HomeSelectionToggled>(_onSelectionToggled);
    on<HomeSelectionCleared>(_onSelectionCleared);
    on<HomeBulkConfirmRequested>(_onBulkConfirmRequested);
  }

  String? _getStatusString(int tabIndex) {
    if (tabIndex == 0) return null; // All jobs
    if (tabIndex == 1) return 'today';
    if (tabIndex == 2) return 'upcoming';
    if (tabIndex == 3) return 'completed';
    return null;
  }

  Future<void> _onJobsFetched(
    HomeJobsFetched event,
    Emitter<HomeState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(
        state.copyWith(
          status: HomeStatus.loading,
          jobs: [], // Clear jobs when doing a fresh fetch (not a refresh)
          currentPage: 1,
          hasReachedMax: false,
        ),
      );
    }

    try {
      final statusStr = _getStatusString(state.activeTab);
      // Fetch both jobs and counts in parallel
      final results = await Future.wait([
        _homeRepository.getMyJobs(
          page: 1,
          status: statusStr,
          search: state.searchQuery,
        ),
        _homeRepository.getMyJobsCounts(
          search: state.searchQuery,
        ),
      ]);

      final jobs = results[0] as List<JobEntity>;
      final counts = results[1] as HomeStatusCounts;

      emit(
        state.copyWith(
          jobs: jobs,
          statusCounts: counts,
          status: HomeStatus.success,
          hasReachedMax: jobs.length < _limit,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onLoadMoreJobs(
    HomeLoadMoreJobs event,
    Emitter<HomeState> emit,
  ) async {
    if (state.hasReachedMax || state.isFetchingMore || state.status == HomeStatus.loading) return;

    emit(state.copyWith(isFetchingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final statusStr = _getStatusString(state.activeTab);
      final newJobs = await _homeRepository.getMyJobs(
        page: nextPage,
        status: statusStr,
        search: state.searchQuery,
      );

      emit(
        state.copyWith(
          jobs: List.of(state.jobs)..addAll(newJobs),
          status: HomeStatus.success,
          hasReachedMax: newJobs.length < _limit,
          currentPage: nextPage,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: e.toString(),
          isFetchingMore: false,
        ),
      );
    }
  }

  void _onTabChanged(HomeTabChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      activeTab: event.tab,
      status: HomeStatus.loading,
      jobs: [], // Immediately clear jobs so the UI shows skeletons
    ));
    add(const HomeJobsFetched());
  }

  void _onSearchToggled(HomeSearchToggled event, Emitter<HomeState> emit) {
    final isActive = !state.isSearchActive;
    emit(state.copyWith(isSearchActive: isActive));
    if (!isActive && state.searchQuery.isNotEmpty) {
      add(const HomeSearchQueryChanged(''));
    }
  }

  void _onSearchQueryChanged(
    HomeSearchQueryChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: event.query,
        jobs: [],
        status: HomeStatus.loading,
      ),
    );
    add(HomeJobsFetched());
  }

  Future<void> _onJobConfirmed(
    HomeJobConfirmed event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      confirmingAssignmentId: event.crewAssignmentId,
      errorMessage: null,
    ));
    try {
      await _homeRepository.confirmAssignment(
        event.crewAssignmentId,
        event.status,
      );

      // Optimistically update the job status in the list
      final updatedJobs = state.jobs.map((job) {
        if (job.crewAssignmentId == event.crewAssignmentId) {
          return job.copyWith(crewStatus: 'CONFIRMED');
        }
        return job;
      }).toList();

      emit(state.copyWith(
        jobs: updatedJobs,
        clearConfirmingId: true,
      ));

      // Still fetch to ensure total sync with backend
      add(const HomeJobsFetched(isRefresh: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        clearConfirmingId: true,
      ));
    }
  }

  void _onSelectionModeEnabled(
    HomeSelectionModeEnabled event,
    Emitter<HomeState> emit,
  ) {
    final next = <int>{event.initialCrewAssignmentId};
    emit(
      state.copyWith(
        isSelectionMode: true,
        selectedCrewAssignmentIds: next,
        errorMessage: null,
      ),
    );
  }

  void _onSelectionToggled(
    HomeSelectionToggled event,
    Emitter<HomeState> emit,
  ) {
    final next = Set<int>.from(state.selectedCrewAssignmentIds);
    if (next.contains(event.crewAssignmentId)) {
      next.remove(event.crewAssignmentId);
    } else {
      next.add(event.crewAssignmentId);
    }

    emit(
      state.copyWith(
        selectedCrewAssignmentIds: next,
        isSelectionMode: next.isNotEmpty,
        errorMessage: null,
      ),
    );
  }

  void _onSelectionCleared(
    HomeSelectionCleared event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        isSelectionMode: false,
        selectedCrewAssignmentIds: <int>{},
        bulkConfirmTotal: 0,
        bulkConfirmCompleted: 0,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onBulkConfirmRequested(
    HomeBulkConfirmRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isConfirmingAvailability) return;

    final ids = state.selectedCrewAssignmentIds.toList();
    if (ids.isEmpty) return;

    emit(
      state.copyWith(
        isConfirmingAvailability: true,
        bulkConfirmTotal: ids.length,
        bulkConfirmCompleted: 0,
        errorMessage: null,
      ),
    );

    try {
      for (var i = 0; i < ids.length; i++) {
        await _homeRepository.confirmAssignment(ids[i], event.status);
        
        // Optimistically update each job as it completes
        final currentId = ids[i];
        final updatedJobs = state.jobs.map((job) {
          if (job.crewAssignmentId == currentId) {
            return job.copyWith(crewStatus: 'CONFIRMED');
          }
          return job;
        }).toList();

        emit(state.copyWith(
          jobs: updatedJobs,
          bulkConfirmCompleted: i + 1,
        ));
      }

      emit(
        state.copyWith(
          isSelectionMode: false,
          selectedCrewAssignmentIds: <int>{},
          bulkConfirmTotal: 0,
          bulkConfirmCompleted: 0,
        ),
      );
      add(const HomeJobsFetched(isRefresh: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isConfirmingAvailability: false));
    }
  }
}
