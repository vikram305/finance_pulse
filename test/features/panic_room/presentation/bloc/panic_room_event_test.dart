import 'package:finance_pulse/domain/constants/financial_shocks.dart';
import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:finance_pulse/domain/entities/scenario.dart';
import 'package:finance_pulse/features/panic_room/presentation/bloc/panic_room_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PanicRoomEvents', () {
    const tScenarioA = Scenario(id: 's1', name: 'Scenario A', eventIds: ['e1']);
    const tScenarioB = Scenario(id: 's2', name: 'Scenario B', eventIds: ['e2']);

    const tEventA = FinancialEvent(
      id: 'e1',
      name: 'Rent',
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: 11,
      amount: 25000.0,
      isBaseline: false,
    );
    const tEventB = FinancialEvent(
      id: 'e2',
      name: 'Salary',
      polarity: FinancialPolarity.income,
      startMonth: 0,
      endMonth: 11,
      amount: 60000.0,
      isBaseline: true,
    );

    group('PanicRoomEntered', () {
      final tEvent1 = PanicRoomEntered(
        scenarios: const {'s1': tScenarioA},
        eventsByScenarioId: const {
          's1': [tEventA],
        },
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
        projectionWindowMonths: 12,
      );

      final tEventIdentical = PanicRoomEntered(
        scenarios: const {'s1': tScenarioA},
        eventsByScenarioId: const {
          's1': [tEventA],
        },
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
        projectionWindowMonths: 12,
      );

      test('supports value equality', () {
        expect(tEvent1, equals(tEventIdentical));
      });

      test('differentiates by scenarios', () {
        final other = PanicRoomEntered(
          scenarios: const {'s2': tScenarioB},
          eventsByScenarioId: const {
            's1': [tEventA],
          },
          liquidBalance: 100000.0,
          monthlyNetIncome: 60000.0,
          projectionWindowMonths: 12,
        );
        expect(tEvent1, isNot(equals(other)));
      });

      test('differentiates by eventsByScenarioId', () {
        final other = PanicRoomEntered(
          scenarios: const {'s1': tScenarioA},
          eventsByScenarioId: const {
            's1': [tEventB],
          },
          liquidBalance: 100000.0,
          monthlyNetIncome: 60000.0,
          projectionWindowMonths: 12,
        );
        expect(tEvent1, isNot(equals(other)));
      });

      test('differentiates by liquidBalance', () {
        final other = PanicRoomEntered(
          scenarios: const {'s1': tScenarioA},
          eventsByScenarioId: const {
            's1': [tEventA],
          },
          liquidBalance: 50000.0,
          monthlyNetIncome: 60000.0,
          projectionWindowMonths: 12,
        );
        expect(tEvent1, isNot(equals(other)));
      });

      test('differentiates by monthlyNetIncome', () {
        final other = PanicRoomEntered(
          scenarios: const {'s1': tScenarioA},
          eventsByScenarioId: const {
            's1': [tEventA],
          },
          liquidBalance: 100000.0,
          monthlyNetIncome: 75000.0,
          projectionWindowMonths: 12,
        );
        expect(tEvent1, isNot(equals(other)));
      });

      test('differentiates by projectionWindowMonths', () {
        final other = PanicRoomEntered(
          scenarios: const {'s1': tScenarioA},
          eventsByScenarioId: const {
            's1': [tEventA],
          },
          liquidBalance: 100000.0,
          monthlyNetIncome: 60000.0,
          projectionWindowMonths: 24,
        );
        expect(tEvent1, isNot(equals(other)));
      });
    });

    group('ShockToggled', () {
      final tShockA = FinancialShocks.medicalEmergency;
      final tShockB = FinancialShocks.rentSpike;

      test('supports value equality', () {
        expect(
          ShockToggled(shock: tShockA),
          equals(ShockToggled(shock: tShockA)),
        );
      });

      test('differentiates by shock', () {
        expect(
          ShockToggled(shock: tShockA),
          isNot(equals(ShockToggled(shock: tShockB))),
        );
      });
    });

    group('PanicRoomExited', () {
      test('supports value equality', () {
        expect(const PanicRoomExited(), equals(const PanicRoomExited()));
      });
    });
  });
}

