/// Pulse application-wide constants.
class AppConstants {
  AppConstants._();

  // Projection engine
  static const int defaultProjectionMonths = 12;
  static const int minProjectionMonths = 12;
  static const int maxProjectionMonths = 36;

  // Resilience score ceiling (ADR-009)
  static const int resilienceRunwayCeilingMonths = 12;

  // Scenario cap (ADR-008)
  static const int maxActiveScenarios = 2;

  // Onboarding — 50/30/20 Strawman percentages
  static const double strawmanNeedsPercent = 0.50;
  static const double strawmanWantsPercent = 0.30;
  static const double strawmanSavingsPercent = 0.20;

  // Strawman monthly expense estimates (as % of monthly net income)
  // Rent ≈ 30%, Living Costs ≈ 15%, EMI placeholder ≈ 10%
  static const double strawmanRentPercent = 0.30;
  static const double strawmanLivingCostsPercent = 0.15;
  static const double strawmanEmiPercent = 0.10;

  // Web layout (ADR-DS-001)
  static const double webMaxContentWidth = 1200.0;
  static const double webMobileBreakpoint = 768.0;

  // Mobile chart layout
  static const double mobileChartHeightFraction = 0.60;

  // PBKDF2 parameters (ADR-004)
  static const int pbkdf2Iterations = 100000;
}
