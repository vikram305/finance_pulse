import 'package:finance_pulse/core/presentation/theme/pulse_spacing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseSpacing Constants', () {
    test('defines exact 4px-base spacing scale constants', () {
      expect(PulseSpacing.xs, equals(4.0));
      expect(PulseSpacing.sm, equals(8.0));
      expect(PulseSpacing.md, equals(12.0));
      expect(PulseSpacing.base, equals(16.0));
      expect(PulseSpacing.lg, equals(24.0));
      expect(PulseSpacing.xl, equals(32.0));
      expect(PulseSpacing.xxl, equals(48.0));
      expect(PulseSpacing.xxxl, equals(64.0));
    });

    test('spacing constants are strictly monotonically increasing', () {
      final values = [
        PulseSpacing.xs,
        PulseSpacing.sm,
        PulseSpacing.md,
        PulseSpacing.base,
        PulseSpacing.lg,
        PulseSpacing.xl,
        PulseSpacing.xxl,
        PulseSpacing.xxxl,
      ];

      for (int i = 0; i < values.length - 1; i++) {
        expect(values[i], lessThan(values[i + 1]));
      }
    });
  });
}

