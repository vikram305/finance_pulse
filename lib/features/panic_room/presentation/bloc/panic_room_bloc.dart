import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/constants/financial_shocks.dart';
import '../../../../domain/engine/projection_engine.dart';
import '../../../../domain/entities/financial_event.dart';
import '../../../../domain/entities/financial_shock.dart';
import '../../../../domain/entities/projection_node.dart';
import '../../../../domain/entities/resilience_score.dart';
import '../../../../domain/entities/scenario.dart';
import '../../../../domain/usecases/calculate_resilience_score.dart';
import 'panic_room_event.dart';
import 'panic_room_state.dart';

/// Central state machine for the Panic Room stress-test feature (Mobile Only).
///
/// Owns the stress-test state: toggled shock chips, active shocks, and per-scenario
/// resilience scores and survival runway months calculated after each toggle.
/// Shocks are never applied to scenario stored events — they are flattened into
/// [ProjectionEngine] inputs at calculation time only.
class PanicRoomBloc extends Bloc<PanicRoomEvent, PanicRoomState> {
  final CalculateResilienceScore _calculateResilienceScore;
  final ProjectionEngine? _engine;

  /// Creates a [PanicRoomBloc] instance with optional injectable dependencies.
  ///
  /// Injects [CalculateResilienceScore] for computing scenario resilience scores,
  /// and an optional [projectionEngine] for custom calculation logic or testing.
  PanicRoomBloc({
    CalculateResilienceScore? calculateResilienceScore,
    ProjectionEngine? projectionEngine,
  }) : _calculateResilienceScore =
           calculateResilienceScore ?? const CalculateResilienceScore(),
       _engine = projectionEngine,
       super(PanicRoomState.initial()) {
    on<PanicRoomEntered>(_onPanicRoomEntered);
    on<ShockToggled>(_onShockToggled);
    on<PanicRoomExited>(_onPanicRoomExited);
  }

  /// Constructs the V1 catalogue of available shocks.
  ///
  /// The [FinancialShocks.jobLoss] shock is dynamically built using [monthlyNetIncome],
  /// while the other three shocks use the static final constants directly.
  List<FinancialShock> _buildAvailableShocks(double monthlyNetIncome) {
    return [
      FinancialShocks.medicalEmergency,
      FinancialShocks.rentSpike,
      FinancialShocks.emiShock,
      FinancialShocks.jobLoss(monthlyNetIncome: monthlyNetIncome),
    ];
  }

  Future<void> _onPanicRoomEntered(
    PanicRoomEntered event,
    Emitter<PanicRoomState> emit,
  ) async {
    final availableShocks = _buildAvailableShocks(event.monthlyNetIncome);
    const activeShockIds = <String>{};
    const activeShocks = <FinancialShock>[];

    final (projections, scores, survivalMonths) = await _calculateMetrics(
      scenarios: event.scenarios,
      eventsByScenarioId: event.eventsByScenarioId,
      liquidBalance: event.liquidBalance,
      windowMonths: event.projectionWindowMonths,
      activeShocks: activeShocks,
    );

    emit(
      PanicRoomState(
        activeShockIds: activeShockIds,
        availableShocks: availableShocks,
        projectionsByScenarioId: projections,
        scoresByScenarioId: scores,
        survivalMonthsByScenarioId: survivalMonths,
        scenarios: event.scenarios,
        eventsByScenarioId: event.eventsByScenarioId,
        liquidBalance: event.liquidBalance,
        monthlyNetIncome: event.monthlyNetIncome,
        projectionWindowMonths: event.projectionWindowMonths,
      ),
    );
  }

  Future<void> _onShockToggled(
    ShockToggled event,
    Emitter<PanicRoomState> emit,
  ) async {
    final updatedActiveShockIds = Set<String>.from(state.activeShockIds);
    if (updatedActiveShockIds.contains(event.shock.id)) {
      updatedActiveShockIds.remove(event.shock.id);
    } else {
      updatedActiveShockIds.add(event.shock.id);
    }

    final availableShocks = _buildAvailableShocks(state.monthlyNetIncome);
    final activeShocks = availableShocks
        .where((s) => updatedActiveShockIds.contains(s.id))
        .toList(growable: false);

    final (projections, scores, survivalMonths) = await _calculateMetrics(
      scenarios: state.scenarios,
      eventsByScenarioId: state.eventsByScenarioId,
      liquidBalance: state.liquidBalance,
      windowMonths: state.projectionWindowMonths,
      activeShocks: activeShocks,
    );

    emit(
      state.copyWith(
        activeShockIds: updatedActiveShockIds,
        availableShocks: availableShocks,
        projectionsByScenarioId: projections,
        scoresByScenarioId: scores,
        survivalMonthsByScenarioId: survivalMonths,
      ),
    );
  }

  void _onPanicRoomExited(PanicRoomExited event, Emitter<PanicRoomState> emit) {
    emit(PanicRoomState.initial());
  }

  Future<
    (
      Map<String, List<ProjectionNode>>,
      Map<String, ResilienceScore>,
      Map<String, double>,
    )
  >
  _calculateMetrics({
    required Map<String, Scenario> scenarios,
    required Map<String, List<FinancialEvent>> eventsByScenarioId,
    required double liquidBalance,
    required int windowMonths,
    required List<FinancialShock> activeShocks,
  }) async {
    final projections = <String, List<ProjectionNode>>{};
    final scores = <String, ResilienceScore>{};
    final survivalMonths = <String, double>{};

    for (final scenario in scenarios.values) {
      final scenarioEvents = eventsByScenarioId[scenario.id] ?? const [];
      final engine = _engine ?? const ProjectionEngine();

      final nodes = engine.calculate(
        scenario,
        activeShocks,
        windowMonths: windowMonths,
        initialBalance: liquidBalance,
        events: scenarioEvents,
      );
      projections[scenario.id] = nodes;

      final scoreResult = await _calculateResilienceScore(
        CalculateResilienceScoreParams(scenarioId: scenario.id, nodes: nodes),
      );

      scores[scenario.id] = scoreResult.fold(
        (_) => ResilienceScore(scenarioId: scenario.id, score: 0.0),
        (score) => score,
      );

      final firstZeroOrNegative = nodes.indexWhere((n) => n.endingBalance <= 0);
      survivalMonths[scenario.id] = firstZeroOrNegative == -1
          ? windowMonths.toDouble()
          : firstZeroOrNegative.toDouble();
    }

    return (projections, scores, survivalMonths);
  }
}
