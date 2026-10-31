import 'package:finance_pulse/core/constants/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppStrings', () {
    test('defines all required onboarding and banner strings', () {
      expect(AppStrings.appTitle, equals('Pulse'));
      expect(
        AppStrings.onboardingBalanceLabel,
        equals('Current Liquid Balance'),
      );
      expect(AppStrings.onboardingIncomeLabel, equals('Monthly Net Income'));
      expect(AppStrings.onboardingCurrencyPrefix, equals('₹'));
      expect(
        AppStrings.onboardingBalanceSemantics,
        equals('Current liquid balance input'),
      );
      expect(
        AppStrings.onboardingIncomeSemantics,
        equals('Monthly net income input'),
      );
      expect(AppStrings.onboardingSubmitButton, equals('See Projections'));
      expect(
        AppStrings.strawmanNotice,
        contains('Strawman blocks below are auto-generated estimates'),
      );
      expect(
        AppStrings.webVolatileBanner,
        contains('Browser storage is volatile'),
      );
      expect(
        AppStrings.dismissVolatileBanner,
        equals('Dismiss volatile storage banner'),
      );
      expect(
        AppStrings.dismissStrawmanNotice,
        equals('Dismiss Strawman notice'),
      );
      expect(
        AppStrings.skeletonLoaderSemantics,
        equals('Generating strawman scenario'),
      );
    });
  });
}
