import 'package:finance_pulse/core/presentation/theme/pulse_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseColors Token Definitions', () {
    test('primary Deep Indigo matches HSL(255, 45%, 55%)', () {
      final expected =
          HSLColor.fromAHSL(1.0, 255.0, 0.45, 0.55).toColor();
      expect(PulseColors.primary, equals(expected));
    });

    test('secondary Amber matches HSL(38, 80%, 52%)', () {
      final expected =
          HSLColor.fromAHSL(1.0, 38.0, 0.80, 0.52).toColor();
      expect(PulseColors.secondary, equals(expected));
    });

    test('income Teal matches HSL(174, 55%, 45%)', () {
      final expected =
          HSLColor.fromAHSL(1.0, 174.0, 0.55, 0.45).toColor();
      expect(PulseColors.income, equals(expected));
      expect(PulseColors.teal, equals(expected));
    });

    test('expense Rose matches HSL(350, 60%, 55%)', () {
      final expected =
          HSLColor.fromAHSL(1.0, 350.0, 0.60, 0.55).toColor();
      expect(PulseColors.expense, equals(expected));
      expect(PulseColors.rose, equals(expected));
    });

    test('semantic error matches Rose HSL(350, 65%, 58%)', () {
      final expected =
          HSLColor.fromAHSL(1.0, 350.0, 0.65, 0.58).toColor();
      expect(PulseColors.error, equals(expected));
    });

    test('semantic warning matches Gold HSL(45, 90%, 52%)', () {
      final expected =
          HSLColor.fromAHSL(1.0, 45.0, 0.90, 0.52).toColor();
      expect(PulseColors.warning, equals(expected));
    });

    test('semantic success matches Emerald HSL(155, 55%, 42%)', () {
      final expected =
          HSLColor.fromAHSL(1.0, 155.0, 0.55, 0.42).toColor();
      expect(PulseColors.success, equals(expected));
    });

    test('semantic info matches Sky HSL(200, 75%, 52%)', () {
      final expected =
          HSLColor.fromAHSL(1.0, 200.0, 0.75, 0.52).toColor();
      expect(PulseColors.info, equals(expected));
    });
  });

  group('PulseColors Dark Surface Tokens', () {
    test('dark background has lightness <= 10%', () {
      final hsl = HSLColor.fromColor(PulseColors.darkBackground);
      expect(hsl.lightness, lessThanOrEqualTo(0.10));
    });

    test('dark surface has lightness between 8% and 12%', () {
      final hsl = HSLColor.fromColor(PulseColors.darkSurface);
      expect(hsl.lightness, greaterThanOrEqualTo(0.08));
      expect(hsl.lightness, lessThanOrEqualTo(0.12));
    });
  });

  group('PulseColors Accessibility and Contrast', () {
    test('light theme primary achieves WCAG AA 4.5:1 contrast against white background', () {
      final contrast = PulseColors.contrastRatio(
        PulseColors.lightPrimary,
        PulseColors.lightBackground,
      );
      expect(contrast, greaterThanOrEqualTo(4.5));
    });

    test('white text on dark background achieves WCAG AA contrast (>= 4.5:1)', () {
      final contrast = PulseColors.contrastRatio(
        PulseColors.darkOnSurface,
        PulseColors.darkBackground,
      );
      expect(contrast, greaterThanOrEqualTo(4.5));
    });

    test('dark text on light background achieves WCAG AA contrast (>= 4.5:1)', () {
      final contrast = PulseColors.contrastRatio(
        PulseColors.lightOnSurface,
        PulseColors.lightBackground,
      );
      expect(contrast, greaterThanOrEqualTo(4.5));
    });
  });
}

