import 'dart:ui';

import 'package:flutter/material.dart';

/// Overlay widget applying a 3–5% noise grain texture on dark surfaces
/// to prevent OLED banding and create a matte precision-instrument feel (ADR-DS-001).
class PulseNoiseOverlay extends StatelessWidget {
  final Widget child;

  /// Grain opacity value. Defaults to 0.04 (4%), strictly within the 3–5% range.
  final double opacity;

  /// Custom noise grain tint. Defaults to white for dark surfaces.
  final Color? noiseColor;

  const PulseNoiseOverlay({
    super.key,
    required this.child,
    this.opacity = 0.04,
    this.noiseColor,
  }) : assert(opacity >= 0.0 && opacity <= 1.0, 'Opacity must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: PulseNoisePainter(
        opacity: opacity,
        noiseColor: noiseColor ?? Colors.white,
      ),
      child: child,
    );
  }
}

/// CustomPainter generating a fast, deterministic procedural noise grain.
class PulseNoisePainter extends CustomPainter {
  final double opacity;
  final Color noiseColor;

  const PulseNoisePainter({
    required this.opacity,
    required this.noiseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || opacity <= 0) return;

    final paint = Paint()
      ..color = noiseColor.withValues(alpha: opacity)
      ..strokeWidth = 1.0;

    // Draw deterministic sparse stipple points with step 4px
    final points = <Offset>[];
    const step = 4.0;

    int seed = 0x1234567;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        // Fast pseudo-random hash
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        if ((seed & 0xFF) < 40) {
          final offsetX = (seed % 3).toDouble();
          final offsetY = ((seed >> 2) % 3).toDouble();
          points.add(Offset(x + offsetX, y + offsetY));
        }
      }
    }

    if (points.isNotEmpty) {
      canvas.drawPoints(PointMode.points, points, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PulseNoisePainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.noiseColor != noiseColor;
  }
}
