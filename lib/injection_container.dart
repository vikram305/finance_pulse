import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

/// Registers all app-level dependencies.
///
/// TODO(next-session): Wire Pulse features in this order:
///   1. Isar database (encrypted on mobile, plain on web)
///   2. FinancialEventRepository
///   3. ScenarioRepository
///   4. ProjectionEngine (pure function — no DI needed, call directly)
///   5. SandboxBloc (app-level, provided at MaterialApp root)
///   6. PanicRoomBloc (mobile-only)
Future<void> init() async {
  // — Helpers & Core —
  // (add DateHelper, etc. when first feature needs them)

  // — Feature: Sandbox —
  // locator.registerFactory(() => SandboxBloc(locator()));

  // — Feature: Panic Room —
  // locator.registerFactory(() => PanicRoomBloc(locator()));
}
