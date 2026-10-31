import 'package:finance_pulse/core/constants/app_strings.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/pulse_tap_target.dart';
import 'package:finance_pulse/features/onboarding/presentation/widgets/onboarding_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({required VoidCallback onTap}) {
    return MaterialApp(
      theme: PulseTheme.dark(),
      home: Scaffold(
        body: OnboardingSubmitButton(onTap: onTap),
      ),
    );
  }

  group('OnboardingSubmitButton', () {
    testWidgets('renders button text and wraps in PulseTapTarget', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(onTap: () {}));

      expect(find.text(AppStrings.onboardingSubmitButton), findsOneWidget);
      expect(find.byType(PulseTapTarget), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(PulseTapTarget)).label,
        contains(AppStrings.onboardingSubmitSemantics),
      );
      handle.dispose();
    });

    testWidgets('triggers onTap callback when pressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(buildSubject(onTap: () => pressed = true));

      await tester.tap(find.byType(PulseTapTarget));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
  });
}
