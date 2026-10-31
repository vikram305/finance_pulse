import 'package:finance_pulse/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants', () {
    test('projection window constants are configured correctly', () {
      expect(AppConstants.minProjectionMonths, equals(12));
      expect(AppConstants.intermediateProjectionMonths, equals(24));
      expect(AppConstants.maxProjectionMonths, equals(36));
      expect(AppConstants.defaultProjectionMonths, equals(12));
      expect(
        AppConstants.allowedProjectionWindows,
        equals(const [12, 24, 36]),
      );
    });

    test('scenario limit constants are configured correctly', () {
      expect(AppConstants.minActiveScenarios, equals(1));
      expect(AppConstants.maxActiveScenarios, equals(2));
    });

    test('UI and layout constants are configured correctly', () {
      expect(AppConstants.webMaxContentWidth, equals(1200.0));
      expect(AppConstants.onboardingFormMaxWidth, equals(520.0));
      expect(AppConstants.inputBorderWidth, equals(1.5));
      expect(AppConstants.primaryButtonHeight, equals(52.0));
      expect(AppConstants.shimmerDuration, equals(const Duration(milliseconds: 1500)));
    });
  });
}
