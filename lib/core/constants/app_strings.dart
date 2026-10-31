/// Pulse application strings.
class AppStrings {
  AppStrings._();

  static const String appTitle = 'Pulse';
  static const String appTagline = 'The Financial Sandbox';

  // Onboarding
  static const String onboardingTitle = 'The 10-Second Hook';
  static const String onboardingSubtitle =
      'Enter two numbers to see your 12-month financial trajectory in seconds.';
  static const String onboardingBalanceLabel = 'Current Liquid Balance';
  static const String onboardingIncomeLabel = 'Monthly Net Income';
  static const String onboardingCurrencyPrefix = '₹';
  static const String onboardingBalanceSemantics =
      'Current liquid balance input';
  static const String onboardingIncomeSemantics = 'Monthly net income input';
  static const String onboardingSubmitButton = 'See Projections';
  static const String onboardingSubmitSemantics = 'See Projections';
  static const String onboardingBalanceRequired =
      'Please enter your liquid balance';
  static const String onboardingBalancePositive =
      'Balance must be greater than 0';
  static const String onboardingIncomeRequired =
      'Please enter your monthly net income';
  static const String onboardingIncomePositive =
      'Income must be greater than 0';
  static const String strawmanNotice =
      'The Strawman blocks below are auto-generated estimates. '
      'The accuracy of your Projected Resilience Score depends on how much you correct them.';
  static const String dismissStrawmanNotice = 'Dismiss Strawman notice';
  static const String dismissStrawmanNoticeSemantics = dismissStrawmanNotice;

  // Web volatile storage banner (TDD §4.1)
  static const String webVolatileBanner =
      'Browser storage is volatile. Clear your cache and your sandbox is gone. '
      'Export your scenario or download the app to keep your data.';
  static const String dismissVolatileBanner =
      'Dismiss volatile storage banner';
  static const String dismissVolatileBannerSemantics = dismissVolatileBanner;

  // Skeleton loader
  static const String skeletonLoaderSemantics = 'Generating strawman scenario';

  // Panic Room
  static const String projectedResilienceLabel = 'Projected Resilience';

  // PIN dialogs
  static const String pinSetupExportNudge =
      'Export a backup now. If you ever forget this PIN or get a new device, '
      'your .pulse file is the only way to recover your data.';
  static const String pinWebExportCopy =
      'Choose a PIN you\'ll remember — you\'ll need it to import on mobile. '
      'There is no recovery if you forget it.';
  static const String pinForgottenWarning =
      'There is no server-side recovery. '
      'If you forget your PIN you will need to wipe and reinstall the app.';

  // Scenario actions
  static const String forkScenario = 'Fork Scenario';
  static const String scenarioCapReached =
      'Maximum of 2 scenarios reached. Delete one to fork again.';

  // Shocks
  static const String shockJobLoss = 'Job Loss';
  static const String shockMedicalEmergency = 'Medical Emergency';
  static const String shockRentSpike = 'Rent Spike';
  static const String shockEmiShock = 'EMI Shock';

  //Error messages
  static const String somethingWentWrong =
      "Something went wrong please try again after sometime.";
}
