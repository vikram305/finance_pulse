/// Pulse input validation patterns.
class AppPatterns {
  AppPatterns._();

  /// Accepts positive numbers (integer or decimal) for financial amounts.
  /// e.g. "50000", "4500.50"
  static final RegExp positiveAmount = RegExp(r'^\d+(\.\d{1,2})?$');

  /// Accepts a valid scenario name: 1–64 printable characters.
  static final RegExp scenarioName = RegExp(r'^.{1,64}$');

  /// Accepts a valid event block name: 1–64 printable characters.
  static final RegExp eventName = RegExp(r'^.{1,64}$');

  /// PIN: 4–8 digits.
  static final RegExp pin = RegExp(r'^\d{4,8}$');
}
