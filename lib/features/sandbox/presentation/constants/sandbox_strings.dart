/// Strings specific to the Sandbox feature.
class SandboxStrings {
  SandboxStrings._();

  /// Default strawman expense names.
  static const String rent = 'Rent';
  static const String livingCosts = 'Living Costs';
  static const String emi = 'EMI';

  /// Default initial scenario name.
  static const String defaultScenarioName = 'Scenario A';

  /// Generates a duplicated scenario name with the standard copy suffix.
  static String scenarioCopy(String name) => '$name (Copy)';
}
