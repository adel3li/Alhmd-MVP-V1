import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/consistency/consistency_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/reflection/reflection_flow_screen.dart';
import '../../features/settings/settings_controller.dart';
import '../../features/settings/settings_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String reflection = '/reflection';
  static const String journal = '/journal';
  static const String consistency = '/consistency';
  static const String settings = '/settings';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// 400ms fade-through — the app's contemplative transition (§3.4).
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    child: child,
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.read(settingsProvider).onboardingComplete;
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: onboarded ? AppRoutes.home : AppRoutes.onboarding,
    redirect: (context, state) {
      final complete = ref.read(settingsProvider).onboardingComplete;
      final goingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!complete && !goingToOnboarding) return AppRoutes.onboarding;
      if (complete && goingToOnboarding) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) =>
            _fadePage(state, const HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.reflection,
        pageBuilder: (context, state) =>
            _fadePage(state, const ReflectionFlowScreen()),
      ),
      GoRoute(
        path: AppRoutes.journal,
        pageBuilder: (context, state) =>
            _fadePage(state, const JournalScreen()),
      ),
      GoRoute(
        path: AppRoutes.consistency,
        pageBuilder: (context, state) =>
            _fadePage(state, const ConsistencyScreen()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) =>
            _fadePage(state, const SettingsScreen()),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
