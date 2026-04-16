import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movers/core/bloc/theme_bloc.dart';
import 'package:movers/core/config/router.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/network/dio_client.dart';
import 'package:movers/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:movers/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movers/features/auth/domain/repositories/auth_repository.dart';
import 'package:movers/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movers/features/auth/presentation/bloc/auth_event.dart';
import 'package:movers/features/auth/presentation/bloc/auth_state.dart';
import 'package:movers/features/home/data/repositories/home_repository_impl.dart';
import 'package:movers/features/home/domain/repositories/home_repository.dart';
import 'package:movers/features/home/presentation/bloc/home_bloc.dart';
import 'package:movers/features/home/presentation/bloc/home_event.dart';
import 'package:movers/features/job_details/data/datasources/job_details_remote_data_source.dart';
import 'package:movers/features/job_details/data/repositories/job_details_repository_impl.dart';
import 'package:movers/features/job_details/domain/repositories/job_details_repository.dart';
import 'package:movers/features/settings/data/repositories/profile_repository_impl.dart';
import 'package:movers/features/settings/domain/repositories/profile_repository.dart';
import 'package:movers/features/settings/presentation/bloc/profile_bloc.dart';
import 'package:movers/features/settings/presentation/bloc/profile_event.dart';
import 'package:movers/core/services/local_notifications_service.dart';
import 'package:movers/core/services/notifications_socket_service.dart';
import 'package:movers/core/services/dispatch_tracking_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  const storage = FlutterSecureStorage();

  await LocalNotificationsService.instance.init();
  // NotificationsSocketService is created here as a singleton.
  // connect() is called later via BlocListener once the user is authenticated
  // so the access token is guaranteed to exist.
  final notificationsSocketService = NotificationsSocketService(
    storage: storage,
  );

  // Industry standard: Always start at the root route ('/').
  // The Onboarding/Splash logic will decide whether to show onboarding
  // or act as a Splash screen while AuthBloc validates the session.
  const String initialLocation = '/';

  // ── Step 1: Create AuthBloc early so the Dio logout callback can reference it ──
  // We use a late reference pattern: the variable is captured by the closure
  // but only called after the bloc is assigned, which happens synchronously below.
  late final AuthBloc authBloc;

  final dioClient = DioClient(
    storage: storage,
    onLogout: () {
      // The network layer detected that both tokens are expired.
      // Tell the AuthBloc to clear the session state → the router will
      // automatically redirect to /login via its redirect function.
      authBloc.add(AuthLogoutRequested());
    },
  );

  // ── Step 2: Build the rest of the dependency tree ──
  final dispatchTrackingService = DispatchTrackingService(
    storage: storage,
    dioClient: dioClient,
  );
  final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource, storage);
  final homeRepository = HomeRepositoryImpl(dioClient);
  final jobDetailsRepository = JobDetailsRepositoryImpl(
    JobDetailsRemoteDataSourceImpl(dioClient),
  );
  final profileRepository = ProfileRepositoryImpl(dioClient);

  // ── Step 3: Assign and boot the AuthBloc ──
  authBloc = AuthBloc(
    authRepository,
    dispatchTrackingService: dispatchTrackingService,
  )..add(AuthCheckRequested());

  runApp(
    MyApp(
      authBloc: authBloc,
      authRepository: authRepository,
      homeRepository: homeRepository,
      jobDetailsRepository: jobDetailsRepository,
      profileRepository: profileRepository,
      initialLocation: initialLocation,
      dioClient: dioClient,
      dispatchTrackingService: dispatchTrackingService,
      notificationsSocketService: notificationsSocketService,
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthBloc authBloc;
  final AuthRepositoryImpl authRepository;
  final HomeRepositoryImpl homeRepository;
  final JobDetailsRepository jobDetailsRepository;
  final ProfileRepository profileRepository;
  final String initialLocation;
  final DioClient dioClient;
  final DispatchTrackingService dispatchTrackingService;
  final NotificationsSocketService notificationsSocketService;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.authRepository,
    required this.homeRepository,
    required this.jobDetailsRepository,
    required this.profileRepository,
    required this.initialLocation,
    required this.dioClient,
    required this.dispatchTrackingService,
    required this.notificationsSocketService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Build the router once, keeping the authBloc reference stable.
  late final _router = createRouter(
    authBloc: widget.authBloc,
    initialLocation: widget.initialLocation,
  );

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DioClient>.value(value: widget.dioClient),
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
        RepositoryProvider<HomeRepository>.value(value: widget.homeRepository),
        RepositoryProvider<JobDetailsRepository>.value(
          value: widget.jobDetailsRepository,
        ),
        RepositoryProvider<ProfileRepository>.value(
          value: widget.profileRepository,
        ),
        // Expose the singleton tracking service so Settings can read it
        // via context.read<DispatchTrackingService>() without constructing a new one.
        RepositoryProvider<DispatchTrackingService>.value(
          value: widget.dispatchTrackingService,
        ),
        RepositoryProvider<NotificationsSocketService>.value(
          value: widget.notificationsSocketService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Provide the pre-created AuthBloc (NOT create: so it isn't disposed on widget rebuild)
          BlocProvider<AuthBloc>.value(value: widget.authBloc),
          BlocProvider(
            create: (_) =>
                HomeBloc(widget.homeRepository)..add(HomeJobsFetched()),
          ),
          BlocProvider(
            create: (_) =>
                ProfileBloc(widget.profileRepository)
                  ..add(ProfileFetchRequested()),
          ),
          BlocProvider(create: (_) => ThemeBloc()..add(ThemeLoadRequested())),
        ],
        child: ToastificationWrapper(
          // Listen globally for logout events and clear the HomeBloc too
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) => curr.status != prev.status,
            listener: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                // Connect the notification socket now that we have a valid token.
                widget.notificationsSocketService.connect();
                widget.dispatchTrackingService.autoResume();
              } else if (state.status == AuthStatus.unauthenticated) {
                // Disconnect socket and clear home cache on logout.
                widget.notificationsSocketService.disconnect();
                widget.dispatchTrackingService.stop();
                context.read<HomeBloc>().add(const HomeJobsFetched());
              }
            },
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                return MaterialApp.router(
                  title: 'Movers App',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeState.isDark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  routerConfig: _router,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
