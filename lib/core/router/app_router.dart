import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/panic_room/presentation/bloc/panic_room_bloc.dart';
import '../../features/panic_room/presentation/screens/panic_room_screen.dart';
import '../../features/sandbox/presentation/bloc/sandbox_bloc.dart';
import '../../features/sandbox/presentation/bloc/sandbox_state.dart';
import '../../features/sandbox/presentation/screens/sandbox_screen.dart';
import '../../injection_container.dart' as di;
import '../constants/app_routes.dart';
import '../presentation/theme/pulse_motion.dart';

export '../constants/app_routes.dart';

/// A [ValueNotifier] that listens to a [SandboxBloc] state stream
/// and notifies [GoRouter] listeners whenever the BLoC state changes.
class SandboxListenableNotifier extends ValueNotifier<SandboxState> {
  final SandboxBloc _sandboxBloc;
  late final StreamSubscription<SandboxState> _subscription;

  SandboxListenableNotifier(this._sandboxBloc) : super(_sandboxBloc.state) {
    _subscription = _sandboxBloc.stream.listen((state) {
      value = state;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Evaluates GoRouter redirect rules according to Pulse navigation specifications.
///
/// Guard rules:
/// 1. `/panic-room`: If [isWeb] is true, redirect to `/sandbox`.
/// 2. `/sandbox` or `/`: If there is no active Scenario in [sandboxBloc],
///    redirect to `/onboarding`.
/// 3. `/onboarding`: Always accessible without guards.
String? appRouterRedirect(
  BuildContext context,
  GoRouterState state, {
  required SandboxBloc sandboxBloc,
  required bool isWeb,
}) {
  final location = state.matchedLocation;

  // Platform conditional guard: Panic Room is mobile-only (ADR-012)
  if (isWeb && location == AppRoutes.panicRoom) {
    return AppRoutes.sandbox;
  }

  // Sandbox guard: redirect to /onboarding if no active Scenario in SandboxBloc state
  if (location == AppRoutes.sandbox || location == AppRoutes.root) {
    final hasActiveScenario = sandboxBloc.state.scenarios.isNotEmpty;
    if (!hasActiveScenario) {
      return AppRoutes.onboarding;
    }
  }

  // Onboarding completion guard: once Scenario exists, onboarding is complete (ADR-007)
  if (location == AppRoutes.onboarding) {
    final hasActiveScenario = sandboxBloc.state.scenarios.isNotEmpty;
    if (hasActiveScenario) {
      return AppRoutes.sandbox;
    }
  }

  return null;
}

/// Creates the application [GoRouter] configuration.
///
/// Features:
/// - Three named routes: `/onboarding`, `/sandbox`, `/panic-room`.
/// - Platform guard: `/panic-room` redirects to `/sandbox` when [isWeb] is true.
/// - State guard: `/sandbox` redirects to `/onboarding` if no active Scenario exists.
/// - Cold start default: lands on `/onboarding` when starting without an active Scenario.
/// - Scoped BLoC provisioning: [PanicRoomBloc] is provided via [BlocProvider] only
///   on mobile and scoped strictly to the `/panic-room` route.
GoRouter createAppRouter({
  required SandboxBloc sandboxBloc,
  bool isWeb = kIsWeb,
  String initialLocation = AppRoutes.sandbox,
  Listenable? refreshListenable,
  GlobalKey<NavigatorState>? navigatorKey,
  PanicRoomBloc Function()? panicRoomBlocFactory,
}) {
  final listenable =
      refreshListenable ?? SandboxListenableNotifier(sandboxBloc);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    refreshListenable: listenable,
    redirect: (context, state) => appRouterRedirect(
      context,
      state,
      sandboxBloc: sandboxBloc,
      isWeb: isWeb,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => OnboardingScreen(isWeb: isWeb),
      ),
      GoRoute(
        path: AppRoutes.sandbox,
        name: AppRoutes.sandboxName,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SandboxScreen(),
          transitionDuration: PulseMotion.defaultDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: PulseMotion.defaultCurve,
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.panicRoom,
        name: AppRoutes.panicRoomName,
        builder: (context, state) {
          return BlocProvider<PanicRoomBloc>(
            create: (_) => panicRoomBlocFactory != null
                ? panicRoomBlocFactory()
                : di.sl<PanicRoomBloc>(),
            child: const PanicRoomScreen(),
          );
        },
      ),
    ],
  );
}
