import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:finance_pulse/domain/entities/scenario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scenario', () {
    const tScenario = Scenario(
      id: 's1',
      name: 'Base Plan',
      eventIds: ['e1', 'e2'],
    );

    test('two instances with identical values are equal', () {
      const other = Scenario(
        id: 's1',
        name: 'Base Plan',
        eventIds: ['e1', 'e2'],
      );
      expect(tScenario, equals(other));
    });

    test('instances differing by id are not equal', () {
      const other = Scenario(
        id: 's2',
        name: 'Base Plan',
        eventIds: ['e1', 'e2'],
      );
      expect(tScenario, isNot(equals(other)));
    });

    test('instances differing by name are not equal', () {
      const other = Scenario(
        id: 's1',
        name: 'Alternative Plan',
        eventIds: ['e1', 'e2'],
      );
      expect(tScenario, isNot(equals(other)));
    });

    test('instances differing by eventIds are not equal', () {
      const other = Scenario(id: 's1', name: 'Base Plan', eventIds: ['e1']);
      expect(tScenario, isNot(equals(other)));
    });

    test('instances differing by events are not equal', () {
      const eventA = FinancialEvent(
        id: 'e1',
        name: 'Salary',
        polarity: FinancialPolarity.income,
        startMonth: 0,
        endMonth: 11,
        amount: 50000.0,
        isBaseline: true,
      );
      final s1 = const Scenario(
        id: 's1',
        name: 'Base Plan',
        eventIds: ['e1'],
        events: [eventA],
      );
      final s2 = const Scenario(
        id: 's1',
        name: 'Base Plan',
        eventIds: ['e1'],
        events: [],
      );
      expect(s1, isNot(equals(s2)));
    });

    test('copyWith creates a copy with updated fields', () {
      final updated = tScenario.copyWith(
        name: 'Renamed Plan',
        eventIds: ['e1', 'e2', 'e3'],
      );
      expect(
        updated,
        equals(
          const Scenario(
            id: 's1',
            name: 'Renamed Plan',
            eventIds: ['e1', 'e2', 'e3'],
          ),
        ),
      );
    });
  });
}
