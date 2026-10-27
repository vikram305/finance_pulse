import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:finance_pulse/domain/entities/financial_shock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialShock', () {
    const tEvent1 = FinancialEvent(
      id: 'e1',
      name: 'Event 1',
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: 0,
      amount: 1000.0,
      isBaseline: false,
    );

    const tEvent2 = FinancialEvent(
      id: 'e2',
      name: 'Event 2',
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: 1,
      amount: 2000.0,
      isBaseline: false,
    );

    const tShock = FinancialShock(
      id: 's1',
      label: 'Emergency',
      events: [tEvent1],
    );

    test('two instances with identical values are equal', () {
      const other = FinancialShock(
        id: 's1',
        label: 'Emergency',
        events: [tEvent1],
      );
      expect(tShock, equals(other));
    });

    test('instances differing by id are not equal', () {
      const other = FinancialShock(
        id: 's2',
        label: 'Emergency',
        events: [tEvent1],
      );
      expect(tShock, isNot(equals(other)));
    });

    test('instances differing by label are not equal', () {
      const other = FinancialShock(
        id: 's1',
        label: 'Other Emergency',
        events: [tEvent1],
      );
      expect(tShock, isNot(equals(other)));
    });

    test('instances differing by events are not equal', () {
      const other = FinancialShock(
        id: 's1',
        label: 'Emergency',
        events: [tEvent2],
      );
      expect(tShock, isNot(equals(other)));
    });

    test('copyWith creates a copy with updated fields', () {
      final updated = tShock.copyWith(label: 'Updated Label');
      expect(
        updated,
        equals(
          const FinancialShock(
            id: 's1',
            label: 'Updated Label',
            events: [tEvent1],
          ),
        ),
      );
    });
  });
}
