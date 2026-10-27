import 'package:equatable/equatable.dart';

import 'financial_event.dart';

/// An app-level stress scenario injected during simulation calculations.
///
/// Financial shocks stress-test scenario resilience by injecting one or more
/// additive crisis events (e.g., job loss, medical emergency). Shocks are
/// transient calculation inputs that never mutate stored scenario entities.
class FinancialShock extends Equatable {
  /// Unique identifier (UUID or catalogue key) for this shock.
  final String id;

  /// User-visible label for the shock (e.g., "Job Loss", "Medical Emergency").
  final String label;

  /// List of financial impact events introduced when this shock is active.
  final List<FinancialEvent> events;

  /// Creates an immutable [FinancialShock] scenario.
  const FinancialShock({
    required this.id,
    required this.label,
    required this.events,
  });

  /// Returns a copy of this [FinancialShock] with the given fields replaced.
  FinancialShock copyWith({
    String? id,
    String? label,
    List<FinancialEvent>? events,
  }) {
    return FinancialShock(
      id: id ?? this.id,
      label: label ?? this.label,
      events: events ?? this.events,
    );
  }

  @override
  List<Object?> get props => [id, label, events];
}
