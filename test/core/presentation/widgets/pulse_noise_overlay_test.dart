import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/pulse_noise_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseNoiseOverlay', () {
    testWidgets('renders child widget with subtle noise painter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.dark(),
          home: const Scaffold(
            body: PulseNoiseOverlay(
              child: Text('Surface with noise texture'),
            ),
          ),
        ),
      );

      expect(find.text('Surface with noise texture'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('noise opacity default is configured between 3% and 5%', () {
      const overlay = PulseNoiseOverlay(child: SizedBox());
      expect(overlay.opacity, greaterThanOrEqualTo(0.03));
      expect(overlay.opacity, lessThanOrEqualTo(0.05));
    });
  });
}

