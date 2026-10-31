import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'domain/engine/projection_engine.dart';
import 'domain/usecases/calculate_resilience_score.dart';
import 'features/panic_room/presentation/bloc/panic_room_bloc.dart';
import 'features/sandbox/presentation/bloc/sandbox_bloc.dart';

final locator = GetIt.instance;
final sl = locator;

/// Registers all app-level dependencies.
///
/// Pulse features are wired in this sequence:
///   1. DatabaseService / Drift database (encrypted on mobile, plain on web)
///   2. FinancialEventRepository
///   3. ScenarioRepository
///   4. ProjectionEngine (lazy singleton)
///   5. SandboxBloc (app-level factory, takes ProjectionEngine dependency)
///   6. PanicRoomBloc (mobile-only, guarded by `if (!isWeb)`)
Future<void> init({bool isWeb = kIsWeb}) async {
  // — Helpers & Core —
  // (add DateHelper, etc. when first feature needs them)

  // — Domain UseCases & Engines —
  if (!locator.isRegistered<CalculateResilienceScore>()) {
    locator.registerLazySingleton<CalculateResilienceScore>(
      () => const CalculateResilienceScore(),
    );
  }

  if (!locator.isRegistered<ProjectionEngine>()) {
    locator.registerLazySingleton<ProjectionEngine>(
      () => const ProjectionEngine(),
    );
  }

  // — Feature: Sandbox —
  if (!locator.isRegistered<SandboxBloc>()) {
    locator.registerFactory<SandboxBloc>(
      () => SandboxBloc(
        projectionEngine: locator<ProjectionEngine>(),
      ),
    );
  }

  // — Feature: Panic Room (Mobile Only) —
  if (!isWeb) {
    if (!locator.isRegistered<PanicRoomBloc>()) {
      locator.registerFactory<PanicRoomBloc>(
        () => PanicRoomBloc(
          calculateResilienceScore: locator<CalculateResilienceScore>(),
          projectionEngine: locator<ProjectionEngine>(),
        ),
      );
    }
  }
}
