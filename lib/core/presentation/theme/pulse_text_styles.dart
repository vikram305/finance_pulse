import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pulse Typography styles defined in ADR-DS-001.
///
/// Dual font family approach:
/// - **Inter** for UI (headings, body, labels, buttons, copy)
/// - **JetBrains Mono** for all numerical & financial data (scores, values, metrics)
abstract final class PulseTextStyles {
  // --- JetBrains Mono (Numerical & Financial Data) ---
  /// 52px, weight 700 — Used for Projected Resilience score hero number.
  static TextStyle get dataHero => GoogleFonts.jetBrainsMono(
        fontSize: 52.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.1,
      );

  /// 24px, weight 600 — Used for major financial values & currency balance.
  static TextStyle get financialValue => GoogleFonts.jetBrainsMono(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.2,
      );

  /// 15px, weight 600 — Chart axis labels, block amounts inline.
  static TextStyle get dataInline => GoogleFonts.jetBrainsMono(
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
      );

  /// 14px, weight 400 — Used for financial captions & table labels.
  static TextStyle get financialLabel => GoogleFonts.jetBrainsMono(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.4,
      );

  /// 12px, weight 500 — Timestamp values, secondary metrics.
  static TextStyle get dataSmall => GoogleFonts.jetBrainsMono(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // --- Inter (UI Typography) ---
  /// 36px, weight 600 — Section headings, screen titles.
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 36.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        height: 1.2,
      );

  /// 16px, weight 400 — Primary content, readable body text.
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.5,
      );

  /// 14px, weight 400 — Standard body content & descriptions.
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.45,
      );

  /// 12px, weight 400 — Secondary captions and helpers.
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
      );

  /// 14px, weight 500 — Large button & action labels.
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.3,
      );

  /// 13px, weight 500 — Chip labels, toggle text.
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.3,
      );

  /// 12px, weight 500 — Small tags, captions, form sub-labels.
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.3,
      );
}

