import 'package:finance_pulse/core/constants/app_strings.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_colors.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/pulse_tap_target.dart';
import 'package:finance_pulse/core/presentation/widgets/skeleton_loader.dart';
import 'package:finance_pulse/core/router/app_router.dart';
import 'package:finance_pulse/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:finance_pulse/features/onboarding/presentation/widgets/web_volatile_banner.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_bloc.dart';
import 'package:finance_pulse/features/sandbox/presentation/screens/sandbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late SandboxBloc sandboxBloc;

  setUp(() {
    sandboxBloc = SandboxBloc();
  });

  tearDown(() {
    sandboxBloc.close();
  });

  Widget buildSubject({
    SandboxBloc? bloc,
    bool isWeb = false,
    GoRouter? router,
  }) {
    final effectiveBloc = bloc ?? sandboxBloc;
    final effectiveRouter =
        router ??
        createAppRouter(
          sandboxBloc: effectiveBloc,
          isWeb: isWeb,
          initialLocation: AppRoutes.onboarding,
        );

    return BlocProvider<SandboxBloc>.value(
      value: effectiveBloc,
      child: MaterialApp.router(
        theme: PulseTheme.dark(),
        routerConfig: effectiveRouter,
      ),
    );
  }

  group('OnboardingScreen', () {
    group('Screen Layout & First Impression', () {
      testWidgets(
        'opens directly to Onboarding without splash, PIN, or account prompts',
        (tester) async {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          expect(find.byType(OnboardingScreen), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.textContaining('PIN'), findsNothing);
          expect(find.textContaining('Account'), findsNothing);
          expect(find.textContaining('Sign in'), findsNothing);
        },
      );

      testWidgets(
        'renders hero titles, input labels, semantic labels, and currency prefixes',
        (tester) async {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          expect(find.text(AppStrings.onboardingTitle), findsOneWidget);
          expect(find.text(AppStrings.onboardingSubtitle), findsOneWidget);
          expect(find.text(AppStrings.onboardingBalanceLabel), findsOneWidget);
          expect(find.text(AppStrings.onboardingIncomeLabel), findsOneWidget);
          expect(find.text('₹'), findsNWidgets(2));

          expect(
            find.bySemanticsLabel(AppStrings.onboardingBalanceSemantics),
            findsOneWidget,
          );
          expect(
            find.bySemanticsLabel(AppStrings.onboardingIncomeSemantics),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'renders submit button with Deep Indigo background and white text',
        (tester) async {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          final submitButtonFinder = find.widgetWithText(
            PulseTapTarget,
            AppStrings.onboardingSubmitButton,
          );
          expect(submitButtonFinder, findsOneWidget);

          final container = tester.widget<Container>(
            find.byKey(const ValueKey('submit_button_container')),
          );
          final decoration = container.decoration as BoxDecoration?;
          expect(decoration?.color, equals(PulseColors.primary));
        },
      );
    });

    group('Web Volatile Storage Banner', () {
      testWidgets('displays WebVolatileBanner when isWeb is true', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject(isWeb: true));
        await tester.pumpAndSettle();

        expect(find.byType(WebVolatileBanner), findsOneWidget);
        expect(find.text(AppStrings.webVolatileBanner), findsOneWidget);
      });

      testWidgets(
        'does not display WebVolatileBanner on mobile (isWeb: false)',
        (tester) async {
          await tester.pumpWidget(buildSubject(isWeb: false));
          await tester.pumpAndSettle();

          expect(find.text(AppStrings.webVolatileBanner), findsNothing);
        },
      );

      testWidgets('dismissing banner on web animates out in-memory only', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject(isWeb: true));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.webVolatileBanner), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.webVolatileBanner), findsNothing);
      });
    });

    group('Input Validation', () {
      testWidgets(
        'blocks submission and displays inline errors when fields are empty',
        (tester) async {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          final submitFinder = find.widgetWithText(
            PulseTapTarget,
            AppStrings.onboardingSubmitButton,
          );
          await tester.tap(submitFinder);
          await tester.pumpAndSettle();

          expect(
            find.text(AppStrings.onboardingBalanceRequired),
            findsOneWidget,
          );
          expect(
            find.text(AppStrings.onboardingIncomeRequired),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.error_outline), findsNWidgets(2));
          expect(find.textContaining('Exception'), findsNothing);
          expect(sandboxBloc.state.scenarios, isEmpty);
        },
      );

      testWidgets(
        'blocks submission and displays inline errors when numbers are <= 0',
        (tester) async {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          final balanceField = find.byKey(const ValueKey('balance_input'));
          final incomeField = find.byKey(const ValueKey('income_input'));

          await tester.enterText(balanceField, '0');
          await tester.enterText(incomeField, '-500');

          final submitFinder = find.widgetWithText(
            PulseTapTarget,
            AppStrings.onboardingSubmitButton,
          );
          await tester.tap(submitFinder);
          await tester.pumpAndSettle();

          expect(
            find.text(AppStrings.onboardingBalancePositive),
            findsOneWidget,
          );
          expect(
            find.text(AppStrings.onboardingIncomePositive),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.error_outline), findsNWidgets(2));
          expect(find.textContaining('Exception'), findsNothing);
          expect(sandboxBloc.state.scenarios, isEmpty);
        },
      );
    });

    group('Keyboard Actions & Focus', () {
      testWidgets(
        'keyboard next on balance field moves focus to monthly income field',
        (tester) async {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          final balanceField = find.byKey(const ValueKey('balance_input'));
          final incomeField = find.byKey(const ValueKey('income_input'));

          await tester.tap(balanceField);
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(balanceField).focusNode!.hasFocus,
            isTrue,
          );

          await tester.testTextInput.receiveAction(TextInputAction.next);
          await tester.pumpAndSettle();

          expect(
            tester.widget<TextField>(incomeField).focusNode!.hasFocus,
            isTrue,
          );
        },
      );

      testWidgets(
        'keyboard done on monthly income field triggers form submission',
        (tester) async {
          final localBloc = SandboxBloc();
          await tester.pumpWidget(buildSubject(bloc: localBloc));
          await tester.pumpAndSettle();

          final balanceField = find.byKey(const ValueKey('balance_input'));
          final incomeField = find.byKey(const ValueKey('income_input'));

          await tester.enterText(balanceField, '100000');
          await tester.enterText(incomeField, '60000');
          await tester.pumpAndSettle();

          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          expect(localBloc.state.scenarios, isNotEmpty);
          expect(find.byType(SandboxScreen), findsOneWidget);
          localBloc.close();
        },
      );

      testWidgets(
        'web tab navigation sequence: focus flows from Balance input -> Income input -> Submit button',
        (tester) async {
          await tester.pumpWidget(buildSubject(isWeb: true));
          await tester.pumpAndSettle();

          final balanceField = find.byKey(const ValueKey('balance_input'));
          final incomeField = find.byKey(const ValueKey('income_input'));

          await tester.tap(balanceField);
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(balanceField).focusNode!.hasFocus,
            isTrue,
          );

          // Tab to income input
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(incomeField).focusNode!.hasFocus,
            isTrue,
          );

          // Tab to submit button
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          final submitFocusNode = Focus.of(
            tester.element(find.text(AppStrings.onboardingSubmitButton)),
          );
          expect(submitFocusNode.hasFocus, isTrue);
        },
      );

      testWidgets(
        'web enter key submission: pressing Enter while submit button has focus triggers form submission',
        (tester) async {
          final localBloc = SandboxBloc();
          await tester.pumpWidget(buildSubject(bloc: localBloc, isWeb: true));
          await tester.pumpAndSettle();

          final balanceField = find.byKey(const ValueKey('balance_input'));
          final incomeField = find.byKey(const ValueKey('income_input'));
          final submitButtonText = find.text(AppStrings.onboardingSubmitButton);

          await tester.enterText(balanceField, '200000');
          await tester.enterText(incomeField, '80000');
          await tester.pumpAndSettle();

          // Focus the submit button
          final submitFocusNode = Focus.of(tester.element(submitButtonText));
          submitFocusNode.requestFocus();
          await tester.pumpAndSettle();
          expect(submitFocusNode.hasFocus, isTrue);

          // Press Enter to submit
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();

          expect(localBloc.state.scenarios, isNotEmpty);
          expect(find.byType(SandboxScreen), findsOneWidget);
          localBloc.close();
        },
      );
    });

    group('Submission, Shimmer SkeletonLoader & Navigation', () {
      testWidgets(
        'valid submission dispatches SandboxInitialized and transitions to /sandbox',
        (tester) async {
          final localBloc = SandboxBloc();
          await tester.pumpWidget(buildSubject(bloc: localBloc));
          await tester.pumpAndSettle();

          final balanceField = find.byKey(const ValueKey('balance_input'));
          final incomeField = find.byKey(const ValueKey('income_input'));

          await tester.enterText(balanceField, '150000');
          await tester.enterText(incomeField, '75000');
          await tester.pumpAndSettle();

          final submitFinder = find.widgetWithText(
            PulseTapTarget,
            AppStrings.onboardingSubmitButton,
          );
          await tester.tap(submitFinder);

          // While submitting/processing, SkeletonLoader is displayed
          await tester.pump();
          expect(find.byType(SkeletonLoader), findsOneWidget);

          // Advance to complete transition to /sandbox
          await tester.pumpAndSettle();

          expect(find.byType(SandboxScreen), findsOneWidget);
          expect(localBloc.state.liquidBalance, equals(150000.0));
          expect(localBloc.state.monthlyNetIncome, equals(75000.0));
          localBloc.close();
        },
      );
    });

    group('Accessibility Guidelines', () {
      testWidgets('meets androidTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets iOSTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets labeledTapTargetGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets textContrastGuideline', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    });
  });
}
