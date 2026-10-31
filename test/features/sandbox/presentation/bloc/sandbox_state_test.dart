import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:finance_pulse/domain/entities/projection_node.dart';
import 'package:finance_pulse/domain/entities/scenario.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SandboxState', () {
    const tScenario = Scenario(
      id: 's1',
      name: 'Scenario A',
      eventIds: ['e1'],
    );
    const tEvent = FinancialEvent(
      id: 'e1',
      name: 'Rent',
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: 35,
      amount: 30000.0,
      isBaseline: false,
    );
    const tNode = ProjectionNode(
      monthIndex: 0,
      startingBalance: 100000.0,
      netCashFlow: -30000.0,
      endingBalance: 70000.0,
      activeEventIds: ['e1'],
    );

    const tState = SandboxState(
      scenarios: {'s1': tScenario},
      eventsByScenarioId: {
        's1': [tEvent],
      },
      projectionsByScenarioId: {
        's1': [tNode],
      },
      projectionWindowMonths: 12,
      liquidBalance: 100000.0,
      monthlyNetIncome: 60000.0,
    );

    test('two instances with identical values are equal', () {
      const other = SandboxState(
        scenarios: {'s1': tScenario},
        eventsByScenarioId: {
          's1': [tEvent],
        },
        projectionsByScenarioId: {
          's1': [tNode],
        },
        projectionWindowMonths: 12,
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
      );

      expect(tState, equals(other));
    });

    test('instances differing by scenarios are not equal', () {
      const other = SandboxState(
        scenarios: {
          's2': Scenario(id: 's2', name: 'Scenario B', eventIds: []),
        },
        eventsByScenarioId: {
          's1': [tEvent],
        },
        projectionsByScenarioId: {
          's1': [tNode],
        },
        projectionWindowMonths: 12,
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
      );

      expect(tState, isNot(equals(other)));
    });

    test('instances differing by eventsByScenarioId are not equal', () {
      const other = SandboxState(
        scenarios: {'s1': tScenario},
        eventsByScenarioId: {
          's1': [],
        },
        projectionsByScenarioId: {
          's1': [tNode],
        },
        projectionWindowMonths: 12,
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
      );

      expect(tState, isNot(equals(other)));
    });

    test('instances differing by projectionsByScenarioId are not equal', () {
      const other = SandboxState(
        scenarios: {'s1': tScenario},
        eventsByScenarioId: {
          's1': [tEvent],
        },
        projectionsByScenarioId: {},
        projectionWindowMonths: 12,
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
      );

      expect(tState, isNot(equals(other)));
    });

    test('instances differing by projectionWindowMonths are not equal', () {
      const other = SandboxState(
        scenarios: {'s1': tScenario},
        eventsByScenarioId: {
          's1': [tEvent],
        },
        projectionsByScenarioId: {
          's1': [tNode],
        },
        projectionWindowMonths: 24,
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
      );

      expect(tState, isNot(equals(other)));
    });

    test('instances differing by liquidBalance are not equal', () {
      const other = SandboxState(
        scenarios: {'s1': tScenario},
        eventsByScenarioId: {
          's1': [tEvent],
        },
        projectionsByScenarioId: {
          's1': [tNode],
        },
        projectionWindowMonths: 12,
        liquidBalance: 50000.0,
        monthlyNetIncome: 60000.0,
      );

      expect(tState, isNot(equals(other)));
    });

    test('instances differing by monthlyNetIncome are not equal', () {
      const other = SandboxState(
        scenarios: {'s1': tScenario},
        eventsByScenarioId: {
          's1': [tEvent],
        },
        projectionsByScenarioId: {
          's1': [tNode],
        },
        projectionWindowMonths: 12,
        liquidBalance: 100000.0,
        monthlyNetIncome: 75000.0,
      );

      expect(tState, isNot(equals(other)));
    });

    test('copyWith updates specified fields while retaining others', () {
      final updated = tState.copyWith(
        projectionWindowMonths: 36,
        liquidBalance: 120000.0,
      );

      expect(updated.projectionWindowMonths, 36);
      expect(updated.liquidBalance, 120000.0);
      expect(updated.monthlyNetIncome, 60000.0);
      expect(updated.scenarios, tState.scenarios);
      expect(updated.eventsByScenarioId, tState.eventsByScenarioId);
      expect(updated.projectionsByScenarioId, tState.projectionsByScenarioId);
    });
  });
}

