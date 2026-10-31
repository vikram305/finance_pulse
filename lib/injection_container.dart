import 'package:get_it/get_it.dart';

import 'domain/usecases/calculate_resilience_score.dart';
import 'features/sandbox/presentation/bloc/sandbox_bloc.dart';

final locator = GetIt.instance;
final sl = locator;

/// Registers all app-level dependencies.
///
/// TODO(next-session): Wire Pulse features in this order:
///   1. DatabaseService / Drift database (encrypted on mobile, plain on web)
///   2. FinancialEventRepository
///   3. ScenarioRepository
///   4. ProjectionEngine (pure function — no DI needed, call directly)
///   5. SandboxBloc (app-level, provided at MaterialApp root)
///   6. PanicRoomBloc (mobile-only)
Future<void> init() async {
  // — Helpers & Core —
  // (add DateHelper, etc. when first feature needs them)

  // — Domain UseCases —
  if (!locator.isRegistered<CalculateResilienceScore>()) {
    locator.registerLazySingleton<CalculateResilienceScore>(
      () => const CalculateResilienceScore(),
    );
  }

  // — Feature: Sandbox —
  if (!locator.isRegistered<SandboxBloc>()) {
    locator.registerFactory<SandboxBloc>(() => SandboxBloc());
  }

  // — Feature: Panic Room —
  // locator.registerFactory(() => PanicRoomBloc(locator()));
}
