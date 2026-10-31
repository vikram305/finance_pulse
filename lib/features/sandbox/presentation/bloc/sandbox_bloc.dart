import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../domain/engine/projection_engine.dart';
import '../../../../domain/entities/financial_event.dart';
import '../../../../domain/entities/projection_node.dart';
import '../../../../domain/entities/scenario.dart';
import '../constants/sandbox_strings.dart';
import 'sandbox_event.dart';
import 'sandbox_state.dart';

/// Central state machine for the Sandbox feature.
///
/// Owns the active scenarios, event collections, and projection recalculations.
class SandboxBloc extends Bloc<SandboxEvent, SandboxState> {
  final ProjectionEngine? _engine;
  final Uuid _uuid;

  /// Creates a [SandboxBloc] instance with optional injectable dependencies.
  ///
  /// An optional [projectionEngine] can be provided for custom calculation logic
  /// or testing. When omitted, [ProjectionEngine.withEvents] is instantiated on demand.
  /// An optional [uuid] generator can be injected for deterministic ID generation in tests.
  SandboxBloc({
    ProjectionEngine? projectionEngine,
    Uuid? uuid,
  })  : _engine = projectionEngine,
        _uuid = uuid ?? const Uuid(),
        super(const SandboxState.initial()) {
    on<SandboxInitialized>(_onSandboxInitialized);
    on<FinancialEventAdded>(_onFinancialEventAdded);
    on<FinancialEventUpdated>(_onFinancialEventUpdated);
    on<FinancialEventDeleted>(_onFinancialEventDeleted);
    on<FinancialEventStartMonthChanged>(_onFinancialEventStartMonthChanged);
    on<ScenarioForked>(_onScenarioForked);
    on<ScenarioRenamed>(_onScenarioRenamed);
    on<ScenarioDuplicated>(_onScenarioDuplicated);
    on<ScenarioDeleted>(_onScenarioDeleted);
    on<ProjectionWindowChanged>(_onProjectionWindowChanged);
  }

  void _onSandboxInitialized(
    SandboxInitialized event,
    Emitter<SandboxState> emit,
  ) {
    final scenarioId = _uuid.v4();

    final rentEvent = FinancialEvent(
      id: _uuid.v4(),
      name: SandboxStrings.rent,
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: AppConstants.maxProjectionMonths - 1,
      amount: event.monthlyNetIncome * AppConstants.strawmanNeedsPercent,
      isBaseline: false,
    );

    final livingCostsEvent = FinancialEvent(
      id: _uuid.v4(),
      name: SandboxStrings.livingCosts,
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: AppConstants.maxProjectionMonths - 1,
      amount: event.monthlyNetIncome * AppConstants.strawmanWantsPercent,
      isBaseline: false,
    );

    final emiEvent = FinancialEvent(
      id: _uuid.v4(),
      name: SandboxStrings.emi,
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: AppConstants.maxProjectionMonths - 1,
      amount: event.monthlyNetIncome * AppConstants.strawmanSavingsPercent,
      isBaseline: false,
    );

    final events = [rentEvent, livingCostsEvent, emiEvent];
    final scenario = Scenario(
      id: scenarioId,
      name: SandboxStrings.defaultScenarioName,
      eventIds: events.map((e) => e.id).toList(growable: false),
    );

    final scenarios = {scenarioId: scenario};
    final eventsByScenarioId = {scenarioId: events};
    final projectionWindowMonths = state.projectionWindowMonths == 0
        ? AppConstants.defaultProjectionMonths
        : state.projectionWindowMonths;

    final projections = _calculateProjections(
      scenarios: scenarios,
      eventsByScenarioId: eventsByScenarioId,
      liquidBalance: event.liquidBalance,
      windowMonths: projectionWindowMonths,
    );

    emit(
      SandboxState(
        scenarios: scenarios,
        eventsByScenarioId: eventsByScenarioId,
        projectionsByScenarioId: projections,
        projectionWindowMonths: projectionWindowMonths,
        liquidBalance: event.liquidBalance,
        monthlyNetIncome: event.monthlyNetIncome,
      ),
    );
  }

  void _onFinancialEventAdded(
    FinancialEventAdded event,
    Emitter<SandboxState> emit,
  ) {
    final scenario = state.scenarios[event.scenarioId];
    if (scenario == null) return;

    final currentEvents = state.eventsByScenarioId[event.scenarioId] ?? [];
    final updatedEvents = [...currentEvents, event.event];

    final updatedScenario = scenario.copyWith(
      eventIds: [...scenario.eventIds, event.event.id],
    );

    final updatedScenarios = Map<String, Scenario>.from(state.scenarios);
    updatedScenarios[event.scenarioId] = updatedScenario;

    final updatedEventsByScenarioId =
        Map<String, List<FinancialEvent>>.from(state.eventsByScenarioId);
    updatedEventsByScenarioId[event.scenarioId] = updatedEvents;

    final projections = _calculateProjections(
      scenarios: updatedScenarios,
      eventsByScenarioId: updatedEventsByScenarioId,
      liquidBalance: state.liquidBalance,
      windowMonths: state.projectionWindowMonths,
    );

    emit(
      state.copyWith(
        scenarios: updatedScenarios,
        eventsByScenarioId: updatedEventsByScenarioId,
        projectionsByScenarioId: projections,
      ),
    );
  }

  void _onFinancialEventUpdated(
    FinancialEventUpdated event,
    Emitter<SandboxState> emit,
  ) {
    final scenario = state.scenarios[event.scenarioId];
    if (scenario == null) return;

    final currentEvents = state.eventsByScenarioId[event.scenarioId] ?? [];
    final eventIndex = currentEvents.indexWhere((e) => e.id == event.event.id);
    if (eventIndex == -1) return;

    final updatedEvents = List<FinancialEvent>.from(currentEvents);
    updatedEvents[eventIndex] = event.event;

    final updatedEventsByScenarioId =
        Map<String, List<FinancialEvent>>.from(state.eventsByScenarioId);
    updatedEventsByScenarioId[event.scenarioId] = updatedEvents;

    final projections = _calculateProjections(
      scenarios: state.scenarios,
      eventsByScenarioId: updatedEventsByScenarioId,
      liquidBalance: state.liquidBalance,
      windowMonths: state.projectionWindowMonths,
    );

    emit(
      state.copyWith(
        eventsByScenarioId: updatedEventsByScenarioId,
        projectionsByScenarioId: projections,
      ),
    );
  }

  void _onFinancialEventDeleted(
    FinancialEventDeleted event,
    Emitter<SandboxState> emit,
  ) {
    final scenario = state.scenarios[event.scenarioId];
    if (scenario == null) return;

    final currentEvents = state.eventsByScenarioId[event.scenarioId] ?? [];
    final updatedEvents =
        currentEvents.where((e) => e.id != event.eventId).toList();

    final updatedScenario = scenario.copyWith(
      eventIds: scenario.eventIds.where((id) => id != event.eventId).toList(),
    );

    final updatedScenarios = Map<String, Scenario>.from(state.scenarios);
    updatedScenarios[event.scenarioId] = updatedScenario;

    final updatedEventsByScenarioId =
        Map<String, List<FinancialEvent>>.from(state.eventsByScenarioId);
    updatedEventsByScenarioId[event.scenarioId] = updatedEvents;

    final projections = _calculateProjections(
      scenarios: updatedScenarios,
      eventsByScenarioId: updatedEventsByScenarioId,
      liquidBalance: state.liquidBalance,
      windowMonths: state.projectionWindowMonths,
    );

    emit(
      state.copyWith(
        scenarios: updatedScenarios,
        eventsByScenarioId: updatedEventsByScenarioId,
        projectionsByScenarioId: projections,
      ),
    );
  }

  void _onFinancialEventStartMonthChanged(
    FinancialEventStartMonthChanged event,
    Emitter<SandboxState> emit,
  ) {
    final currentEvents = state.eventsByScenarioId[event.scenarioId] ?? [];
    final eventIndex = currentEvents.indexWhere((e) => e.id == event.eventId);
    if (eventIndex == -1) return;

    final targetEvent = currentEvents[eventIndex];
    final updatedEvent = targetEvent.copyWith(startMonth: event.newStartMonth);

    final updatedEvents = List<FinancialEvent>.from(currentEvents);
    updatedEvents[eventIndex] = updatedEvent;

    final updatedEventsByScenarioId =
        Map<String, List<FinancialEvent>>.from(state.eventsByScenarioId);
    updatedEventsByScenarioId[event.scenarioId] = updatedEvents;

    final projections = _calculateProjections(
      scenarios: state.scenarios,
      eventsByScenarioId: updatedEventsByScenarioId,
      liquidBalance: state.liquidBalance,
      windowMonths: state.projectionWindowMonths,
    );

    emit(
      state.copyWith(
        eventsByScenarioId: updatedEventsByScenarioId,
        projectionsByScenarioId: projections,
      ),
    );
  }

  void _onScenarioForked(
    ScenarioForked event,
    Emitter<SandboxState> emit,
  ) {
    if (state.scenarios.length >= AppConstants.maxActiveScenarios) return;
    if (state.scenarios.isEmpty) return;

    final sourceScenario = state.scenarios.values.first;
    final newScenarioId = _uuid.v4();

    final sourceEvents = state.eventsByScenarioId[sourceScenario.id] ?? [];
    final clonedEvents = <FinancialEvent>[];
    final clonedEventIds = <String>[];

    for (final ev in sourceEvents) {
      final newEventId = _uuid.v4();
      clonedEvents.add(ev.copyWith(id: newEventId));
      clonedEventIds.add(newEventId);
    }

    final newScenario = Scenario(
      id: newScenarioId,
      name: event.newScenarioName,
      eventIds: clonedEventIds,
    );

    final updatedScenarios = Map<String, Scenario>.from(state.scenarios);
    updatedScenarios[newScenarioId] = newScenario;

    final updatedEventsByScenarioId =
        Map<String, List<FinancialEvent>>.from(state.eventsByScenarioId);
    updatedEventsByScenarioId[newScenarioId] = clonedEvents;

    final projections = _calculateProjections(
      scenarios: updatedScenarios,
      eventsByScenarioId: updatedEventsByScenarioId,
      liquidBalance: state.liquidBalance,
      windowMonths: state.projectionWindowMonths,
    );

    emit(
      state.copyWith(
        scenarios: updatedScenarios,
        eventsByScenarioId: updatedEventsByScenarioId,
        projectionsByScenarioId: projections,
      ),
    );
  }

  void _onScenarioRenamed(
    ScenarioRenamed event,
    Emitter<SandboxState> emit,
  ) {
    final targetScenario = state.scenarios[event.scenarioId];
    if (targetScenario == null || targetScenario.name == event.newName) return;

    final updatedScenario = targetScenario.copyWith(name: event.newName);
    final updatedScenarios = Map<String, Scenario>.from(state.scenarios);
    updatedScenarios[event.scenarioId] = updatedScenario;

    emit(
      state.copyWith(
        scenarios: updatedScenarios,
      ),
    );
  }

  void _onScenarioDuplicated(
    ScenarioDuplicated event,
    Emitter<SandboxState> emit,
  ) {
    if (state.scenarios.length >= AppConstants.maxActiveScenarios) return;

    final sourceScenario = state.scenarios[event.scenarioId];
    if (sourceScenario == null) return;

    final newScenarioId = _uuid.v4();
    final sourceEvents = state.eventsByScenarioId[sourceScenario.id] ?? [];
    final clonedEvents = <FinancialEvent>[];
    final clonedEventIds = <String>[];

    for (final ev in sourceEvents) {
      final newEventId = _uuid.v4();
      clonedEvents.add(ev.copyWith(id: newEventId));
      clonedEventIds.add(newEventId);
    }

    final newScenario = Scenario(
      id: newScenarioId,
      name: SandboxStrings.scenarioCopy(sourceScenario.name),
      eventIds: clonedEventIds,
    );

    final updatedScenarios = Map<String, Scenario>.from(state.scenarios);
    updatedScenarios[newScenarioId] = newScenario;

    final updatedEventsByScenarioId =
        Map<String, List<FinancialEvent>>.from(state.eventsByScenarioId);
    updatedEventsByScenarioId[newScenarioId] = clonedEvents;

    final projections = _calculateProjections(
      scenarios: updatedScenarios,
      eventsByScenarioId: updatedEventsByScenarioId,
      liquidBalance: state.liquidBalance,
      windowMonths: state.projectionWindowMonths,
    );

    emit(
      state.copyWith(
        scenarios: updatedScenarios,
        eventsByScenarioId: updatedEventsByScenarioId,
        projectionsByScenarioId: projections,
      ),
    );
  }

  void _onScenarioDeleted(
    ScenarioDeleted event,
    Emitter<SandboxState> emit,
  ) {
    if (state.scenarios.length <= AppConstants.minActiveScenarios) return;
    if (!state.scenarios.containsKey(event.scenarioId)) return;

    final updatedScenarios = Map<String, Scenario>.from(state.scenarios)
      ..remove(event.scenarioId);
    final updatedEventsByScenarioId =
        Map<String, List<FinancialEvent>>.from(state.eventsByScenarioId)
          ..remove(event.scenarioId);
    final updatedProjections =
        Map<String, List<ProjectionNode>>.from(state.projectionsByScenarioId)
          ..remove(event.scenarioId);

    emit(
      state.copyWith(
        scenarios: updatedScenarios,
        eventsByScenarioId: updatedEventsByScenarioId,
        projectionsByScenarioId: updatedProjections,
      ),
    );
  }

  void _onProjectionWindowChanged(
    ProjectionWindowChanged event,
    Emitter<SandboxState> emit,
  ) {
    if (!AppConstants.allowedProjectionWindows.contains(event.months)) return;

    final projections = _calculateProjections(
      scenarios: state.scenarios,
      eventsByScenarioId: state.eventsByScenarioId,
      liquidBalance: state.liquidBalance,
      windowMonths: event.months,
    );

    emit(
      state.copyWith(
        projectionWindowMonths: event.months,
        projectionsByScenarioId: projections,
      ),
    );
  }

  Map<String, List<ProjectionNode>> _calculateProjections({
    required Map<String, Scenario> scenarios,
    required Map<String, List<FinancialEvent>> eventsByScenarioId,
    required double liquidBalance,
    required int windowMonths,
  }) {
    final result = <String, List<ProjectionNode>>{};
    for (final scenario in scenarios.values) {
      final scenarioEvents = eventsByScenarioId[scenario.id] ?? const [];
      final engine = _engine ?? const ProjectionEngine();
      result[scenario.id] = engine.calculate(
        scenario,
        const [],
        windowMonths: windowMonths,
        initialBalance: liquidBalance,
        events: scenarioEvents,
      );
    }
    return result;
  }
}
