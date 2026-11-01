import 'dart:ui';
import 'package:finance_pulse/core/presentation/theme/pulse_colors.dart';
import 'package:finance_pulse/domain/entities/projection_node.dart';
import 'package:finance_pulse/features/sandbox/presentation/widgets/trajectory_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });
  List<ProjectionNode> createMockNodes({
    required int count,
    required double startBalance,
    required double netFlow,
  }) {
    final nodes = <ProjectionNode>[];
    var current = startBalance;
    for (var i = 0; i < count; i++) {
      final ending = current + netFlow;
      nodes.add(
        ProjectionNode(
          monthIndex: i,
          startingBalance: current,
          netCashFlow: netFlow,
          endingBalance: ending,
          activeEventIds: const ['ev-1'],
        ),
      );
      current = ending;
    }
    return nodes;
  }

  group('TrajectoryPainter', () {
    test(
      'PulseCurrencyFormatter formats compact Indian currency values correctly',
      () {
        expect(PulseCurrencyFormatter.format(0), equals('₹0'));
        expect(PulseCurrencyFormatter.format(80000), equals('₹80K'));
        expect(PulseCurrencyFormatter.format(120000), equals('₹1.2L'));
        expect(PulseCurrencyFormatter.format(1000000), equals('₹10L'));
        expect(PulseCurrencyFormatter.format(10000000), equals('₹1Cr'));
        expect(PulseCurrencyFormatter.format(-50000), equals('-₹50K'));
        expect(PulseCurrencyFormatter.format(-150000), equals('-₹1.5L'));
      },
    );

    test('shouldRepaint returns false when properties are identical', () {
      final nodes = createMockNodes(
        count: 12,
        startBalance: 100000,
        netFlow: 10000,
      );
      final painter1 = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodes},
        scenarioColours: {'scenario_a': PulseColors.primary},
        windowMonths: 12,
        initialBalance: 100000,
        isDark: true,
      );
      final painter2 = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodes},
        scenarioColours: {'scenario_a': PulseColors.primary},
        windowMonths: 12,
        initialBalance: 100000,
        isDark: true,
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('shouldRepaint returns true when windowMonths changes', () {
      final nodes = createMockNodes(
        count: 24,
        startBalance: 100000,
        netFlow: 10000,
      );
      final painter1 = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodes},
        scenarioColours: {'scenario_a': PulseColors.primary},
        windowMonths: 12,
        initialBalance: 100000,
        isDark: true,
      );
      final painter2 = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodes},
        scenarioColours: {'scenario_a': PulseColors.primary},
        windowMonths: 24,
        initialBalance: 100000,
        isDark: true,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when projections data changes', () {
      final nodes1 = createMockNodes(
        count: 12,
        startBalance: 100000,
        netFlow: 10000,
      );
      final nodes2 = createMockNodes(
        count: 12,
        startBalance: 100000,
        netFlow: -5000,
      );
      final painter1 = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodes1},
        scenarioColours: {'scenario_a': PulseColors.primary},
        windowMonths: 12,
        initialBalance: 100000,
        isDark: true,
      );
      final painter2 = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodes2},
        scenarioColours: {'scenario_a': PulseColors.primary},
        windowMonths: 12,
        initialBalance: 100000,
        isDark: true,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test(
      'shouldRepaint returns true when scenario colours or isDark change',
      () {
        final nodes = createMockNodes(
          count: 12,
          startBalance: 100000,
          netFlow: 10000,
        );
        final painter1 = TrajectoryPainter(
          projectionsByScenarioId: {'scenario_a': nodes},
          scenarioColours: {'scenario_a': PulseColors.primary},
          windowMonths: 12,
          initialBalance: 100000,
          isDark: true,
        );
        final painter2 = TrajectoryPainter(
          projectionsByScenarioId: {'scenario_a': nodes},
          scenarioColours: {'scenario_a': Colors.red},
          windowMonths: 12,
          initialBalance: 100000,
          isDark: true,
        );
        final painter3 = TrajectoryPainter(
          projectionsByScenarioId: {'scenario_a': nodes},
          scenarioColours: {'scenario_a': PulseColors.primary},
          windowMonths: 12,
          initialBalance: 100000,
          isDark: false,
        );

        expect(painter1.shouldRepaint(painter2), isTrue);
        expect(painter1.shouldRepaint(painter3), isTrue);
      },
    );

    test('paints without error for empty projections or zero size', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const painter = TrajectoryPainter(
        projectionsByScenarioId: {},
        scenarioColours: {},
        windowMonths: 12,
        initialBalance: 0,
        isDark: true,
      );

      // Should return early safely
      painter.paint(canvas, Size.zero);
      painter.paint(canvas, const Size(400, 300));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    testWidgets('paints single scenario without error', (tester) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final nodes = createMockNodes(
        count: 12,
        startBalance: 50000,
        netFlow: 10000,
      );
      final painter = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodes},
        scenarioColours: {'scenario_a': PulseColors.primary},
        windowMonths: 12,
        initialBalance: 50000,
        isDark: true,
      );

      painter.paint(canvas, const Size(400, 300));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    testWidgets('paints dual scenarios with dips below ₹0 without error', (
      tester,
    ) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final nodesA = createMockNodes(
        count: 12,
        startBalance: 50000,
        netFlow: 10000,
      );
      // Dips below zero: starts at 50,000, decreases by 20,000 per month
      final nodesB = createMockNodes(
        count: 12,
        startBalance: 50000,
        netFlow: -20000,
      );
      final painter = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodesA, 'scenario_b': nodesB},
        scenarioColours: {
          'scenario_a': PulseColors.primary,
          'scenario_b': PulseColors.secondary,
        },
        scenarioNames: {
          'scenario_a': 'Base Plan',
          'scenario_b': 'Emergency Plan',
        },
        windowMonths: 12,
        initialBalance: 50000,
        isDark: false,
      );

      painter.paint(canvas, const Size(400, 300));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    testWidgets('paints 24M and 36M projection windows correctly', (
      tester,
    ) async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final nodes = createMockNodes(
        count: 36,
        startBalance: 50000,
        netFlow: 5000,
      );

      final painter24 = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodes},
        scenarioColours: {'scenario_a': PulseColors.primary},
        windowMonths: 24,
        initialBalance: 50000,
        isDark: true,
      );
      painter24.paint(canvas, const Size(400, 300));

      final painter36 = TrajectoryPainter(
        projectionsByScenarioId: {'scenario_a': nodes},
        scenarioColours: {'scenario_a': PulseColors.primary},
        windowMonths: 36,
        initialBalance: 50000,
        isDark: true,
      );
      painter36.paint(canvas, const Size(400, 300));

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    testWidgets(
      'paints smoothly without throwing for single scenario and dual scenarios',
      (tester) async {
        final nodesA = createMockNodes(
          count: 12,
          startBalance: 100000,
          netFlow: 10000,
        );
        final nodesB = createMockNodes(
          count: 12,
          startBalance: 100000,
          netFlow: -15000,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  height: 300,
                  child: CustomPaint(
                    painter: TrajectoryPainter(
                      projectionsByScenarioId: {
                        'scenario_a': nodesA,
                        'scenario_b': nodesB,
                      },
                      scenarioColours: {
                        'scenario_a': PulseColors.primary,
                        'scenario_b': PulseColors.secondary,
                      },
                      windowMonths: 12,
                      initialBalance: 100000,
                      isDark: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final customPaintFinder = find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is TrajectoryPainter,
        );
        expect(customPaintFinder, findsOneWidget);
      },
    );
  });
}
