import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/pulse_web_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseWebLayout Constraints & Centering', () {
    testWidgets('constrains wide screens to max width 1200px and centers content', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: const Scaffold(
            body: PulseWebLayout(
              child: Text('Web Content'),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(PulseWebLayout),
          matching: find.byType(ConstrainedBox),
        ),
      );

      expect(constrainedBox.constraints.maxWidth, equals(1200.0));
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('breakpoint 768px: renders compact layout below 768px and wide layout above', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: Scaffold(
            body: PulseWebLayout.responsive(
              compact: const Text('Mobile Layout'),
              wide: const Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Desktop Layout'), findsNothing);

      // Change to desktop width (> 768px)
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpAndSettle();

      expect(find.text('Desktop Layout'), findsOneWidget);
      expect(find.text('Mobile Layout'), findsNothing);
    });
  });
}

