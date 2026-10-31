import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pulse_colors.dart';
import 'pulse_spacing.dart';

/// Pulse design system theme provider.
///
/// Implements ADR-DS-001 precision instrument theme:
/// - Dark mode is the primary surface (near-black, desaturated indigo, amber secondary).
/// - Light mode adjusts Indigo lightness to guarantee WCAG AA >= 4.5:1 contrast against white.
/// - Base typography uses Inter; numerical typography uses JetBrains Mono.
/// - Material 3 enabled.
abstract final class PulseTheme {
  /// Builds the dark [ThemeData] for Pulse.
  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: PulseColors.primary,
      onPrimary: Colors.white,
      primaryContainer: PulseColors.primary.withValues(alpha: 0.2),
      onPrimaryContainer: Colors.white,
      secondary: PulseColors.secondary,
      onSecondary: Colors.black,
      secondaryContainer: PulseColors.secondary.withValues(alpha: 0.2),
      onSecondaryContainer: Colors.white,
      error: PulseColors.error,
      onError: Colors.white,
      surface: PulseColors.darkSurface,
      onSurface: PulseColors.darkOnSurface,
      surfaceContainerHighest: PulseColors.darkSurfaceContainer,
      onSurfaceVariant: PulseColors.darkOnSurfaceVariant,
      outline: PulseColors.darkOutline,
    );

    final baseTextTheme = ThemeData.dark().textTheme;
    final interTextTheme = GoogleFonts.interTextTheme(baseTextTheme).apply(
      bodyColor: PulseColors.darkOnSurface,
      displayColor: PulseColors.darkOnSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PulseColors.darkBackground,
      canvasColor: PulseColors.darkBackground,
      cardColor: PulseColors.darkSurface,
      textTheme: interTextTheme,
      dividerColor: PulseColors.darkOutline,
      appBarTheme: AppBarTheme(
        backgroundColor: PulseColors.darkBackground,
        foregroundColor: PulseColors.darkOnSurface,
        elevation: 0,
        centerTitle: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      cardTheme: CardThemeData(
        color: PulseColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PulseSpacing.md),
          side: const BorderSide(color: PulseColors.darkOutline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PulseColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PulseSpacing.sm),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: PulseSpacing.base,
            vertical: PulseSpacing.md,
          ),
        ),
      ),
      extensions: const [
        PulseThemeExtension.dark(),
      ],
    );
  }

  /// Builds the light [ThemeData] for Pulse.
  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: PulseColors.lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: PulseColors.lightPrimary.withValues(alpha: 0.12),
      onPrimaryContainer: PulseColors.lightPrimary,
      secondary: PulseColors.secondary,
      onSecondary: Colors.black,
      secondaryContainer: PulseColors.secondary.withValues(alpha: 0.15),
      onSecondaryContainer: Colors.black,
      error: PulseColors.error,
      onError: Colors.white,
      surface: PulseColors.lightSurface,
      onSurface: PulseColors.lightOnSurface,
      surfaceContainerHighest: PulseColors.lightSurfaceContainer,
      onSurfaceVariant: PulseColors.lightOnSurfaceVariant,
      outline: PulseColors.lightOutline,
    );

    final baseTextTheme = ThemeData.light().textTheme;
    final interTextTheme = GoogleFonts.interTextTheme(baseTextTheme).apply(
      bodyColor: PulseColors.lightOnSurface,
      displayColor: PulseColors.lightOnSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PulseColors.lightBackground,
      canvasColor: PulseColors.lightBackground,
      cardColor: PulseColors.lightSurface,
      textTheme: interTextTheme,
      dividerColor: PulseColors.lightOutline,
      appBarTheme: const AppBarTheme(
        backgroundColor: PulseColors.lightBackground,
        foregroundColor: PulseColors.lightOnSurface,
        elevation: 0,
        centerTitle: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      cardTheme: CardThemeData(
        color: PulseColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PulseSpacing.md),
          side: const BorderSide(color: PulseColors.lightOutline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PulseColors.lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PulseSpacing.sm),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: PulseSpacing.base,
            vertical: PulseSpacing.md,
          ),
        ),
      ),
      extensions: const [
        PulseThemeExtension.light(),
      ],
    );
  }
}

/// ThemeExtension providing custom semantic & polarity colors for Pulse.
@immutable
class PulseThemeExtension extends ThemeExtension<PulseThemeExtension> {
  final Color primary;
  final Color secondary;
  final Color income;
  final Color expense;
  final Color error;
  final Color warning;
  final Color success;
  final Color info;

  const PulseThemeExtension({
    required this.primary,
    required this.secondary,
    required this.income,
    required this.expense,
    required this.error,
    required this.warning,
    required this.success,
    required this.info,
  });

  const PulseThemeExtension.dark()
      : primary = const Color(0xFF6756B8), // HSL(255, 45%, 55%)
        secondary = const Color(0xFFE99D20), // HSL(38, 80%, 52%)
        income = const Color(0xFF34B29E), // HSL(174, 55%, 45%)
        expense = const Color(0xFFD1485E), // HSL(350, 60%, 55%)
        error = const Color(0xFFDE4B62), // HSL(350, 65%, 58%)
        warning = const Color(0xFFF3B416), // HSL(45, 90%, 52%)
        success = const Color(0xFF30A669), // HSL(155, 55%, 42%)
        info = const Color(0xFF299DE1); // HSL(200, 75%, 52%)

  const PulseThemeExtension.light()
      : primary = const Color(0xFF4C3399), // HSL(255, 50%, 40%)
        secondary = const Color(0xFFE99D20),
        income = const Color(0xFF238E7E),
        expense = const Color(0xFFC4334C),
        error = const Color(0xFFD1324B),
        warning = const Color(0xFFD89B00),
        success = const Color(0xFF258754),
        info = const Color(0xFF197EB9);

  @override
  ThemeExtension<PulseThemeExtension> copyWith({
    Color? primary,
    Color? secondary,
    Color? income,
    Color? expense,
    Color? error,
    Color? warning,
    Color? success,
    Color? info,
  }) {
    return PulseThemeExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<PulseThemeExtension> lerp(
    covariant ThemeExtension<PulseThemeExtension>? other,
    double t,
  ) {
    if (other is! PulseThemeExtension) {
      return this;
    }
    return PulseThemeExtension(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      income: Color.lerp(income, other.income, t) ?? income,
      expense: Color.lerp(expense, other.expense, t) ?? expense,
      error: Color.lerp(error, other.error, t) ?? error,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      success: Color.lerp(success, other.success, t) ?? success,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}

