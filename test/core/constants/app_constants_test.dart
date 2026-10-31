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
  });
}
