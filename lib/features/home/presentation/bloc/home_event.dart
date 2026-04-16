import 'dart:async';
import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class HomeJobsFetched extends HomeEvent {
  final bool isRefresh;
  final Completer<void>? completer;

  const HomeJobsFetched({this.isRefresh = false, this.completer});

  @override
  List<Object> get props => [isRefresh];
}

final class HomeTabChanged extends HomeEvent {
  final int tab;
  const HomeTabChanged(this.tab);

  @override
  List<Object> get props => [tab];
}

final class HomeSearchToggled extends HomeEvent {}

final class HomeSearchQueryChanged extends HomeEvent {
  final String query;
  const HomeSearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

final class HomeLoadMoreJobs extends HomeEvent {}

final class HomeJobConfirmed extends HomeEvent {
  final int crewAssignmentId;
  final String status;

  const HomeJobConfirmed(this.crewAssignmentId, this.status);

  @override
  List<Object> get props => [crewAssignmentId, status];
}

final class HomeSelectionModeEnabled extends HomeEvent {
  final int initialCrewAssignmentId;
  const HomeSelectionModeEnabled(this.initialCrewAssignmentId);

  @override
  List<Object> get props => [initialCrewAssignmentId];
}

final class HomeSelectionToggled extends HomeEvent {
  final int crewAssignmentId;
  const HomeSelectionToggled(this.crewAssignmentId);

  @override
  List<Object> get props => [crewAssignmentId];
}

final class HomeSelectionCleared extends HomeEvent {
  const HomeSelectionCleared();
}

final class HomeBulkConfirmRequested extends HomeEvent {
  final String status;
  const HomeBulkConfirmRequested(this.status);

  @override
  List<Object> get props => [status];
}
