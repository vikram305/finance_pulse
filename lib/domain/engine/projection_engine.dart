import 'dart:math' as math;

import '../entities/financial_event.dart';
import '../entities/financial_shock.dart';
import '../entities/projection_node.dart';
import '../entities/resilience_score.dart';
import '../entities/scenario.dart';

class ProjectionEngine {
  const ProjectionEngine();

  List<ProjectionNode> calculate(
    Scenario scenario,
    List<FinancialShock> activeShocks, {
    double initialBalance = 0.0,
    int windowMonths = 12,
    List<FinancialEvent>? events,
  }) {
    final effectiveWindow = windowMonths.clamp(1, 36);
    final scenarioEvents = events ?? scenario.events;
    final shockEvents = activeShocks
        .expand((s) => s.events)
        .toList(growable: false);

    final nodes = <ProjectionNode>[];
    var currentBalance = initialBalance;

    for (var m = 0; m < effectiveWindow; m++) {
      final activeScenarioEvents = <FinancialEvent>[];
      for (final event in scenarioEvents) {
        if (event.startMonth <= m && m <= event.endMonth) {
          activeScenarioEvents.add(event);
        }
      }

      final activeShockEvents = <FinancialEvent>[];
      for (final event in shockEvents) {
        if (event.startMonth <= m && m <= event.endMonth) {
          activeShockEvents.add(event);
        }
      }

      final activeEventIds = <String>[
        ...activeScenarioEvents.map((e) => e.id),
        ...activeShockEvents.map((e) => e.id),
      ];

      var netCashFlow = 0.0;
      for (final event in activeScenarioEvents) {
        if (event.polarity == FinancialPolarity.income) {
          netCashFlow += event.amount;
        } else {
          netCashFlow -= event.amount;
        }
      }

      for (final event in activeShockEvents) {
        // Shocks reduce cash flow:
        // - income shock (e.g. jobLoss) zeroes/removes income (-amount)
        // - expense shock (e.g. medicalEmergency) adds expense (-amount)
        netCashFlow -= event.amount;
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

  ResilienceScore calculateResilienceScore(
    String scenarioId,
    List<ProjectionNode> nodes,
  ) {
    if (nodes.isEmpty) {
      return ResilienceScore(scenarioId: scenarioId, score: 0.0);
    }

    final firstNegativeIndex = nodes.indexWhere((n) => n.endingBalance <= 0);
    final int runway = firstNegativeIndex == -1
        ? nodes.length
        : firstNegativeIndex;

    final score = (math.min(runway / 12.0, 1.0) * 100.0).clamp(0.0, 100.0);

    return ResilienceScore(scenarioId: scenarioId, score: score);
  }
}
