import 'package:finance_pulse/core/constants/app_routes.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_colors.dart';
import 'package:finance_pulse/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:finance_pulse/injection_container.dart' as di;
import 'package:finance_pulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await di.locator.reset();
    await di.init();
  });

  tearDown(() async {
    await di.locator.reset();
  });

  testWidgets(
      'PulseApp launches and displays onboarding placeholder on cold start',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text(AppRoutes.onboarding), findsOneWidget);
  });

  testWidgets('PulseApp renders dark theme by default when system is dark',
      (WidgetTester tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const PulseApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final BuildContext context = tester.element(find.byType(OnboardingScreen));
    final theme = Theme.of(context);

    expect(theme.brightness, equals(Brightness.dark));
    expect(theme.colorScheme.primary, equals(PulseColors.primary));
    expect(materialApp.theme?.brightness, equals(Brightness.light));
    expect(materialApp.darkTheme?.brightness, equals(Brightness.dark));
  });

  testWidgets('PulseApp switches to light theme when system is light without contrast failure',
      (WidgetTester tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const PulseApp());
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(OnboardingScreen));
    final theme = Theme.of(context);

    expect(theme.brightness, equals(Brightness.light));
    expect(theme.colorScheme.primary, equals(PulseColors.lightPrimary));

    // Verify contrast ratio >= 4.5:1
    final contrast = PulseColors.contrastRatio(
      theme.colorScheme.primary,
      theme.scaffoldBackgroundColor,
    );
    expect(contrast, greaterThanOrEqualTo(4.5));
  });
}
