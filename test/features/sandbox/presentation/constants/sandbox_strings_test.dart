import 'package:finance_pulse/features/sandbox/presentation/constants/sandbox_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SandboxStrings', () {
    test('constants have expected values', () {
      expect(SandboxStrings.rent, equals('Rent'));
      expect(SandboxStrings.livingCosts, equals('Living Costs'));
      expect(SandboxStrings.emi, equals('EMI'));
      expect(SandboxStrings.defaultScenarioName, equals('Scenario A'));
    });

    test('scenarioCopy formats name with (Copy) suffix', () {
      expect(
        SandboxStrings.scenarioCopy('Scenario A'),
        equals('Scenario A (Copy)'),
      );
      expect(
        SandboxStrings.scenarioCopy('My Plan'),
        equals('My Plan (Copy)'),
      );
    });
  });
}
