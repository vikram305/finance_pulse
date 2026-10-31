import 'package:flutter/painting.dart';

/// Pulse spacing scale based on 4px base increment (ADR-DS-001).
///
/// Scale: 4, 8, 12, 16, 24, 32, 48, 64 logical pixels.
abstract final class PulseSpacing {
  /// 4px
  static const double xs = 4.0;

  /// 8px
  static const double sm = 8.0;

  /// 12px - dense inner padding (e.g. event blocks, scenario chips)
  static const double md = 12.0;

  /// 16px - standard base spacing
  static const double base = 16.0;

  /// 24px - large layout separation
  static const double lg = 24.0;

  /// 32px - extra large spacing
  static const double xl = 32.0;

  /// 48px - double extra large
  static const double xxl = 48.0;

  /// 64px - hero section spacing
  static const double xxxl = 64.0;

  // --- EdgeInsets Helpers ---
  static const EdgeInsets insetsXs = EdgeInsets.all(xs);
  static const EdgeInsets insetsSm = EdgeInsets.all(sm);
  static const EdgeInsets insetsMd = EdgeInsets.all(md);
  static const EdgeInsets insetsBase = EdgeInsets.all(base);
  static const EdgeInsets insetsLg = EdgeInsets.all(lg);
  static const EdgeInsets insetsXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalBase = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalBase = EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

