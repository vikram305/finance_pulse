import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pulse design system color tokens derived from ADR-DS-001.
///
/// Palette is inspired by Linear, Raycast, and Robinhood — precision instrument
/// aesthetic with desaturated primary indigo and distinct trajectory accents.
abstract final class PulseColors {
  // --- Primary Palette ---
  /// Deep Indigo `HSL(255, 45%, 55%)` — primary CTA, active states, Scenario A trajectory.
  static final Color primary = HSLColor.fromAHSL(1.0, 255.0, 0.45, 0.55).toColor();

  /// Amber `HSL(38, 80%, 52%)` — secondary accent, Scenario B trajectory.
  static final Color secondary = HSLColor.fromAHSL(1.0, 38.0, 0.80, 0.52).toColor();

  // --- Financial Polarity Colors ---
  /// Teal `HSL(174, 55%, 45%)` — income events (positive direction).
  static final Color income = HSLColor.fromAHSL(1.0, 174.0, 0.55, 0.45).toColor();
  static Color get teal => income;

  /// Rose `HSL(350, 60%, 55%)` — expense events (negative direction).
  static final Color expense = HSLColor.fromAHSL(1.0, 350.0, 0.60, 0.55).toColor();
  static Color get rose => expense;

  // --- Semantic Tokens ---
  /// Error Rose `HSL(350, 65%, 58%)`.
  static final Color error = HSLColor.fromAHSL(1.0, 350.0, 0.65, 0.58).toColor();

  /// Warning Gold `HSL(45, 90%, 52%)`.
  static final Color warning = HSLColor.fromAHSL(1.0, 45.0, 0.90, 0.52).toColor();

  /// Success Emerald `HSL(155, 55%, 42%)`.
  static final Color success = HSLColor.fromAHSL(1.0, 155.0, 0.55, 0.42).toColor();

  /// Info Sky `HSL(200, 75%, 52%)`.
  static final Color info = HSLColor.fromAHSL(1.0, 200.0, 0.75, 0.52).toColor();

  // --- Dark Theme Surfaces ---
  /// Near-black background (lightness <= 10%).
  static final Color darkBackground = HSLColor.fromAHSL(1.0, 240.0, 0.12, 0.06).toColor();

  /// Dark surface cards and panels (lightness 8–12%).
  static final Color darkSurface = HSLColor.fromAHSL(1.0, 240.0, 0.10, 0.10).toColor();

  /// Slightly elevated dark surface container.
  static final Color darkSurfaceContainer = HSLColor.fromAHSL(1.0, 240.0, 0.08, 0.14).toColor();

  /// Dark theme outline / border.
  static const Color darkOutline = Color(0xFF2E303A);

  /// High-emphasis foreground on dark surfaces.
  static const Color darkOnSurface = Color(0xFFF0F1F5);

  /// Medium-emphasis foreground on dark surfaces.
  static const Color darkOnSurfaceVariant = Color(0xFFA0A3B1);

  // --- Light Theme Surfaces ---
  /// Light theme primary with adjusted lightness (darker) to maintain WCAG AA >= 4.5:1 against white.
  static final Color lightPrimary = HSLColor.fromAHSL(1.0, 255.0, 0.50, 0.40).toColor();

  /// Light theme background.
  static const Color lightBackground = Color(0xFFF8F9FA);

  /// Light theme surface.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light theme surface container / card.
  static const Color lightSurfaceContainer = Color(0xFFF0F2F5);

  /// Light theme outline / border.
  static const Color lightOutline = Color(0xFFD0D3DC);

  /// High-emphasis foreground on light surfaces.
  static const Color lightOnSurface = Color(0xFF111216);

  /// Medium-emphasis foreground on light surfaces.
  static const Color lightOnSurfaceVariant = Color(0xFF555866);

  // --- WCAG AA Helpers ---
  /// Computes relative luminance according to WCAG 2.1 specifications.
  static double relativeLuminance(Color color) {
    double channel(double c) {
      return c <= 0.03928
          ? c / 12.92
          : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = channel(color.r);
    final g = channel(color.g);
    final b = channel(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Computes WCAG 2.1 contrast ratio between two colors (ranging from 1.0 to 21.0).
  static double contrastRatio(Color foreground, Color background) {
    final l1 = relativeLuminance(foreground);
    final l2 = relativeLuminance(background);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }
}

