import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/pulse_colors.dart';
import '../../../../core/presentation/theme/pulse_text_styles.dart';
import '../../../../domain/entities/projection_node.dart';

/// Formatter for compact Indian currency strings (e.g. ₹1.2L, ₹80K, ₹0).
abstract final class PulseCurrencyFormatter {
  /// Formats [amount] as a compact Indian currency string.
  static String format(double amount) {
    if (amount.isNaN || amount.isInfinite) return '₹0';
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    String formatted;

    if (absAmount >= 10000000) {
      final cr = absAmount / 10000000;
      formatted = '${_trimZero(cr.toStringAsFixed(1))}Cr';
    } else if (absAmount >= 100000) {
      final lakh = absAmount / 100000;
      formatted = '${_trimZero(lakh.toStringAsFixed(1))}L';
    } else if (absAmount >= 1000) {
      final k = absAmount / 1000;
      formatted = '${_trimZero(k.toStringAsFixed(1))}K';
    } else {
      formatted = absAmount.toStringAsFixed(0);
    }

    return isNegative ? '-₹$formatted' : '₹$formatted';
  }

  static String _trimZero(String value) {
    if (value.endsWith('.0')) {
      return value.substring(0, value.length - 2);
    }
    return value;
  }
}

/// Custom painter rendering smooth cubic Bézier projection trajectories
/// on a bare-metal Flutter canvas.
///
/// Features:
/// - Smooth cubic Bézier paths computed from [ProjectionNode.endingBalance].
/// - Colour-coded trajectory strokes (Deep Indigo for A, Amber for B).
/// - 10-15% opacity gradient area fills.
/// - Below-₹0 distress portions clipped and rendered in Rose.
/// - Muted dotted survival floor reference line at ₹0.
/// - Auto-scaled Y-axis with compact currency labels in JetBrains Mono 12px.
/// - Evenly spaced X-axis month index labels in JetBrains Mono 12px.
/// - In-canvas floating legend rendered in the top-right corner when > 1 scenario is active.
class TrajectoryPainter extends CustomPainter {
  /// Map of monthly projection nodes per active scenario ID.
  final Map<String, List<ProjectionNode>> projectionsByScenarioId;

  /// Assigned colours per scenario ID.
  final Map<String, Color> scenarioColours;

  /// Optional display names per scenario ID for the floating legend.
  final Map<String, String>? scenarioNames;

  /// Projection duration horizon in months (12, 24, or 36).
  final int windowMonths;

  /// Baseline liquid balance at month 0.
  final double initialBalance;

  /// Whether current theme is dark.
  final bool isDark;

  /// Optional color for horizontal grid lines (e.g. [ColorScheme.outlineVariant]).
  final Color? gridLineColor;

  const TrajectoryPainter({
    required this.projectionsByScenarioId,
    required this.scenarioColours,
    this.scenarioNames,
    required this.windowMonths,
    required this.initialBalance,
    required this.isDark,
    this.gridLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activeEntries = projectionsByScenarioId.entries
        .where((e) => e.value.isNotEmpty)
        .toList(growable: false);

    if (activeEntries.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    // 1. Calculate balance bounds across all active scenarios within window
    var minBalance = initialBalance;
    var maxBalance = initialBalance;

    for (final entry in activeEntries) {
      for (final node in entry.value) {
        if (node.monthIndex < windowMonths) {
          if (node.endingBalance < minBalance) minBalance = node.endingBalance;
          if (node.endingBalance > maxBalance) maxBalance = node.endingBalance;
        }
      }
    }

    // Ensure survival floor ₹0 is within range
    if (minBalance > 0.0) {
      minBalance = 0.0;
    }

    final double effectiveMin = minBalance < 0 ? minBalance * 1.15 : 0.0;
    final double span = math.max(maxBalance - effectiveMin, 10000.0);
    final double topMargin = span * 0.15;
    final double effectiveMax = maxBalance + topMargin;

    // 2. Chart geometry and layout boundaries
    const double padLeft = 52.0;
    const double padRight = 16.0;
    const double padTop = 30.0;
    const double padBottom = 28.0;

    final double chartLeft = padLeft;
    final double chartRight = math.max(padLeft + 10.0, size.width - padRight);
    final double chartTop = padTop;
    final double chartBottom = math.max(padTop + 10.0, size.height - padBottom);
    final double chartWidth = chartRight - chartLeft;
    final double chartHeight = chartBottom - chartTop;

    double xForMonth(double month) =>
        chartLeft + (month / windowMonths) * chartWidth;

    double yForBalance(double balance) {
      final double normalized =
          (balance - effectiveMin) / (effectiveMax - effectiveMin);
      return chartBottom - normalized * chartHeight;
    }

    final double zeroY = yForBalance(0.0);

    // 3. Draw horizontal grid lines and Y-axis balance labels
    _drawYAxis(
      canvas: canvas,
      chartLeft: chartLeft,
      chartRight: chartRight,
      effectiveMin: effectiveMin,
      effectiveMax: effectiveMax,
      yForBalance: yForBalance,
    );

    // 4. Draw Survival Floor (₹0 dotted line)
    if (zeroY >= chartTop && zeroY <= chartBottom) {
      final zeroLinePaint = Paint()
        ..color = isDark
            ? PulseColors.darkOnSurfaceVariant.withValues(alpha: 0.35)
            : PulseColors.lightOnSurfaceVariant.withValues(alpha: 0.35)
        ..strokeWidth = 1.0;
      _drawDashedLine(
        canvas,
        Offset(chartLeft, zeroY),
        Offset(chartRight, zeroY),
        zeroLinePaint,
      );
    }

    // 5. Draw X-axis month labels
    _drawXAxis(
      canvas: canvas,
      chartLeft: chartLeft,
      chartRight: chartRight,
      chartBottom: chartBottom,
      xForMonth: xForMonth,
    );

    // 6. Draw Bézier curves and gradients for each active scenario
    for (var sIdx = 0; sIdx < activeEntries.length; sIdx++) {
      final entry = activeEntries[sIdx];
      final scenarioId = entry.key;
      final nodes = entry.value
          .where((n) => n.monthIndex < windowMonths)
          .toList(growable: false);

      if (nodes.isEmpty) continue;

      final scenarioColor = scenarioColours[scenarioId] ??
          (sIdx == 0 ? PulseColors.primary : PulseColors.secondary);

      final points = <Offset>[
        Offset(xForMonth(0.0), yForBalance(initialBalance)),
      ];

      for (var i = 0; i < nodes.length; i++) {
        points.add(
          Offset(xForMonth((i + 1).toDouble()), yForBalance(nodes[i].endingBalance)),
        );
      }

      final curvePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 0; i < points.length - 1; i++) {
        final curr = points[i];
        final next = points[i + 1];
        final cpX = (curr.dx + next.dx) / 2.0;
        curvePath.cubicTo(cpX, curr.dy, cpX, next.dy, next.dx, next.dy);
      }

      final areaPath = Path.from(curvePath)
        ..lineTo(points.last.dx, zeroY.clamp(chartTop, chartBottom))
        ..lineTo(points.first.dx, zeroY.clamp(chartTop, chartBottom))
        ..close();

      // Region A: Positive balance (above or at ₹0 line)
      canvas.save();
      canvas.clipRect(
        Rect.fromLTRB(chartLeft - 4, chartTop - 4, chartRight + 4, zeroY),
      );

      final fillShader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          scenarioColor.withValues(alpha: 0.15),
          scenarioColor.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromLTRB(chartLeft, chartTop, chartRight, zeroY),
      );

      canvas.drawPath(
        areaPath,
        Paint()
          ..shader = fillShader
          ..style = PaintingStyle.fill,
      );

      final strokePaint = Paint()
        ..color = scenarioColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(curvePath, strokePaint);
      canvas.restore();

      // Region B: Negative balance (below ₹0 line) — signal distress in Rose
      if (effectiveMin < 0.0 && zeroY < chartBottom) {
        canvas.save();
        canvas.clipRect(
          Rect.fromLTRB(chartLeft - 4, zeroY, chartRight + 4, chartBottom + 4),
        );

        final distressFillShader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PulseColors.rose.withValues(alpha: 0.0),
            PulseColors.rose.withValues(alpha: 0.15),
          ],
        ).createShader(
          Rect.fromLTRB(chartLeft, zeroY, chartRight, chartBottom),
        );

        canvas.drawPath(
          areaPath,
          Paint()
            ..shader = distressFillShader
            ..style = PaintingStyle.fill,
        );

        final distressStrokePaint = Paint()
          ..color = PulseColors.rose
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(curvePath, distressStrokePaint);
        canvas.restore();
      }
    }

    // 7. Floating In-Canvas Legend Overlay (only when > 1 scenario is active)
    if (activeEntries.length > 1) {
      _drawLegendOverlay(
        canvas: canvas,
        chartRight: chartRight,
        activeEntries: activeEntries,
      );
    }
  }

  void _drawYAxis({
    required Canvas canvas,
    required double chartLeft,
    required double chartRight,
    required double effectiveMin,
    required double effectiveMax,
    required double Function(double) yForBalance,
  }) {
    final textColor = isDark
        ? PulseColors.darkOnSurfaceVariant
        : PulseColors.lightOnSurfaceVariant;
    final effectiveGridLineColor = gridLineColor ??
        (isDark
            ? PulseColors.darkOutline.withValues(alpha: 0.25)
            : PulseColors.lightOutline.withValues(alpha: 0.4));

    final gridPaint = Paint()
      ..color = effectiveGridLineColor
      ..strokeWidth = 1.0;

    const int tickCount = 4;
    for (var i = 0; i <= tickCount; i++) {
      final double balance =
          effectiveMin + (effectiveMax - effectiveMin) * (i / tickCount);
      final double y = yForBalance(balance);

      _drawDashedLine(
        canvas,
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
        dashWidth: 3.0,
        dashSpace: 3.0,
      );

      final label = PulseCurrencyFormatter.format(balance);
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: PulseTextStyles.dataSmall.copyWith(
            color: textColor,
            fontSize: 12.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(chartLeft - textPainter.width - 6.0, y - textPainter.height / 2.0),
      );
    }
  }

  void _drawXAxis({
    required Canvas canvas,
    required double chartLeft,
    required double chartRight,
    required double chartBottom,
    required double Function(double) xForMonth,
  }) {
    final textColor = isDark
        ? PulseColors.darkOnSurfaceVariant
        : PulseColors.lightOnSurfaceVariant;

    final int step = windowMonths <= 12 ? 1 : (windowMonths <= 24 ? 3 : 6);

    for (var m = step; m <= windowMonths; m += step) {
      final double x = xForMonth(m.toDouble());
      final label = 'M$m';

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: PulseTextStyles.dataSmall.copyWith(
            color: textColor,
            fontSize: 12.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2.0, chartBottom + 6.0),
      );
    }
  }

  void _drawLegendOverlay({
    required Canvas canvas,
    required double chartRight,
    required List<MapEntry<String, List<ProjectionNode>>> activeEntries,
  }) {
    final items = <_LegendItem>[];
    for (var i = 0; i < activeEntries.length; i++) {
      final id = activeEntries[i].key;
      final name = scenarioNames?[id] ??
          (id.toLowerCase().contains('b') ? 'Scenario B' : 'Scenario A');
      final color = scenarioColours[id] ??
          (i == 0 ? PulseColors.primary : PulseColors.secondary);

      final textPainter = TextPainter(
        text: TextSpan(
          text: name,
          style: PulseTextStyles.labelSmall.copyWith(
            color:
                isDark ? PulseColors.darkOnSurface : PulseColors.lightOnSurface,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      items.add(_LegendItem(color: color, painter: textPainter));
    }

    const double swatchWidth = 14.0;
    const double swatchHeight = 4.0;
    const double swatchGap = 6.0;
    const double itemSpacing = 12.0;
    const double padH = 10.0;
    const double padV = 6.0;

    double contentWidth = 0.0;
    for (var i = 0; i < items.length; i++) {
      contentWidth += swatchWidth + swatchGap + items[i].painter.width;
      if (i < items.length - 1) contentWidth += itemSpacing;
    }

    final double totalWidth = contentWidth + padH * 2.0;
    final double totalHeight = 16.0 + padV * 2.0;
    final double left = chartRight - totalWidth;
    const double top = 6.0;

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, totalWidth, totalHeight),
      const Radius.circular(6.0),
    );

    // Background surface fill
    final bgPaint = Paint()
      ..color = (isDark ? PulseColors.darkSurface : PulseColors.lightSurface)
          .withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cardRect, bgPaint);

    // Border stroke
    final borderPaint = Paint()
      ..color = isDark ? PulseColors.darkOutline : PulseColors.lightOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(cardRect, borderPaint);

    // Render legend swatches and labels
    double currentX = left + padH;
    for (final item in items) {
      final swatchRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          currentX,
          top + (totalHeight - swatchHeight) / 2.0,
          swatchWidth,
          swatchHeight,
        ),
        const Radius.circular(2.0),
      );
      canvas.drawRRect(swatchRect, Paint()..color = item.color);

      currentX += swatchWidth + swatchGap;
      item.painter.paint(
        canvas,
        Offset(currentX, top + (totalHeight - item.painter.height) / 2.0),
      );
      currentX += item.painter.width + itemSpacing;
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashWidth = 4.0,
    double dashSpace = 4.0,
  }) {
    double currentX = p1.dx;
    while (currentX < p2.dx) {
      final nextX = math.min(currentX + dashWidth, p2.dx);
      canvas.drawLine(Offset(currentX, p1.dy), Offset(nextX, p1.dy), paint);
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant TrajectoryPainter oldDelegate) {
    if (oldDelegate.windowMonths != windowMonths ||
        oldDelegate.initialBalance != initialBalance ||
        oldDelegate.isDark != isDark ||
        oldDelegate.gridLineColor != gridLineColor ||
        !mapEquals(oldDelegate.scenarioColours, scenarioColours) ||
        !mapEquals(oldDelegate.scenarioNames, scenarioNames)) {
      return true;
    }

    return !_areProjectionsEqual(
      oldDelegate.projectionsByScenarioId,
      projectionsByScenarioId,
    );
  }

  bool _areProjectionsEqual(
    Map<String, List<ProjectionNode>> a,
    Map<String, List<ProjectionNode>> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final listA = a[key]!;
      final listB = b[key]!;
      if (listA.length != listB.length) return false;
      for (var i = 0; i < listA.length; i++) {
        if (listA[i] != listB[i]) return false;
      }
    }
    return true;
  }
}

class _LegendItem {
  final Color color;
  final TextPainter painter;

  _LegendItem({required this.color, required this.painter});
}

