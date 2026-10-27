import 'package:finance_pulse/domain/constants/financial_shocks.dart';
import 'package:finance_pulse/domain/engine/projection_engine.dart';
import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:finance_pulse/domain/entities/projection_node.dart';
import 'package:finance_pulse/domain/entities/scenario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectionEngine - Projection Calculation', () {
    const tIncomeEvent = FinancialEvent(
      id: 'e-income',
      name: 'Salary',
      polarity: FinancialPolarity.income,
      startMonth: 0,
      endMonth: 11,
      amount: 50000.0,
      isBaseline: true,
    );

    const tExpenseEvent = FinancialEvent(
      id: 'e-expense',
      name: 'Rent',
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: 11,
      amount: 20000.0,
      isBaseline: true,
    );

    test(
      'single income event across 12 months -> each node endingBalance is initialBalance + (income * (monthIndex + 1))',
      () {
        const scenario = Scenario(
          id: 's1',
          name: 'Income Plan',
          eventIds: ['e-income'],
        );

        const initialBalance = 100000.0;
        final engine = ProjectionEngine.withEvents(
          initialBalance: initialBalance,
          events: const [tIncomeEvent],
        );

        final nodes = engine.calculate(
          scenario,
          const [],
          windowMonths: 12,
        );

        expect(nodes.length, equals(12));
        for (var i = 0; i < 12; i++) {
          final expectedEndingBalance = initialBalance + (50000.0 * (i + 1));
          expect(nodes[i].monthIndex, equals(i));
          expect(nodes[i].netCashFlow, equals(50000.0));
          expect(nodes[i].endingBalance, equals(expectedEndingBalance));
          expect(nodes[i].activeEventIds, equals(['e-income']));
          if (i > 0) {
            expect(
              nodes[i].startingBalance,
              equals(nodes[i - 1].endingBalance),
            );
          } else {
            expect(nodes[i].startingBalance, equals(initialBalance));
          }
        }
      },
    );

    test('single expense event -> balance decreases correctly per month', () {
      const scenario = Scenario(
        id: 's1',
        name: 'Expense Plan',
        eventIds: ['e-expense'],
      );

      const initialBalance = 100000.0;
      final engine = ProjectionEngine.withEvents(
        initialBalance: initialBalance,
        events: const [tExpenseEvent],
      );

      final nodes = engine.calculate(
        scenario,
        const [],
        windowMonths: 12,
      );

      expect(nodes.length, equals(12));
      for (var i = 0; i < 12; i++) {
        final expectedEndingBalance = initialBalance - (20000.0 * (i + 1));
        expect(nodes[i].monthIndex, equals(i));
        expect(nodes[i].netCashFlow, equals(-20000.0));
        expect(nodes[i].endingBalance, equals(expectedEndingBalance));
        expect(nodes[i].activeEventIds, equals(['e-expense']));
      }
    });

    test(
      'event active only in its window (startMonth-endMonth) -> outside window is unaffected',
      () {
        const windowEvent = FinancialEvent(
          id: 'e-window',
          name: 'Bonus',
          polarity: FinancialPolarity.income,
          startMonth: 2,
          endMonth: 4,
          amount: 30000.0,
          isBaseline: false,
        );

        const scenario = Scenario(
          id: 's1',
          name: 'Window Plan',
          eventIds: ['e-window'],
        );

        final engine = ProjectionEngine.withEvents(
          initialBalance: 10000.0,
          events: const [windowEvent],
        );

        final nodes = engine.calculate(
          scenario,
          const [],
          windowMonths: 6,
        );

        expect(nodes.length, equals(6));
        // Month 0 and 1: not active
        expect(nodes[0].netCashFlow, equals(0.0));
        expect(nodes[0].endingBalance, equals(10000.0));
        expect(nodes[0].activeEventIds, isEmpty);

        expect(nodes[1].netCashFlow, equals(0.0));
        expect(nodes[1].endingBalance, equals(10000.0));
        expect(nodes[1].activeEventIds, isEmpty);

        // Month 2, 3, 4: active
        expect(nodes[2].netCashFlow, equals(30000.0));
        expect(nodes[2].endingBalance, equals(40000.0));
        expect(nodes[2].activeEventIds, equals(['e-window']));

        expect(nodes[3].netCashFlow, equals(30000.0));
        expect(nodes[3].endingBalance, equals(70000.0));
        expect(nodes[3].activeEventIds, equals(['e-window']));

        expect(nodes[4].netCashFlow, equals(30000.0));
        expect(nodes[4].endingBalance, equals(100000.0));
        expect(nodes[4].activeEventIds, equals(['e-window']));

        // Month 5: not active
        expect(nodes[5].netCashFlow, equals(0.0));
        expect(nodes[5].endingBalance, equals(100000.0));
        expect(nodes[5].activeEventIds, isEmpty);
      },
    );

    test('multiple overlapping events are correctly summed per month', () {
      const scenario = Scenario(
        id: 's1',
        name: 'Overlap Plan',
        eventIds: ['e-income', 'e-expense'],
      );

      final engine = ProjectionEngine.withEvents(
        initialBalance: 0.0,
        events: const [tIncomeEvent, tExpenseEvent],
      );

      final nodes = engine.calculate(
        scenario,
        const [],
        windowMonths: 12,
      );

      expect(nodes.length, equals(12));
      for (var i = 0; i < 12; i++) {
        expect(nodes[i].netCashFlow, equals(30000.0)); // 50000 - 20000
        expect(nodes[i].endingBalance, equals(30000.0 * (i + 1)));
        expect(nodes[i].activeEventIds, containsAll(['e-income', 'e-expense']));
      }
    });

    test('windowMonths = 37 is clamped to 36; output has exactly 36 nodes', () {
      const scenario = Scenario(id: 's1', name: 'Clamp Max');
      const engine = ProjectionEngine();
      final nodes = engine.calculate(scenario, const [], windowMonths: 37);
      expect(nodes.length, equals(36));
      expect(nodes.last.monthIndex, equals(35));
    });

    test('windowMonths = 0 is clamped to 1; output has exactly 1 node', () {
      const scenario = Scenario(id: 's1', name: 'Clamp Min');
      const engine = ProjectionEngine();
      final nodes = engine.calculate(scenario, const [], windowMonths: 0);
      expect(nodes.length, equals(1));
      expect(nodes.first.monthIndex, equals(0));
    });

    test('windowMonths = -5 is clamped to 1; output has exactly 1 node', () {
      const scenario = Scenario(id: 's1', name: 'Clamp Negative');
      const engine = ProjectionEngine();
      final nodes = engine.calculate(scenario, const [], windowMonths: -5);
      expect(nodes.length, equals(1));
    });

    test(
      'active shocks are flattened into the event list — medicalEmergency shock reduces month-0 endingBalance by 200000',
      () {
        const scenario = Scenario(
          id: 's1',
          name: 'Emergency Test',
          eventIds: ['e-income'],
        );

        final engine = ProjectionEngine.withEvents(
          initialBalance: 300000.0,
          events: const [tIncomeEvent],
        );

        final nodes = engine.calculate(
          scenario,
          [FinancialShocks.medicalEmergency],
          windowMonths: 12,
        );

        // Month 0: 300000 + 50000 (salary) - 200000 (medical) = 150000
        expect(nodes[0].netCashFlow, equals(-150000.0));
        expect(nodes[0].endingBalance, equals(150000.0));
        expect(
          nodes[0].activeEventIds,
          containsAll(['e-income', 'event-shock-medical-emergency']),
        );

        // Month 1: 150000 + 50000 = 200000 (medical shock was month 0 only)
        expect(nodes[1].netCashFlow, equals(50000.0));
        expect(nodes[1].endingBalance, equals(200000.0));
        expect(nodes[1].activeEventIds, equals(['e-income']));
      },
    );

    test(
      'jobLoss shock with monthlyNetIncome = 50000 zeroes income for months 0–5; months 6+ are unaffected',
      () {
        const scenario = Scenario(
          id: 's1',
          name: 'Job Loss Test',
          eventIds: ['e-income'], // 50000 income months 0-11
        );

        final jobLossShock = FinancialShocks.jobLoss(monthlyNetIncome: 50000.0);
        final engine = ProjectionEngine.withEvents(
          initialBalance: 100000.0,
          events: const [tIncomeEvent],
        );

        final nodes = engine.calculate(
          scenario,
          [jobLossShock],
          windowMonths: 12,
        );

        // Months 0-5: income zeroed -> netCashFlow = 0, balance remains 100000
        for (var i = 0; i <= 5; i++) {
          expect(
            nodes[i].netCashFlow,
            equals(0.0),
            reason: 'Month $i cash flow should be 0.0',
          );
          expect(
            nodes[i].endingBalance,
            equals(100000.0),
            reason: 'Month $i ending balance should be 100000.0',
          );
          expect(
            nodes[i].activeEventIds,
            containsAll(['e-income', 'event-shock-job-loss']),
          );
        }

        // Months 6-11: job loss shock expired -> normal income 50000
        for (var i = 6; i <= 11; i++) {
          expect(
            nodes[i].netCashFlow,
            equals(50000.0),
            reason: 'Month $i cash flow should be 50000.0',
          );
          final expectedBalance = 100000.0 + (50000.0 * (i - 5));
          expect(
            nodes[i].endingBalance,
            equals(expectedBalance),
            reason: 'Month $i ending balance should be $expectedBalance',
          );
          expect(nodes[i].activeEventIds, equals(['e-income']));
        }
      },
    );

    test(
      'scenario entity is not mutated after calculate is called with shocks',
      () {
        const scenario = Scenario(
          id: 's1',
          name: 'Immutable Scenario',
          eventIds: ['e-income'],
        );

        final shocks = [
          FinancialShocks.medicalEmergency,
          FinancialShocks.rentSpike,
        ];

        final engine = ProjectionEngine.withEvents(
          events: const [tIncomeEvent],
        );

        engine.calculate(scenario, shocks, windowMonths: 12);

        expect(scenario.eventIds, equals(['e-income']));
        expect(scenario.name, equals('Immutable Scenario'));
        expect(scenario.id, equals('s1'));
      },
    );

    test(
      'empty scenario (no events): all nodes have netCashFlow = 0, endingBalance = initialBalance',
      () {
        const scenario = Scenario(id: 's1', name: 'Empty Plan');
        const initialBalance = 75000.0;
        const engine = ProjectionEngine(initialBalance: initialBalance);

        final nodes = engine.calculate(
          scenario,
          const [],
          windowMonths: 12,
        );

        expect(nodes.length, equals(12));
        for (var i = 0; i < 12; i++) {
          expect(nodes[i].netCashFlow, equals(0.0));
          expect(nodes[i].startingBalance, equals(initialBalance));
          expect(nodes[i].endingBalance, equals(initialBalance));
          expect(nodes[i].activeEventIds, isEmpty);
        }
      },
    );

    test('performance: completes calculate for 36 months in <= 16.6ms', () {
      const scenario = Scenario(
        id: 's1',
        name: 'Perf Test',
        eventIds: ['e-income', 'e-expense'],
      );

      final engine = ProjectionEngine.withEvents(
        initialBalance: 500000.0,
        events: const [tIncomeEvent, tExpenseEvent],
      );

      final shocks = [
        FinancialShocks.jobLoss(monthlyNetIncome: 50000.0),
        FinancialShocks.medicalEmergency,
        FinancialShocks.rentSpike,
        FinancialShocks.emiShock,
      ];

      final stopwatch = Stopwatch()..start();
      final nodes = engine.calculate(
        scenario,
        shocks,
        windowMonths: 36,
      );
      stopwatch.stop();

      expect(nodes.length, equals(36));
      expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(16));
    });
  });

  group('ProjectionEngine - ResilienceScore Calculation', () {
    const engine = ProjectionEngine();

    test(
      'scenario where balance goes negative at month 3 -> runway = 3 -> score = 25.0',
      () {
        final nodes = List.generate(
          12,
          (i) => ProjectionNode(
            monthIndex: i,
            startingBalance: 100,
            netCashFlow: -25,
            endingBalance: i < 3 ? 100.0 - (25.0 * i) : -10.0,
            activeEventIds: const [],
          ),
        );

        final result = engine.calculateResilienceScore('s1', nodes);
        expect(result.scenarioId, equals('s1'));
        expect(result.score, equals(25.0));
      },
    );

    test(
      'scenario where balance stays positive for all 12 months -> runway = 12 -> score = 100.0',
      () {
        final nodes = List.generate(
          12,
          (i) => ProjectionNode(
            monthIndex: i,
            startingBalance: 1000,
            netCashFlow: 100,
            endingBalance: 1000.0 + (100.0 * (i + 1)),
            activeEventIds: const [],
          ),
        );

        final result = engine.calculateResilienceScore('s1', nodes);
        expect(result.score, equals(100.0));
      },
    );

    test(
      'scenario where balance stays positive for 24 months -> runway = 12 (capped) -> score = 100.0',
      () {
        final nodes = List.generate(
          24,
          (i) => ProjectionNode(
            monthIndex: i,
            startingBalance: 1000,
            netCashFlow: 100,
            endingBalance: 1000.0 + (100.0 * (i + 1)),
            activeEventIds: const [],
          ),
        );

        final result = engine.calculateResilienceScore('s1', nodes);
        expect(result.score, equals(100.0));
      },
    );

    test('scenario with runway = 6 months -> score = 50.0', () {
      final nodes = List.generate(
        12,
        (i) => ProjectionNode(
          monthIndex: i,
          startingBalance: 100,
          netCashFlow: -20,
          endingBalance: i < 6 ? 100.0 - (15.0 * (i + 1)) : 0.0,
          activeEventIds: const [],
        ),
      );

      final result = engine.calculateResilienceScore('s1', nodes);
      expect(result.score, equals(50.0));
    });

    test('scenario with runway = 0 (negative from month 0) -> score = 0.0', () {
      final nodes = List.generate(
        12,
        (i) => ProjectionNode(
          monthIndex: i,
          startingBalance: 0,
          netCashFlow: -100,
          endingBalance: -100.0 * (i + 1),
          activeEventIds: const [],
        ),
      );

      final result = engine.calculateResilienceScore('s1', nodes);
      expect(result.score, equals(0.0));
    });

    test('empty nodes list -> runway = 0 -> score = 0.0', () {
      final result = engine.calculateResilienceScore('s1', const []);
      expect(result.score, equals(0.0));
    });
  });
}
