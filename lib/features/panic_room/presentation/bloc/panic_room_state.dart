import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../domain/constants/financial_shocks.dart';
import '../../../../domain/entities/financial_event.dart';
import '../../../../domain/entities/financial_shock.dart';
import '../../../../domain/entities/projection_node.dart';
import '../../../../domain/entities/resilience_score.dart';
import '../../../../domain/entities/scenario.dart';

/// Central state representation for the Panic Room stress-test feature.
class PanicRoomState extends Equatable {
  /// IDs of currently toggled-on shocks.
  final Set<String> activeShockIds;

  /// Full V1 catalogue of available shocks (always 4 shocks populated).
  final List<FinancialShock> availableShocks;

  /// Recalculated projections per scenario with active shocks applied.
  final Map<String, List<ProjectionNode>> projectionsByScenarioId;

  /// Per-scenario resilience scores (0-100).
  final Map<String, ResilienceScore> scoresByScenarioId;

  /// Months until liquid balance drops to <= 0 per scenario.
  final Map<String, double> survivalMonthsByScenarioId;

  /// Active sandbox scenarios being stress tested.
  final Map<String, Scenario> scenarios;

  /// Scenario financial events keyed by scenario ID.
  final Map<String, List<FinancialEvent>> eventsByScenarioId;

  /// Starting liquid balance at month 0.
  final double liquidBalance;

  /// User's monthly net income, used to dynamically construct the Job Loss shock.
  final double monthlyNetIncome;

  /// Projection duration window in months (12, 24, or 36).
  final int projectionWindowMonths;

  /// Creates a [PanicRoomState] instance.
  const PanicRoomState({
    this.activeShockIds = const {},
    this.availableShocks = const [],
    this.projectionsByScenarioId = const {},
    this.scoresByScenarioId = const {},
    this.survivalMonthsByScenarioId = const {},
    this.scenarios = const {},
    this.eventsByScenarioId = const {},
    this.liquidBalance = 0.0,
    this.monthlyNetIncome = 0.0,
    this.projectionWindowMonths = AppConstants.defaultProjectionMonths,
  });

  /// Initial state prior to [PanicRoomEntered] or after [PanicRoomExited].
  ///
  /// Populates [availableShocks] with the 4 standard V1 shocks and clears active shocks.
  factory PanicRoomState.initial() {
    return PanicRoomState(
      activeShockIds: const {},
      availableShocks: [
        FinancialShocks.medicalEmergency,
        FinancialShocks.rentSpike,
        FinancialShocks.emiShock,
        FinancialShocks.jobLoss(monthlyNetIncome: 0.0),
      ],
      projectionsByScenarioId: const {},
      scoresByScenarioId: const {},
      survivalMonthsByScenarioId: const {},
      scenarios: const {},
      eventsByScenarioId: const {},
      liquidBalance: 0.0,
      monthlyNetIncome: 0.0,
      projectionWindowMonths: AppConstants.defaultProjectionMonths,
    );
  }

  PanicRoomState copyWith({
    Set<String>? activeShockIds,
    List<FinancialShock>? availableShocks,
    Map<String, List<ProjectionNode>>? projectionsByScenarioId,
    Map<String, ResilienceScore>? scoresByScenarioId,
    Map<String, double>? survivalMonthsByScenarioId,
    Map<String, Scenario>? scenarios,
    Map<String, List<FinancialEvent>>? eventsByScenarioId,
    double? liquidBalance,
    double? monthlyNetIncome,
    int? projectionWindowMonths,
  }) {
    return PanicRoomState(
      activeShockIds: activeShockIds ?? this.activeShockIds,
      availableShocks: availableShocks ?? this.availableShocks,
      projectionsByScenarioId:
          projectionsByScenarioId ?? this.projectionsByScenarioId,
      scoresByScenarioId: scoresByScenarioId ?? this.scoresByScenarioId,
      survivalMonthsByScenarioId:
          survivalMonthsByScenarioId ?? this.survivalMonthsByScenarioId,
      scenarios: scenarios ?? this.scenarios,
      eventsByScenarioId: eventsByScenarioId ?? this.eventsByScenarioId,
      liquidBalance: liquidBalance ?? this.liquidBalance,
      monthlyNetIncome: monthlyNetIncome ?? this.monthlyNetIncome,
      projectionWindowMonths:
          projectionWindowMonths ?? this.projectionWindowMonths,
    );
  }

  @override
  List<Object?> get props => [
    activeShockIds,
    availableShocks,
    projectionsByScenarioId,
    scoresByScenarioId,
    survivalMonthsByScenarioId,
    scenarios,
    eventsByScenarioId,
    liquidBalance,
    monthlyNetIncome,
    projectionWindowMonths,
  ];
}
