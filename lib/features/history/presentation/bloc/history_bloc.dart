import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movers/features/history/domain/repositories/history_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _historyRepository;
  static const int _limit = 10;

  HistoryBloc(this._historyRepository) : super(const HistoryState()) {
    on<HistoryJobsFetched>(_onJobsFetched);
    on<HistoryLoadMoreJobs>(_onLoadMoreJobs);
  }

  Future<void> _onJobsFetched(
    HistoryJobsFetched event,
    Emitter<HistoryState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(
        state.copyWith(
          status: HistoryStatus.loading,
          currentPage: 1,
          hasReachedMax: false,
          errorMessage: null,
        ),
      );
    }

    try {
      final jobs = await _historyRepository.getCompletedJobs(page: 1);
      emit(
        state.copyWith(
          jobs: jobs,
          status: HistoryStatus.success,
          hasReachedMax: jobs.length < _limit,
          currentPage: 1,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, errorMessage: e.toString()));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onLoadMoreJobs(
    HistoryLoadMoreJobs event,
    Emitter<HistoryState> emit,
  ) async {
    if (state.hasReachedMax || state.status == HistoryStatus.loading) return;

    try {
      final nextPage = state.currentPage + 1;
      final newJobs = await _historyRepository.getCompletedJobs(page: nextPage);
      emit(
        state.copyWith(
          jobs: List.of(state.jobs)..addAll(newJobs),
          status: HistoryStatus.success,
          hasReachedMax: newJobs.length < _limit,
          currentPage: nextPage,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, errorMessage: e.toString()));
    }
  }
}
