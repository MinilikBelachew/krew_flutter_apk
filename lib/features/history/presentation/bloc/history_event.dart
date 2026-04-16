import 'dart:async';
import 'package:equatable/equatable.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

final class HistoryJobsFetched extends HistoryEvent {
  final bool isRefresh;
  final Completer<void>? completer;

  const HistoryJobsFetched({this.isRefresh = false, this.completer});

  @override
  List<Object?> get props => [isRefresh];
}

final class HistoryLoadMoreJobs extends HistoryEvent {}
