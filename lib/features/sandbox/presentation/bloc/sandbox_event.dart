import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/financial_event.dart';

/// Base class for all events processed by the [SandboxBloc].
abstract class SandboxEvent extends Equatable {
  /// Const constructor for subclasses.
  const SandboxEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes the Sandbox with liquid balance and monthly net income,
/// auto-generating the initial Strawman Scenario.
class SandboxInitialized extends SandboxEvent {
  final double liquidBalance;
  final double monthlyNetIncome;

  const SandboxInitialized({
    required this.liquidBalance,
    required this.monthlyNetIncome,
  });

  @override
  List<Object?> get props => [liquidBalance, monthlyNetIncome];
}

/// Adds a new financial event to a scenario.
class FinancialEventAdded extends SandboxEvent {
  final String scenarioId;
  final FinancialEvent event;

  const FinancialEventAdded({
    required this.scenarioId,
    required this.event,
  });

  @override
  List<Object?> get props => [scenarioId, event];
}

/// Replaces an existing event having the same ID within a scenario.
class FinancialEventUpdated extends SandboxEvent {
  final String scenarioId;
  final FinancialEvent event;

  const FinancialEventUpdated({
    required this.scenarioId,
    required this.event,
  });

  @override
  List<Object?> get props => [scenarioId, event];
}

/// Deletes an event by ID from a scenario.
class FinancialEventDeleted extends SandboxEvent {
  final String scenarioId;
  final String eventId;

  const FinancialEventDeleted({
    required this.scenarioId,
    required this.eventId,
  });

  @override
  List<Object?> get props => [scenarioId, eventId];
}

/// Updates only the startMonth of a financial event on timeline drag deltas.
class FinancialEventStartMonthChanged extends SandboxEvent {
  final String scenarioId;
  final String eventId;
  final int newStartMonth;

  const FinancialEventStartMonthChanged({
    required this.scenarioId,
    required this.eventId,
    required this.newStartMonth,
  });

  @override
  List<Object?> get props => [scenarioId, eventId, newStartMonth];
}

/// Forks the currently active scenario into a new scenario with the given name.
///
/// **Invariant**: Silently rejected (no-op) if the active scenario count has already
/// reached [AppConstants.maxActiveScenarios] or if there are no existing scenarios to fork.
class ScenarioForked extends SandboxEvent {
  final String newScenarioName;

  const ScenarioForked({
    required this.newScenarioName,
  });

  @override
  List<Object?> get props => [newScenarioName];
}

/// Renames a scenario.
///
/// **Invariant**: Silently rejected (no-op) if [scenarioId] does not exist in
/// active scenarios or if [newName] matches the current scenario name.
class ScenarioRenamed extends SandboxEvent {
  final String scenarioId;
  final String newName;

  const ScenarioRenamed({
    required this.scenarioId,
    required this.newName,
  });

  @override
  List<Object?> get props => [scenarioId, newName];
}

/// Duplicates a scenario with a deep copy of all its events.
///
/// **Invariant**: Silently rejected (no-op) if the active scenario count has already
/// reached [AppConstants.maxActiveScenarios] or if the source [scenarioId] is not found.
class ScenarioDuplicated extends SandboxEvent {
  final String scenarioId;

  const ScenarioDuplicated({
    required this.scenarioId,
  });

  @override
  List<Object?> get props => [scenarioId];
}

/// Deletes a scenario.
///
/// **Invariant**: Silently rejected (no-op) if the active scenario count is at or below
/// [AppConstants.minActiveScenarios] (at least one scenario must remain) or if
/// [scenarioId] does not exist.
class ScenarioDeleted extends SandboxEvent {
  final String scenarioId;

  const ScenarioDeleted({
    required this.scenarioId,
  });

  @override
  List<Object?> get props => [scenarioId];
}

/// Changes the active projection window (valid values: 12, 24, 36).
class ProjectionWindowChanged extends SandboxEvent {
  final int months;

  const ProjectionWindowChanged({
    required this.months,
  });

  @override
  List<Object?> get props => [months];
}

