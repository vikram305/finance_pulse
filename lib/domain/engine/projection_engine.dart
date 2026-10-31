import 'dart:math' as math;

import '../../core/constants/app_constants.dart';
import '../entities/financial_event.dart';
import '../entities/financial_shock.dart';
import '../entities/projection_node.dart';
import '../entities/resilience_score.dart';
import '../entities/scenario.dart';

/// Pure calculation engine for projecting financial balance trajectories
/// and evaluating resilience scores.
///
/// Operates synchronously at O(N x M) complexity, completing well within
/// frame rendering budgets (<= 16.6ms on 60fps devices). The engine enforces
/// a hard cap of 36 months regardless of caller input.
class ProjectionEngine {
  /// Initial liquid balance at month 0 prior to any cash flow events.
  final double initialBalance;

  /// Map of [FinancialEvent] entities keyed by their unique ID used to resolve
  /// scenario [Scenario.eventIds].
  final Map<String, FinancialEvent> eventLookup;

  /// Creates a [ProjectionEngine] with an optional [initialBalance] and [eventLookup].
  const ProjectionEngine({
    this.initialBalance = 0.0,
    this.eventLookup = const {},
  });

  /// Factory constructor that indexes a list of [events] by their ID for lookup.
  factory ProjectionEngine.withEvents({
    double initialBalance = 0.0,
    List<FinancialEvent> events = const [],
  }) {
    return ProjectionEngine(
      initialBalance: initialBalance,
      eventLookup: {for (final event in events) event.id: event},
    );
  }

  /// Calculates monthly projection nodes for [scenario] with [activeShocks] applied.
  ///
  /// Merges scenario events and active shock events into a single unified event list
  /// prior to node computation. Enforces that [windowMonths] is clamped within [1, 36].
  /// Optional [initialBalance], [eventLookup], or [events] can be passed to override
  /// instance-level fields (allowing [ProjectionEngine] to be reused as a stateless singleton).
  List<ProjectionNode> calculate(
    Scenario scenario,
    List<FinancialShock> activeShocks, {
    int windowMonths = AppConstants.defaultProjectionMonths,
    double? initialBalance,
    Map<String, FinancialEvent>? eventLookup,
    List<FinancialEvent>? events,
  }) {
    final effectiveWindow =
        windowMonths.clamp(1, AppConstants.maxProjectionMonths);

    final effectiveLookup = eventLookup ??
        (events != null
            ? {for (final event in events) event.id: event}
            : this.eventLookup);

    // Resolve scenario events via effectiveLookup
    final scenarioEvents = scenario.eventIds
        .map((id) => effectiveLookup[id])
        .whereType<FinancialEvent>()
        .toList(growable: false);

    // Extract all shock events from active shocks
    final shockEvents = activeShocks
        .expand((s) => s.events)
        .toList(growable: false);

    final shockEventIds = shockEvents.map((e) => e.id).toSet();

    // Shock flattening: effective event list = scenario events + all shock events
    // merged before computing nodes.
    final effectiveEvents = <FinancialEvent>[
      ...scenarioEvents,
      ...shockEvents,
    ];

    final nodes = <ProjectionNode>[];
    var currentBalance = initialBalance ?? this.initialBalance;

    for (var m = 0; m < effectiveWindow; m++) {
      // Single unified filtering loop over the flattened event list
      final activeEvents = <FinancialEvent>[];
      for (final event in effectiveEvents) {
        if (event.startMonth <= m && m <= event.endMonth) {
          activeEvents.add(event);
        }
      }

      final activeEventIds =
          activeEvents.map((e) => e.id).toList(growable: false);

      var netCashFlow = 0.0;
      for (final event in activeEvents) {
        final isShock = shockEventIds.contains(event.id);
        if (isShock) {
          // Inspect polarity for shock events:
          // In V1, both expense shocks (e.g. medical emergency, rent spike) and
          // personal income shocks (e.g. job loss) reduce projected liquid cash flow.
          netCashFlow -= event.amount;
        } else {
          // Standard scenario event polarity evaluation
          if (event.polarity == FinancialPolarity.income) {
            netCashFlow += event.amount;
          } else {
            netCashFlow -= event.amount;
          }
        }
      }

      final startingBalance = currentBalance;
      final endingBalance = startingBalance + netCashFlow;
      currentBalance = endingBalance;

      nodes.add(
        ProjectionNode(
          monthIndex: m,
          startingBalance: startingBalance,
          netCashFlow: netCashFlow,
          endingBalance: endingBalance,
          activeEventIds: activeEventIds,
        ),
      );
    }

    return nodes;
  }

  /// Calculates the [ResilienceScore] for [scenarioId] given a sequence of projection [nodes].
  ///
  /// Runway is defined as the month index when [ProjectionNode.endingBalance] first
  /// drops to <= 0. If balance never drops to <= 0, runway equals [nodes.length].
  /// The formula normalises runway against a 12-month ceiling:
  /// `score = min(runway / 12.0, 1.0) * 100.0`, clamped between 0.0 and 100.0.
  ResilienceScore calculateResilienceScore(
    String scenarioId,
    List<ProjectionNode> nodes,
  ) {
    if (nodes.isEmpty) {
      return ResilienceScore(scenarioId: scenarioId, score: 0.0);
    }

    final firstNegativeIndex = nodes.indexWhere((n) => n.endingBalance <= 0);
    final int runway =
        firstNegativeIndex == -1 ? nodes.length : firstNegativeIndex;

    final score = (math.min(
      runway / AppConstants.resilienceRunwayCeilingMonths,
      1.0,
    ) * 100.0).clamp(0.0, 100.0);

    return ResilienceScore(scenarioId: scenarioId, score: score);
  }
}
