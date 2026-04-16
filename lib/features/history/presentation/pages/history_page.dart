import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/network/dio_client.dart';
import 'package:movers/features/history/data/repositories/history_repository_impl.dart';
import 'package:movers/features/history/presentation/bloc/history_bloc.dart';
import 'package:movers/features/history/presentation/bloc/history_event.dart';
import 'package:movers/features/history/presentation/bloc/history_state.dart';
import 'package:movers/features/history/presentation/widgets/history_empty_state.dart';
import 'package:movers/features/history/presentation/widgets/history_header.dart';
import 'package:movers/features/history/presentation/widgets/history_job_card.dart';
import 'package:movers/features/history/presentation/widgets/history_skeleton_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HistoryBloc(HistoryRepositoryImpl(context.read<DioClient>()))
            ..add(const HistoryJobsFetched()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HistoryBloc>().add(HistoryLoadMoreJobs());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptivePageBackground(context),
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final completer = Completer<void>();
                context.read<HistoryBloc>().add(
                  HistoryJobsFetched(isRefresh: true, completer: completer),
                );
                await completer.future;
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: HistoryHeader(),
                  ),

                  if (state.status == HistoryStatus.loading &&
                      state.jobs.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: HistorySkeletonCard(),
                          ),
                          childCount: 6,
                        ),
                      ),
                    )
                  else if (state.status == HistoryStatus.success &&
                      state.jobs.isEmpty)
                    const HistoryEmptyState()
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= state.jobs.length) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: HistorySkeletonCard(),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HistoryJobCard(job: state.jobs[index]),
                            );
                          },
                          childCount:
                              state.jobs.length + (state.hasReachedMax ? 0 : 1),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

