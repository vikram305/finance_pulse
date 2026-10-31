import 'package:equatable/equatable.dart';

import '../../../../domain/entities/financial_event.dart';
import '../../../../domain/entities/financial_shock.dart';
import '../../../../domain/entities/scenario.dart';

/// Base class for all events dispatched to [PanicRoomBloc].
abstract class PanicRoomEvent extends Equatable {
  const PanicRoomEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched upon navigating into the Panic Room stress-test view.
///
/// Ingests baseline sandbox scenarios, active events, balances, and income to
/// compute baseline resilience metrics before any shock chips are applied.
class PanicRoomEntered extends PanicRoomEvent {
  /// The collection of scenarios active in the Sandbox session.
  final Map<String, Scenario> scenarios;

  /// The financial events mapped by scenario ID.
  final Map<String, List<FinancialEvent>> eventsByScenarioId;

  /// Liquid balance at month 0.
  final double liquidBalance;

  /// Monthly net income used to scale income-related shocks such as Job Loss.
  final double monthlyNetIncome;

  /// Projection duration window in months (12, 24, or 36).
  final int projectionWindowMonths;

  /// Creates a [PanicRoomEntered] event.
  const PanicRoomEntered({
    required this.scenarios,
    required this.eventsByScenarioId,
    required this.liquidBalance,
    required this.monthlyNetIncome,
    required this.projectionWindowMonths,
  });

  @override
  List<Object?> get props => [
    scenarios,
    eventsByScenarioId,
    liquidBalance,
    monthlyNetIncome,
    projectionWindowMonths,
  ];
}

/// Dispatched when the user toggles a stress shock chip ON or OFF.
class ShockToggled extends PanicRoomEvent {
  /// The shock being toggled.
  final FinancialShock shock;

  /// Creates a [ShockToggled] event.
  const ShockToggled({required this.shock});

  @override
  List<Object?> get props => [shock];
}

/// Dispatched when leaving the Panic Room to clear active shocks and reset state.
class PanicRoomExited extends PanicRoomEvent {
  /// Creates a [PanicRoomExited] event.
  const PanicRoomExited();
}
