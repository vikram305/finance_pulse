import 'package:flutter/material.dart';

import '../theme/pulse_spacing.dart';
import '../theme/pulse_text_styles.dart';

/// Minimalist empty state widget complying with ADR-DS-001.
///
/// Style guidelines:
/// - Minimal line-art (single-colour stroke, no fills) — analytical, precision feel.
/// - Used for zero-data states in Scenarios and Timeline Event blocks.
class PulseEmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final Widget? illustration;
  final Widget? action;

  const PulseEmptyState({
    super.key,
    required this.message,
    this.title,
    this.illustration,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final strokeColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    final titleColor = colorScheme.onSurface;
    final messageColor = colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PulseSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            illustration ??
                CustomPaint(
                  key: const Key('pulse_default_empty_illustration'),
                  size: const Size(72.0, 72.0),
                  painter: _PulseLineArtPainter(color: strokeColor),
                ),
            if (title != null) ...[
              const SizedBox(height: PulseSpacing.lg),
              Text(
                title!,
                style: (textTheme.titleLarge ?? PulseTextStyles.display).copyWith(
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: PulseSpacing.sm),
            Text(
              message,
              style: (textTheme.bodyMedium ?? PulseTextStyles.bodyMedium).copyWith(
                color: messageColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: PulseSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Precision minimal line-art painter with single-color stroke and no solid fills.
class _PulseLineArtPainter extends CustomPainter {
  final Color color;

  const _PulseLineArtPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Outer subtle analytical frame (open bracket style)
    final framePath = Path()
      ..moveTo(w * 0.1, h * 0.3)
      ..lineTo(w * 0.1, h * 0.9)
      ..lineTo(w * 0.9, h * 0.9);
    canvas.drawPath(framePath, paint);

    // Baseline grid tick marks
    canvas.drawLine(Offset(w * 0.1, h * 0.6), Offset(w * 0.15, h * 0.6), paint);
    canvas.drawLine(Offset(w * 0.5, h * 0.9), Offset(w * 0.5, h * 0.85), paint);

    // Pulse trajectory line
    final pulsePath = Path()
      ..moveTo(w * 0.18, h * 0.72)
      ..lineTo(w * 0.38, h * 0.72)
      ..lineTo(w * 0.52, h * 0.40)
      ..lineTo(w * 0.66, h * 0.55)
      ..lineTo(w * 0.85, h * 0.28);
    canvas.drawPath(pulsePath, paint);

    // Terminal node indicator (unfilled circle)
    canvas.drawCircle(Offset(w * 0.85, h * 0.28), 3.0, paint);
  }

  @override
  bool shouldRepaint(covariant _PulseLineArtPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

