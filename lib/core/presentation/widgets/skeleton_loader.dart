import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';
import '../theme/pulse_spacing.dart';

/// A shimmer skeleton loader widget showing placeholder bars for the Strawman Scenario.
///
/// Features:
/// - Three placeholder bars corresponding to Strawman events (Rent, Living Costs, EMI).
/// - Dynamic light-to-dark gradient sweep shimmer animation representing active calculation.
/// - Configurable bar count, height, and spacing.
/// - Full accessibility semantics support.
class SkeletonLoader extends StatefulWidget {
  final int barCount;
  final double barHeight;
  final double spacing;
  final String semanticsLabel;
  final bool loop;

  const SkeletonLoader({
    super.key,
    this.barCount = 3,
    this.barHeight = 48.0,
    this.spacing = PulseSpacing.md,
    this.semanticsLabel = AppStrings.skeletonLoaderSemantics,
    this.loop = false,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.shimmerDuration,
    );
    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = colorScheme.surfaceContainerHighest;
    final highlightColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
        : colorScheme.surface;
    final outlineColor = colorScheme.outline;

    return Semantics(
      container: true,
      label: widget.semanticsLabel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final gradient = LinearGradient(
            begin: Alignment(-2.0 + 4.0 * progress, -0.2),
            end: Alignment(-1.0 + 4.0 * progress, 0.2),
            colors: [baseColor, highlightColor, baseColor],
            stops: const [0.0, 0.5, 1.0],
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(widget.barCount, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < widget.barCount - 1 ? widget.spacing : 0.0,
                ),
                child: Container(
                  key: ValueKey('skeleton_bar_$index'),
                  height: widget.barHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(PulseSpacing.sm),
                    gradient: gradient,
                    border: Border.all(
                      color: outlineColor,
                      width: 1.0,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
