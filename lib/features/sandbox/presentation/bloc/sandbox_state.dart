import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/financial_event.dart';
import '../../../../domain/entities/projection_node.dart';
import '../../../../domain/entities/scenario.dart';

/// Central state representation for the Sandbox feature.
class SandboxState extends Equatable {
  /// Map of active scenarios keyed by [Scenario.id]. Max 2 in V1.
  final Map<String, Scenario> scenarios;

  /// Full financial event entities associated with each scenario, keyed by scenario ID.
  final Map<String, List<FinancialEvent>> eventsByScenarioId;

  /// Recalculated projection trajectories per scenario, keyed by scenario ID.
  final Map<String, List<ProjectionNode>> projectionsByScenarioId;

  /// Active projection duration in months (12, 24, or 36; defaults to 12).
  final int projectionWindowMonths;

  /// User's initial liquid balance passed to [ProjectionEngine].
  final double liquidBalance;

  /// User's monthly net income retained for baseline projections and Panic Room.
  final double monthlyNetIncome;

  /// Creates a [SandboxState] instance with the specified scenario collections,
  /// projection configurations, and initial balances.
  const SandboxState({
    this.scenarios = const {},
    this.eventsByScenarioId = const {},
    this.projectionsByScenarioId = const {},
    this.projectionWindowMonths = AppConstants.defaultProjectionMonths,
    this.liquidBalance = 0.0,
    this.monthlyNetIncome = 0.0,
  });

  /// Creates an uninitialized [SandboxState] with default projection settings and empty collections.
  const SandboxState.initial({
    this.scenarios = const {},
    this.eventsByScenarioId = const {},
    this.projectionsByScenarioId = const {},
    this.projectionWindowMonths = AppConstants.defaultProjectionMonths,
    this.liquidBalance = 0.0,
    this.monthlyNetIncome = 0.0,
  });

  SandboxState copyWith({
    Map<String, Scenario>? scenarios,
    Map<String, List<FinancialEvent>>? eventsByScenarioId,
    Map<String, List<ProjectionNode>>? projectionsByScenarioId,
    int? projectionWindowMonths,
    double? liquidBalance,
    double? monthlyNetIncome,
  }) {
    return SandboxState(
      scenarios: scenarios ?? this.scenarios,
      eventsByScenarioId: eventsByScenarioId ?? this.eventsByScenarioId,
      projectionsByScenarioId:
          projectionsByScenarioId ?? this.projectionsByScenarioId,
      projectionWindowMonths:
          projectionWindowMonths ?? this.projectionWindowMonths,
      liquidBalance: liquidBalance ?? this.liquidBalance,
      monthlyNetIncome: monthlyNetIncome ?? this.monthlyNetIncome,
    );
  }

  @override
  List<Object?> get props => [
        scenarios,
        eventsByScenarioId,
        projectionsByScenarioId,
        projectionWindowMonths,
        liquidBalance,
        monthlyNetIncome,
      ];
}

