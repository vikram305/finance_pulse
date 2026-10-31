import 'package:finance_pulse/core/presentation/theme/pulse_colors.dart';
import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseTheme.dark', () {
    testWidgets('enables Material 3 and dark brightness', (tester) async {
      final theme = PulseTheme.dark();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.dark));
    });

    testWidgets('configures ColorScheme with palette tokens', (tester) async {
      final theme = PulseTheme.dark();
      expect(theme.colorScheme.brightness, equals(Brightness.dark));
      expect(theme.colorScheme.primary, equals(PulseColors.primary));
      expect(theme.colorScheme.secondary, equals(PulseColors.secondary));
      expect(theme.colorScheme.error, equals(PulseColors.error));
      expect(theme.scaffoldBackgroundColor, equals(PulseColors.darkBackground));
    });

    testWidgets('textTheme applies Inter base font', (tester) async {
      final theme = PulseTheme.dark();
      final bodyLarge = theme.textTheme.bodyLarge;
      expect(bodyLarge?.fontFamily?.toLowerCase(), contains('inter'));
    });
  });

  group('PulseTheme.light', () {
    testWidgets('enables Material 3 and light brightness', (tester) async {
      final theme = PulseTheme.light();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.light));
    });

    testWidgets('configures ColorScheme with adjusted primary for contrast', (tester) async {
      final theme = PulseTheme.light();
      expect(theme.colorScheme.brightness, equals(Brightness.light));
      expect(theme.colorScheme.primary, equals(PulseColors.lightPrimary));
      expect(theme.colorScheme.secondary, equals(PulseColors.secondary));
      expect(theme.scaffoldBackgroundColor, equals(PulseColors.lightBackground));
    });

    testWidgets('textTheme applies Inter base font', (tester) async {
      final theme = PulseTheme.light();
      final bodyLarge = theme.textTheme.bodyLarge;
      expect(bodyLarge?.fontFamily?.toLowerCase(), contains('inter'));
    });
  });
}
