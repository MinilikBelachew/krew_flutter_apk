import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/network/dio_client.dart';
import 'package:movers/core/utils/toast_service.dart';
import 'package:movers/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:movers/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:movers/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:movers/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:movers/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:movers/features/notifications/presentation/widgets/notification_card.dart';
import 'package:movers/features/notifications/presentation/widgets/notification_skeleton_card.dart';
import 'package:movers/features/notifications/presentation/widgets/notifications_empty_state.dart';
import 'package:movers/features/notifications/presentation/widgets/notifications_header.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dioClient = context.read<DioClient>();
        final repo = NotificationsRepositoryImpl(
          NotificationsRemoteDataSource(dioClient),
        );
        return NotificationsBloc(repo)..add(const NotificationsFetched());
      },
      child: const _NotificationsView(),
    );
  }

  static Widget buildBlurredBody(
      BuildContext context, String body, TextStyle baseStyle,
      {int? maxLines}) {
    final nameRegex = RegExp(r'\(([^)]+)\)');
    final matches = nameRegex.allMatches(body);

    if (matches.isEmpty) {
      return Text(
        body,
        style: baseStyle,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      // Add text before name
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: body.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      // Add blurred name
      final nameWithParentheses = body.substring(match.start, match.end);
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                nameWithParentheses,
                style: baseStyle.copyWith(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < body.length) {
      spans.add(TextSpan(
        text: body.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NotificationsBloc>().add(const NotificationsLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  String? _extractJobId(Map<String, dynamic> data) {
    final candidates = [
      data['jobId'],
      data['job_id'],
      data['rawId'],
      data['raw_id'],
      data['dispatchId'],
      data['dispatch_id'],
    ];

    for (final c in candidates) {
      if (c == null) continue;
      final s = c.toString();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  void _showNotificationDialog(BuildContext context, String title, String body,
      String time, String? jobId, bool isUnread) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.adaptiveCardBackground(context),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.adaptiveNeutralBackground(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.adaptiveTextSecondary(context),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                title.isEmpty ? 'Notification' : title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.adaptiveTextPrimary(context),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: NotificationsPage.buildBlurredBody(
                    context,
                    body,
                    GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.adaptiveTextSecondary(context),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              if (jobId != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.push('/job/$jobId');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Job Details'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adaptivePageBackground(context),
      body: SafeArea(
        child: BlocConsumer<NotificationsBloc, NotificationsState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ToastService.showError(context, state.errorMessage!);
            }
          },
          builder: (context, state) {
            final isLoading = state.status == NotificationsStatus.loading;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final completer = Completer<void>();
                context.read<NotificationsBloc>().add(
                  NotificationsFetched(isRefresh: true, completer: completer),
                );
                await completer.future;
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ─── Header ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: NotificationsHeader(
                      unreadCount: state.unreadCount,
                      isUpdating: state.isUpdating,
                      onMarkAllRead: () {
                        context.read<NotificationsBloc>().add(
                          const NotificationsMarkedAllRead(),
                        );
                      },
                    ),
                  ),

                  // ─── Content ─────────────────────────────────────────
                  if (isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: NotificationSkeletonCard(),
                          ),
                          childCount: 6,
                        ),
                      ),
                    )
                  else if (state.notifications.isEmpty)
                    const NotificationsEmptyState()
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final n = state.notifications[index];
                          final jobId = _extractJobId(n.data);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: NotificationCard(
                              title: n.title,
                              body: NotificationsPage.buildBlurredBody(
                                context,
                                n.body,
                                GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight:
                                      !n.read ? FontWeight.w600 : FontWeight.w500,
                                  color: AppColors.adaptiveTextSecondary(context)
                                      .withValues(alpha: !n.read ? 1.0 : 0.6),
                                  height: 1.25,
                                ),
                                maxLines: 2,
                              ),
                              time: _formatTime(n.createdAt),
                              isUnread: !n.read,
                              isFavorite: n.isFavorite,
                              onTap: () {
                                if (!n.read) {
                                  context.read<NotificationsBloc>().add(
                                    NotificationMarkedRead(n.id),
                                  );
                                }
                                _showNotificationDialog(
                                  context,
                                  n.title,
                                  n.body,
                                  _formatTime(n.createdAt),
                                  jobId,
                                  !n.read,
                                );
                              },
                              onFavorite: () {
                                context.read<NotificationsBloc>().add(
                                  NotificationFavoriteToggled(n.id),
                                );
                              },
                            ),
                          );
                        }, childCount: state.notifications.length),
                      ),
                    ),
                    // Bottom Loader
                    if (state.hasMore)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          alignment: Alignment.center,
                          child: state.isFetchingMore
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
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

