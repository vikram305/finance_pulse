import 'package:flutter/animation.dart';

/// Pulse motion constants specified in ADR-DS-001.
///
/// Motion philosophy: Surgical + one signature moment.
/// Fast, functional, invisible. No decorative motion.
abstract final class PulseMotion {
  /// Default state transition duration (300ms).
  static const Duration defaultDuration = Duration(milliseconds: 300);

  /// Default transition easing curve (Curves.easeOut).
  static const Curve defaultCurve = Curves.easeOut;

  /// Duration for tap press feedback (120ms).
  static const Duration tapScaleDuration = Duration(milliseconds: 120);

  /// Target scale value on tap down (0.97).
  static const double tapScaleValue = 0.97;
}

