import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movers/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movers/features/auth/presentation/bloc/auth_state.dart';
import 'package:movers/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:movers/features/auth/presentation/pages/login_page.dart';
import 'package:movers/features/auth/presentation/pages/reset_password_page.dart';
import 'package:movers/features/history/presentation/pages/history_page.dart';
import 'package:movers/features/home/presentation/pages/home_page.dart';
import 'package:movers/features/job_details/presentation/pages/job_details_page.dart';
import 'package:movers/features/notifications/presentation/pages/notifications_page.dart';
import 'package:movers/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:movers/features/settings/presentation/pages/change_password_page.dart';
import 'package:movers/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:movers/features/settings/presentation/pages/settings_page.dart';
import 'package:movers/features/settings/presentation/pages/two_factor_setup_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges the [AuthBloc] stream to GoRouter's [refreshListenable].
/// Only triggers a rebuild when the auth *status* changes (not every bloc state).
class _AuthRouterNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _subscription;

  _AuthRouterNotifier(this._authBloc) {
    _subscription = _authBloc.stream
        .distinct((a, b) => a.status == b.status)
        .listen((_) => notifyListeners());
  }

  AuthStatus get status => _authBloc.state.status;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter({
  required AuthBloc authBloc,
  String initialLocation = '/',
}) {
  final notifier = _AuthRouterNotifier(authBloc);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: notifier,
    redirect: (context, routerState) {
      final authStatus = notifier.status;
      final loc = routerState.matchedLocation;

      // Pages that don't need authentication
      final isPublicRoute =
          loc == '/' || loc == '/login' || loc == '/forgot-password' || loc == '/reset-password';

      // If auth is still being determined, don't redirect
      if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
        return null;
      }

      // Unauthenticated users can only see public routes
      if (authStatus == AuthStatus.unauthenticated && !isPublicRoute) {
        return '/login';
      }

      // Authenticated users shouldn't see auth screens
      if (authStatus == AuthStatus.authenticated && isPublicRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.extra as String;
          return ResetPasswordPage(email: email);
        },
      ),
      GoRoute(
        path: '/job/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final jobId = state.pathParameters['id']!;
          return JobDetailsPage(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/2fa-setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TwoFactorSetupPage(),
      ),
      GoRoute(
        path: '/change-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/home',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
