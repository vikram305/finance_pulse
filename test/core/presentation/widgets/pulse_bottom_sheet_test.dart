import 'dart:ui';

import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/pulse_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseBottomSheet', () {
    testWidgets('renders glassmorphic container with 24px top corners and blur', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: const Scaffold(
            body: PulseBottomSheet(
              child: Text('Sheet Body Content'),
            ),
          ),
        ),
      );

      expect(find.text('Sheet Body Content'), findsOneWidget);

      // Verify ClipRRect has 24px top radius
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(
        clipRRect.borderRadius,
        equals(const BorderRadius.vertical(top: Radius.circular(24))),
      );

      // Verify BackdropFilter with 12px blur
      final backdropFilter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      final filter = backdropFilter.filter;
      expect(filter, equals(ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0)));

      // Verify drag handle exists
      expect(find.byKey(const Key('pulse_bottom_sheet_drag_handle')), findsOneWidget);
    });

    testWidgets('PulseBottomSheet.show launches modal bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    PulseBottomSheet.show(
                      context: context,
                      child: const Text('Modal Content'),
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Content'), findsOneWidget);
      expect(find.byType(PulseBottomSheet), findsOneWidget);
    });
  });
}

