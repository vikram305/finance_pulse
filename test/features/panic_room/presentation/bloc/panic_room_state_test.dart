import 'package:finance_pulse/domain/constants/financial_shocks.dart';
import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:finance_pulse/domain/entities/projection_node.dart';
import 'package:finance_pulse/domain/entities/resilience_score.dart';
import 'package:finance_pulse/domain/entities/scenario.dart';
import 'package:finance_pulse/features/panic_room/presentation/bloc/panic_room_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PanicRoomState', () {
    const tScenario = Scenario(id: 's1', name: 'Scenario A', eventIds: ['e1']);
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
    const tScore = ResilienceScore(scenarioId: 's1', score: 75.0);
    final tShockA = FinancialShocks.medicalEmergency;
    final tShockB = FinancialShocks.rentSpike;

    final tState = PanicRoomState(
      activeShockIds: const {'shock-medical-emergency'},
      availableShocks: [tShockA, tShockB],
      projectionsByScenarioId: const {
        's1': [tNode],
      },
      scoresByScenarioId: const {'s1': tScore},
      survivalMonthsByScenarioId: const {'s1': 8.0},
      scenarios: const {'s1': tScenario},
      eventsByScenarioId: const {
        's1': [tEvent],
      },
      liquidBalance: 100000.0,
      monthlyNetIncome: 60000.0,
      projectionWindowMonths: 12,
    );

    test('two instances with identical values are equal', () {
      final other = PanicRoomState(
        activeShockIds: const {'shock-medical-emergency'},
        availableShocks: [tShockA, tShockB],
        projectionsByScenarioId: const {
          's1': [tNode],
        },
        scoresByScenarioId: const {'s1': tScore},
        survivalMonthsByScenarioId: const {'s1': 8.0},
        scenarios: const {'s1': tScenario},
        eventsByScenarioId: const {
          's1': [tEvent],
        },
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
        projectionWindowMonths: 12,
      );

      expect(tState, equals(other));
    });

    test('initial state has 4 available shocks and empty activeShockIds', () {
      final initial = PanicRoomState.initial();
      expect(initial.activeShockIds, isEmpty);
      expect(initial.availableShocks.length, equals(4));
      expect(initial.projectionsByScenarioId, isEmpty);
      expect(initial.scoresByScenarioId, isEmpty);
      expect(initial.survivalMonthsByScenarioId, isEmpty);
      expect(initial.scenarios, isEmpty);
      expect(initial.eventsByScenarioId, isEmpty);
      expect(initial.liquidBalance, 0.0);
      expect(initial.monthlyNetIncome, 0.0);
      expect(initial.projectionWindowMonths, 12);
    });

    test('instances differing by activeShockIds are not equal', () {
      final other = tState.copyWith(activeShockIds: const {'shock-rent-spike'});
      expect(tState, isNot(equals(other)));
    });

    test('instances differing by availableShocks are not equal', () {
      final other = tState.copyWith(availableShocks: [tShockA]);
      expect(tState, isNot(equals(other)));
    });

    test('instances differing by projectionsByScenarioId are not equal', () {
      final other = tState.copyWith(projectionsByScenarioId: const {});
      expect(tState, isNot(equals(other)));
    });

    test('instances differing by scoresByScenarioId are not equal', () {
      final other = tState.copyWith(
        scoresByScenarioId: const {
          's1': ResilienceScore(scenarioId: 's1', score: 50.0),
        },
      );
      expect(tState, isNot(equals(other)));
    });

    test('instances differing by survivalMonthsByScenarioId are not equal', () {
      final other = tState.copyWith(
        survivalMonthsByScenarioId: const {'s1': 4.0},
      );
      expect(tState, isNot(equals(other)));
    });

    test('instances differing by scenarios are not equal', () {
      final other = tState.copyWith(scenarios: const {});
      expect(tState, isNot(equals(other)));
    });

    test('instances differing by eventsByScenarioId are not equal', () {
      final other = tState.copyWith(eventsByScenarioId: const {});
      expect(tState, isNot(equals(other)));
    });

    test('instances differing by liquidBalance are not equal', () {
      final other = tState.copyWith(liquidBalance: 50000.0);
      expect(tState, isNot(equals(other)));
    });

    test('instances differing by monthlyNetIncome are not equal', () {
      final other = tState.copyWith(monthlyNetIncome: 75000.0);
      expect(tState, isNot(equals(other)));
    });

    test('instances differing by projectionWindowMonths are not equal', () {
      final other = tState.copyWith(projectionWindowMonths: 24);
      expect(tState, isNot(equals(other)));
    });

    test('copyWith creates updated clone', () {
      final updated = tState.copyWith(
        liquidBalance: 200000.0,
        activeShockIds: const {'shock-rent-spike'},
      );
      expect(updated.liquidBalance, 200000.0);
      expect(updated.activeShockIds, const {'shock-rent-spike'});
      expect(updated.scenarios, tState.scenarios);
    });
  });
}
