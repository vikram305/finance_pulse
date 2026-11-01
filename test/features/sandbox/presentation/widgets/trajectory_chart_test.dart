import 'package:finance_pulse/core/presentation/theme/pulse_theme.dart';
import 'package:finance_pulse/core/presentation/widgets/pulse_empty_state.dart';
import 'package:finance_pulse/domain/entities/projection_node.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_bloc.dart';
import 'package:finance_pulse/features/sandbox/presentation/widgets/projection_window_segmented_control.dart';
import 'package:finance_pulse/features/sandbox/presentation/widgets/trajectory_chart.dart';
import 'package:finance_pulse/features/sandbox/presentation/widgets/trajectory_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  late SandboxBloc sandboxBloc;

  setUp(() {
    sandboxBloc = SandboxBloc();
  });

  tearDown(() {
    sandboxBloc.close();
  });

  Widget buildSubject({
    Map<String, List<ProjectionNode>>? projectionsByScenarioId,
    int windowMonths = 12,
    double initialBalance = 100000,
    void Function(int)? onWindowChanged,
    SandboxBloc? bloc,
  }) {
    return BlocProvider<SandboxBloc>.value(
      value: bloc ?? sandboxBloc,
      child: MaterialApp(
        theme: PulseTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 350,
              child: TrajectoryChart(
                projectionsByScenarioId: projectionsByScenarioId,
                windowMonths: windowMonths,
                initialBalance: initialBalance,
                onWindowChanged: onWindowChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('TrajectoryChart', () {
    testWidgets(
      'renders PulseEmptyState when projectionsByScenarioId is null or empty',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(projectionsByScenarioId: const {}),
        );

        expect(find.byType(PulseEmptyState), findsOneWidget);
        expect(
          find.text('Add your first event to see your trajectory.'),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is TrajectoryPainter,
          ),
          findsNothing,
        );
        expect(find.byType(ProjectionWindowSegmentedControl), findsNothing);
      },
    );

    testWidgets('renders PulseEmptyState when scenario lists are all empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(projectionsByScenarioId: {'scenario_a': []}),
      );

      expect(find.byType(PulseEmptyState), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is TrajectoryPainter,
        ),
        findsNothing,
      );
    });

    testWidgets(
      'renders TrajectoryPainter wrapped in RepaintBoundary when projections are present',
      (tester) async {
        final nodes = createMockNodes(
          count: 12,
          startBalance: 100000,
          netFlow: 15000,
        );
        await tester.pumpWidget(
          buildSubject(projectionsByScenarioId: {'scenario_a': nodes}),
        );

        expect(find.byType(PulseEmptyState), findsNothing);
        expect(find.byType(RepaintBoundary), findsWidgets);
        expect(find.byType(ProjectionWindowSegmentedControl), findsOneWidget);

        final customPaintFinder = find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is TrajectoryPainter,
        );
        expect(customPaintFinder, findsOneWidget);
      },
    );

    testWidgets(
      'segmented control default is 12M and tapping 24M updates window and dispatches ProjectionWindowChanged',
      (tester) async {
        final nodes = createMockNodes(
          count: 24,
          startBalance: 100000,
          netFlow: 15000,
        );
        int? reportedWindow;

        await tester.pumpWidget(
          buildSubject(
            projectionsByScenarioId: {'scenario_a': nodes},
            windowMonths: 12,
            onWindowChanged: (w) => reportedWindow = w,
          ),
        );

        expect(find.text('12M'), findsOneWidget);
        expect(find.text('24M'), findsOneWidget);

        await tester.tap(find.text('24M'));
        await tester.pump();

        expect(reportedWindow, equals(24));
      },
    );

    testWidgets('animates to new window with AnimatedSwitcher', (tester) async {
      final nodes = createMockNodes(
        count: 36,
        startBalance: 100000,
        netFlow: 15000,
      );
      await tester.pumpWidget(
        buildSubject(
          projectionsByScenarioId: {'scenario_a': nodes},
          windowMonths: 12,
        ),
      );

      expect(find.byType(AnimatedSwitcher), findsOneWidget);

      await tester.tap(find.text('36M'));
      await tester.pump();
      // Mid-animation check (150ms of 300ms)
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(AnimatedSwitcher), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('provides descriptive Semantics label for screen readers', (
      tester,
    ) async {
      final nodes = createMockNodes(
        count: 12,
        startBalance: 100000,
        netFlow: 15000,
      );
      await tester.pumpWidget(
        buildSubject(projectionsByScenarioId: {'scenario_a': nodes}),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          'Financial trajectory projection chart showing 1 scenario over a 12-month horizon',
        ),
        findsOneWidget,
      );
    });

    testWidgets('meets accessibility guidelines', (tester) async {
      final nodes = createMockNodes(
        count: 12,
        startBalance: 100000,
        netFlow: 15000,
      );
      await tester.pumpWidget(
        buildSubject(projectionsByScenarioId: {'scenario_a': nodes}),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
