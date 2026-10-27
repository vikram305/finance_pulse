import 'package:equatable/equatable.dart';

/// Represents a single monthly snapshot in a scenario projection trajectory.
///
/// Contains mathematical balances and cash flows computed by [ProjectionEngine],
/// alongside the list of active event IDs contributing to this monthly slice.
class ProjectionNode extends Equatable {
  /// The 0-indexed month of this projection slice relative to the timeline start.
  final int monthIndex;

  /// Liquid balance at the beginning of this month (prior month's ending balance,
  /// or initial liquid balance for month 0).
  final double startingBalance;

  /// Aggregated net cash flow for this month (total active income minus total active expenses).
  final double netCashFlow;

  /// Projected liquid balance at the close of this month (`startingBalance + netCashFlow`).
  final double endingBalance;

  /// List of event IDs (scenario events and active shocks) active in this month.
  final List<String> activeEventIds;

  /// Creates a [ProjectionNode] representing monthly balance and cash flow metrics.
  const ProjectionNode({
    required this.monthIndex,
    required this.startingBalance,
    required this.netCashFlow,
    required this.endingBalance,
    required this.activeEventIds,
  });

  @override
  List<Object?> get props => [
    monthIndex,
    startingBalance,
    netCashFlow,
    endingBalance,
    activeEventIds,
  ];
}
