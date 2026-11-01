import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/theme/pulse_colors.dart';
import '../../../../core/presentation/theme/pulse_motion.dart';
import '../../../../core/presentation/theme/pulse_spacing.dart';
import '../../../../core/presentation/widgets/pulse_empty_state.dart';
import '../../../../domain/entities/projection_node.dart';
import '../bloc/sandbox_bloc.dart';
import '../bloc/sandbox_event.dart';
import '../constants/sandbox_strings.dart';
import 'projection_window_segmented_control.dart';
import 'trajectory_painter.dart';

/// The signature Trajectory Chart of Pulse.
///
/// Renders a bare-metal cubic Bézier projection curve via [CustomPainter] inside
/// a [RepaintBoundary], bypassing Flutter widget reconciliation entirely to
/// guarantee 60–120 FPS performance.
///
/// Features:
/// - Smooth cubic Bézier trajectories for up to 2 active scenarios.
/// - Segmented control below chart (12M | 24M | 36M) dispatching [ProjectionWindowChanged].
/// - 300ms ease-out window transition animation via [AnimatedSwitcher].
/// - Minimal [PulseEmptyState] when no projections are available.
class TrajectoryChart extends StatefulWidget {
  /// Monthly projection nodes keyed by scenario ID.
  final Map<String, List<ProjectionNode>>? projectionsByScenarioId;

  /// Assigned colours per scenario ID.
  /// Defaults to Deep Indigo for Scenario A and Amber for Scenario B.
  final Map<String, Color>? scenarioColours;

  /// Optional display names per scenario ID for the floating in-canvas legend.
  final Map<String, String>? scenarioNames;

  /// Projection duration horizon in months (12, 24, or 36; default: 12).
  final int windowMonths;

  /// Initial liquid balance at month 0 baseline.
  final double initialBalance;

  /// Optional callback invoked when the projection window is toggled.
  final ValueChanged<int>? onWindowChanged;

  /// Default color mappings for Scenario A and Scenario B.
  static Map<String, Color> get defaultScenarioColours => {
    'scenario_a': PulseColors.primary,
    'scenario_b': PulseColors.secondary,
  };

  const TrajectoryChart({
    super.key,
    required this.projectionsByScenarioId,
    this.scenarioColours,
    this.scenarioNames,
    this.windowMonths = AppConstants.defaultProjectionMonths,
    this.initialBalance = 0.0,
    this.onWindowChanged,
  });

  @override
  State<TrajectoryChart> createState() => _TrajectoryChartState();
}

class _TrajectoryChartState extends State<TrajectoryChart> {
  late int _selectedMonths;

  @override
  void initState() {
    super.initState();
    _selectedMonths = widget.windowMonths;
  }

  @override
  void didUpdateWidget(covariant TrajectoryChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.windowMonths != oldWidget.windowMonths) {
      _selectedMonths = widget.windowMonths;
    }
  }

  void _handleWindowChanged(int months) {
    if (_selectedMonths == months) return;

    setState(() {
      _selectedMonths = months;
    });

    widget.onWindowChanged?.call(months);

    try {
      context.read<SandboxBloc>().add(ProjectionWindowChanged(months: months));
    } catch (_) {
      // Ignored if SandboxBloc is not available in the ancestor tree
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData =
        widget.projectionsByScenarioId != null &&
        widget.projectionsByScenarioId!.isNotEmpty &&
        widget.projectionsByScenarioId!.values.any((nodes) => nodes.isNotEmpty);

    if (!hasData) {
      return const PulseEmptyState(
        message: SandboxStrings.emptyTrajectoryMessage,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColours =
        widget.scenarioColours ?? TrajectoryChart.defaultScenarioColours;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isHeightBounded = constraints.maxHeight.isFinite;

        final chartCanvas = AnimatedSwitcher(
          duration: PulseMotion.defaultDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: RepaintBoundary(
            key: ValueKey<int>(_selectedMonths),
            child: CustomPaint(
              size: Size.infinite,
              painter: TrajectoryPainter(
                projectionsByScenarioId: widget.projectionsByScenarioId!,
                scenarioColours: effectiveColours,
                scenarioNames: widget.scenarioNames,
                windowMonths: _selectedMonths,
                initialBalance: widget.initialBalance,
                isDark: isDark,
              ),
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isHeightBounded)
              Expanded(child: chartCanvas)
            else
              SizedBox(height: 260.0, child: chartCanvas),
            const SizedBox(height: PulseSpacing.sm),
            ProjectionWindowSegmentedControl(
              selectedMonths: _selectedMonths,
              onChanged: _handleWindowChanged,
            ),
          ],
        );
      },
    );
  }
}
