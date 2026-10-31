import 'package:finance_pulse/core/presentation/theme/pulse_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseTextStyles Typography Contract', () {
    testWidgets('dataHero is 52px, weight 700 with JetBrains Mono font', (tester) async {
      final style = PulseTextStyles.dataHero;
      expect(style.fontSize, equals(52.0));
      expect(style.fontWeight, equals(FontWeight.w700));
      expect(style.fontFamily?.toLowerCase(), contains('jetbrains'));
    });

    testWidgets('financialValue is 24px, weight 600 with JetBrains Mono font', (tester) async {
      final style = PulseTextStyles.financialValue;
      expect(style.fontSize, equals(24.0));
      expect(style.fontWeight, equals(FontWeight.w600));
      expect(style.fontFamily?.toLowerCase(), contains('jetbrains'));
    });

    testWidgets('financialLabel is 14px, weight 400 with JetBrains Mono font', (tester) async {
      final style = PulseTextStyles.financialLabel;
      expect(style.fontSize, equals(14.0));
      expect(style.fontWeight, equals(FontWeight.w400));
      expect(style.fontFamily?.toLowerCase(), contains('jetbrains'));
    });

    testWidgets('dataInline is 15px, weight 600 with JetBrains Mono font', (tester) async {
      final style = PulseTextStyles.dataInline;
      expect(style.fontSize, equals(15.0));
      expect(style.fontWeight, equals(FontWeight.w600));
      expect(style.fontFamily?.toLowerCase(), contains('jetbrains'));
    });

    testWidgets('dataSmall is 12px, weight 500 with JetBrains Mono font', (tester) async {
      final style = PulseTextStyles.dataSmall;
      expect(style.fontSize, equals(12.0));
      expect(style.fontWeight, equals(FontWeight.w500));
      expect(style.fontFamily?.toLowerCase(), contains('jetbrains'));
    });

    testWidgets('display is 36px, weight 600 with Inter font', (tester) async {
      final style = PulseTextStyles.display;
      expect(style.fontSize, equals(36.0));
      expect(style.fontWeight, equals(FontWeight.w600));
      expect(style.fontFamily?.toLowerCase(), contains('inter'));
    });

    testWidgets('bodyLarge, bodyMedium, bodySmall use Inter font with correct hierarchy', (tester) async {
      expect(PulseTextStyles.bodyLarge.fontSize, equals(16.0));
      expect(PulseTextStyles.bodyLarge.fontFamily?.toLowerCase(), contains('inter'));

      expect(PulseTextStyles.bodyMedium.fontSize, equals(14.0));
      expect(PulseTextStyles.bodyMedium.fontFamily?.toLowerCase(), contains('inter'));

      expect(PulseTextStyles.bodySmall.fontSize, equals(12.0));
      expect(PulseTextStyles.bodySmall.fontFamily?.toLowerCase(), contains('inter'));
    });

    testWidgets('labelMedium and labelSmall use Inter font with weight 500', (tester) async {
      expect(PulseTextStyles.labelMedium.fontWeight, equals(FontWeight.w500));
      expect(PulseTextStyles.labelMedium.fontFamily?.toLowerCase(), contains('inter'));

      expect(PulseTextStyles.labelSmall.fontWeight, equals(FontWeight.w500));
      expect(PulseTextStyles.labelSmall.fontFamily?.toLowerCase(), contains('inter'));
    });
  });
}
