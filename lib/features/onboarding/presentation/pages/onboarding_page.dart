import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movers/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movers/features/auth/presentation/bloc/auth_state.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/utils/responsive.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    const storage = FlutterSecureStorage();
    // Industry standard: Always start at the root route ('/').
    final status = await storage.read(key: 'has_seen_onboarding');
    final hasSeen = status == 'true';

    if (mounted) {
      if (hasSeen) {
        // If the AuthBloc already determined the status while we were loading storage,
        // navigate immediately instead of waiting for a transition.
        final authState = context.read<AuthBloc>().state;
        if (authState.status == AuthStatus.authenticated) {
          context.go('/home');
          return;
        } else if (authState.status == AuthStatus.unauthenticated) {
          context.go('/login');
          return;
        }
      }

      setState(() {
        _hasSeenOnboarding = hasSeen;
        _isLoading = false;
      });
    }
  }

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Efficient\nLogistics',
      description:
          'Streamline your moving process with real-time updates and digital documentation.',
      icon: Icons.speed_rounded,
      image: 'assets/splash/one (1).png',
    ),
    OnboardingData(
      title: 'Digital\nCollaboration',
      description:
          'Connect your entire team on-site. Foremen and movers working in perfect sync.',
      icon: Icons.groups_rounded,
      image: 'assets/splash/one (2).png',
    ),
    OnboardingData(
      title: 'Empower Your\nMove',
      description:
          'Manage assigned jobs, track your progress in real-time, and stay connected.',
      icon: Icons.local_shipping_rounded,
      isLast: true,
      image: 'assets/splash/one (3).png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Only navigate automatically if we are in Splash mode (already seen onboarding)
        if (_hasSeenOnboarding) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/home');
          } else if (state.status == AuthStatus.unauthenticated) {
            context.go('/login');
          }
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.adaptiveBackground(context),
        body: const Center(child: SizedBox.shrink()),
      );
    }

    if (_hasSeenOnboarding) {
      return Scaffold(
        backgroundColor: AppColors.adaptiveBackground(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(
                    context,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.adaptiveBorder(
                      context,
                    ).withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/logo.png',
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'KREWS',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.adaptiveTextPrimary(context),
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image with Page Transition
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                _pages[_currentPage].image,
                key: ValueKey(_currentPage),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Selective Blur Mask (Clear top, Blurred bottom)
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.0), Colors.black],
                  stops: const [0.1, 0.4],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                child: Container(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
          ),
          // Bottom Gradient Overlay (System Primary Tint)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.55),
                  ],
                  stops: const [0.55, 0.82, 1.0],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.isTablet(context)
                      ? 500
                      : double.infinity,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          return _buildPage(_pages[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 32.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (index) => _buildDot(
                                isActive: index == _currentPage,
                                isWide: index == _currentPage,
                              ),
                            ),
                          ),
                          if (_currentPage == _pages.length - 1) ...[
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 0,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  const storage = FlutterSecureStorage();
                                  await storage.write(
                                    key: 'has_seen_onboarding',
                                    value: 'true',
                                  );
                                  if (context.mounted) {
                                    context.push('/login');
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Spacer(flex: 25),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(data.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'KREWS',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(flex: 1),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
              ),
              children: [
                TextSpan(text: '${data.title.split('\n')[0]}\n'),
                if (data.isLast)
                  TextSpan(
                    text: data.title.split('\n')[1],
                    style: const TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white38,
                      decorationThickness: 4,
                    ),
                  )
                else
                  TextSpan(text: data.title.split('\n')[1]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive, bool isWide = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isWide ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final String image;
  final bool isLast;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.image,
    this.isLast = false,
  });
}
