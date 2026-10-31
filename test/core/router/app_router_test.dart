import 'package:finance_pulse/core/presentation/theme/app_theme.dart';
import 'package:finance_pulse/core/router/app_router.dart';
import 'package:finance_pulse/domain/entities/scenario.dart';
import 'package:finance_pulse/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:finance_pulse/features/panic_room/presentation/bloc/panic_room_bloc.dart';
import 'package:finance_pulse/features/panic_room/presentation/screens/panic_room_screen.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_bloc.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_event.dart';
import 'package:finance_pulse/features/sandbox/presentation/screens/sandbox_screen.dart';
import 'package:finance_pulse/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUp(() async {
    await di.locator.reset();
    await di.init();
  });

  tearDown(() async {
    await di.locator.reset();
  });

  Widget buildSubject({
    required GoRouter router,
    required SandboxBloc sandboxBloc,
  }) {
    return BlocProvider<SandboxBloc>.value(
      value: sandboxBloc,
      child: MaterialApp.router(theme: AppTheme().dark(), routerConfig: router),
    );
  }

  group('AppRouter Navigation & Guards', () {
    testWidgets('cold start defaults to /onboarding when no active scenario', (
      tester,
    ) async {
      final sandboxBloc = SandboxBloc();
      final router = createAppRouter(sandboxBloc: sandboxBloc, isWeb: false);

      await tester.pumpWidget(
        buildSubject(router: router, sandboxBloc: sandboxBloc),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(router.state.matchedLocation, AppRoutes.onboarding);

      sandboxBloc.close();
      router.dispose();
    });

    testWidgets(
      '/onboarding route is always accessible directly without guards',
      (tester) async {
        final sandboxBloc = SandboxBloc();
        final router = createAppRouter(
          sandboxBloc: sandboxBloc,
          isWeb: false,
          initialLocation: AppRoutes.onboarding,
        );

        await tester.pumpWidget(
          buildSubject(router: router, sandboxBloc: sandboxBloc),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(router.state.matchedLocation, AppRoutes.onboarding);

        sandboxBloc.close();
        router.dispose();
      },
    );

    testWidgets(
      'navigating to /sandbox without active scenario redirects to /onboarding',
      (tester) async {
        final sandboxBloc = SandboxBloc();
        final router = createAppRouter(
          sandboxBloc: sandboxBloc,
          isWeb: false,
          initialLocation: AppRoutes.onboarding,
        );

        await tester.pumpWidget(
          buildSubject(router: router, sandboxBloc: sandboxBloc),
        );
        await tester.pumpAndSettle();

        router.go(AppRoutes.sandbox);
        await tester.pumpAndSettle();

        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.byType(SandboxScreen), findsNothing);
        expect(router.state.matchedLocation, AppRoutes.onboarding);

        sandboxBloc.close();
        router.dispose();
      },
    );

    testWidgets(
      'after scenario is initialized, navigating to /sandbox stays at /sandbox',
      (tester) async {
        final sandboxBloc = SandboxBloc();
        final router = createAppRouter(
          sandboxBloc: sandboxBloc,
          isWeb: false,
          initialLocation: AppRoutes.onboarding,
        );

        await tester.pumpWidget(
          buildSubject(router: router, sandboxBloc: sandboxBloc),
        );
        await tester.pumpAndSettle();

        sandboxBloc.add(
          const SandboxInitialized(
            liquidBalance: 100000,
            monthlyNetIncome: 50000,
          ),
        );
        await tester.pumpAndSettle();

        router.go(AppRoutes.sandbox);
        await tester.pumpAndSettle();

        expect(find.byType(SandboxScreen), findsOneWidget);
        expect(find.text(AppRoutes.sandbox), findsOneWidget);
        expect(router.state.matchedLocation, AppRoutes.sandbox);

        sandboxBloc.close();
        router.dispose();
      },
    );

    testWidgets(
      'on a web build (kIsWeb = true), navigating to /panic-room produces a final route of /sandbox',
      (tester) async {
        final sandboxBloc = SandboxBloc();
        sandboxBloc.add(
          const SandboxInitialized(
            liquidBalance: 100000,
            monthlyNetIncome: 50000,
          ),
        );

        final router = createAppRouter(
          sandboxBloc: sandboxBloc,
          isWeb: true,
          initialLocation: AppRoutes.sandbox,
        );

        await tester.pumpWidget(
          buildSubject(router: router, sandboxBloc: sandboxBloc),
        );
        await tester.pumpAndSettle();

        router.go(AppRoutes.panicRoom);
        await tester.pumpAndSettle();

        expect(find.byType(SandboxScreen), findsOneWidget);
        expect(find.byType(PanicRoomScreen), findsNothing);
        expect(router.state.matchedLocation, AppRoutes.sandbox);

        sandboxBloc.close();
        router.dispose();
      },
    );

    testWidgets(
      'on a web build without active scenario, navigating to /panic-room redirects through /sandbox to /onboarding',
      (tester) async {
        final sandboxBloc = SandboxBloc();
        final router = createAppRouter(
          sandboxBloc: sandboxBloc,
          isWeb: true,
          initialLocation: AppRoutes.onboarding,
        );

        await tester.pumpWidget(
          buildSubject(router: router, sandboxBloc: sandboxBloc),
        );
        await tester.pumpAndSettle();

        router.go(AppRoutes.panicRoom);
        await tester.pumpAndSettle();

        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.byType(PanicRoomScreen), findsNothing);
        expect(router.state.matchedLocation, AppRoutes.onboarding);

        sandboxBloc.close();
        router.dispose();
      },
    );

    testWidgets(
      'on a mobile build (kIsWeb = false), navigating to /panic-room stays at /panic-room',
      (tester) async {
        final sandboxBloc = SandboxBloc();
        final router = createAppRouter(
          sandboxBloc: sandboxBloc,
          isWeb: false,
          initialLocation: AppRoutes.onboarding,
        );

        await tester.pumpWidget(
          buildSubject(router: router, sandboxBloc: sandboxBloc),
        );
        await tester.pumpAndSettle();

        router.go(AppRoutes.panicRoom);
        await tester.pumpAndSettle();

        expect(find.byType(PanicRoomScreen), findsOneWidget);
        expect(find.text(AppRoutes.panicRoom), findsOneWidget);
        expect(router.state.matchedLocation, AppRoutes.panicRoom);

        sandboxBloc.close();
        router.dispose();
      },
    );

    testWidgets(
      'scoped BlocProvider provides PanicRoomBloc exclusively at /panic-room route on mobile',
      (tester) async {
        final sandboxBloc = SandboxBloc();
        final router = createAppRouter(
          sandboxBloc: sandboxBloc,
          isWeb: false,
          initialLocation: AppRoutes.onboarding,
        );

        await tester.pumpWidget(
          buildSubject(router: router, sandboxBloc: sandboxBloc),
        );
        await tester.pumpAndSettle();

        router.go(AppRoutes.panicRoom);
        await tester.pumpAndSettle();

        final panicRoomScreenContext = tester.element(
          find.byType(PanicRoomScreen),
        );
        final panicRoomBloc = BlocProvider.of<PanicRoomBloc>(
          panicRoomScreenContext,
        );
        expect(panicRoomBloc, isA<PanicRoomBloc>());

        sandboxBloc.close();
        router.dispose();
      },
    );

    testWidgets(
      'ValueNotifier notifies router when SandboxBloc state updates',
      (tester) async {
        final sandboxBloc = SandboxBloc();
        final notifier = SandboxListenableNotifier(sandboxBloc);
        var notificationCount = 0;
        notifier.addListener(() {
          notificationCount++;
        });

        sandboxBloc.add(
          const SandboxInitialized(
            liquidBalance: 50000,
            monthlyNetIncome: 25000,
          ),
        );
        await tester.pumpAndSettle();

        expect(notificationCount, greaterThan(0));
        expect(notifier.value.scenarios.isNotEmpty, isTrue);

        notifier.dispose();
        sandboxBloc.close();
      },
    );
  });

  group('appRouterRedirect unit tests', () {
    test('redirects /panic-room to /sandbox when isWeb is true', () {
      final sandboxBloc = SandboxBloc();
      final state = MockGoRouterState(matchedLocation: AppRoutes.panicRoom);

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        sandboxBloc: sandboxBloc,
        isWeb: true,
      );

      expect(redirect, AppRoutes.sandbox);
      sandboxBloc.close();
    });

    test('allows /panic-room when isWeb is false', () {
      final sandboxBloc = SandboxBloc();
      final state = MockGoRouterState(matchedLocation: AppRoutes.panicRoom);

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        sandboxBloc: sandboxBloc,
        isWeb: false,
      );

      expect(redirect, isNull);
      sandboxBloc.close();
    });

    test('redirects /sandbox to /onboarding when scenarios are empty', () {
      final sandboxBloc = SandboxBloc();
      final state = MockGoRouterState(matchedLocation: AppRoutes.sandbox);

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        sandboxBloc: sandboxBloc,
        isWeb: false,
      );

      expect(redirect, AppRoutes.onboarding);
      sandboxBloc.close();
    });

    test('allows /sandbox when scenarios are present', () {
      final sandboxBloc = SandboxBloc();
      sandboxBloc.emit(
        sandboxBloc.state.copyWith(
          scenarios: {
            's1': const Scenario(id: 's1', name: 'Scenario A', eventIds: []),
          },
        ),
      );

      final state = MockGoRouterState(matchedLocation: AppRoutes.sandbox);

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        sandboxBloc: sandboxBloc,
        isWeb: false,
      );

      expect(redirect, isNull);
      sandboxBloc.close();
    });

    test('always allows /onboarding without redirecting', () {
      final sandboxBloc = SandboxBloc();
      final state = MockGoRouterState(matchedLocation: AppRoutes.onboarding);

      final redirect = appRouterRedirect(
        MockBuildContext(),
        state,
        sandboxBloc: sandboxBloc,
        isWeb: false,
      );

      expect(redirect, isNull);
      sandboxBloc.close();
    });
  });
}

class MockBuildContext extends Fake implements BuildContext {}

class MockGoRouterState extends Fake implements GoRouterState {
  @override
  final String matchedLocation;

  MockGoRouterState({required this.matchedLocation});
}
