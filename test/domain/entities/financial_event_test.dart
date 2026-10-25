import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialEvent', () {
    const tEvent = FinancialEvent(
      id: 'e1',
      name: 'Salary',
      polarity: FinancialPolarity.income,
      startMonth: 0,
      endMonth: 11,
      amount: 50000.0,
      isBaseline: true,
    );

    test('two instances with identical values are equal', () {
      const other = FinancialEvent(
        id: 'e1',
        name: 'Salary',
        polarity: FinancialPolarity.income,
        startMonth: 0,
        endMonth: 11,
        amount: 50000.0,
        isBaseline: true,
      );
      expect(tEvent, equals(other));
    });

    test('instances differing by id are not equal', () {
      const other = FinancialEvent(
        id: 'e2',
        name: 'Salary',
        polarity: FinancialPolarity.income,
        startMonth: 0,
        endMonth: 11,
        amount: 50000.0,
        isBaseline: true,
      );
      expect(tEvent, isNot(equals(other)));
    });

    test('instances differing by name are not equal', () {
      const other = FinancialEvent(
        id: 'e1',
        name: 'Bonus',
        polarity: FinancialPolarity.income,
        startMonth: 0,
        endMonth: 11,
        amount: 50000.0,
        isBaseline: true,
      );
      expect(tEvent, isNot(equals(other)));
    });

    test('instances differing by polarity are not equal', () {
      const other = FinancialEvent(
        id: 'e1',
        name: 'Salary',
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 11,
        amount: 50000.0,
        isBaseline: true,
      );
      expect(tEvent, isNot(equals(other)));
    });

    test('instances differing by startMonth are not equal', () {
      const other = FinancialEvent(
        id: 'e1',
        name: 'Salary',
        polarity: FinancialPolarity.income,
        startMonth: 1,
        endMonth: 11,
        amount: 50000.0,
        isBaseline: true,
      );
      expect(tEvent, isNot(equals(other)));
    });

    test('instances differing by endMonth are not equal', () {
      const other = FinancialEvent(
        id: 'e1',
        name: 'Salary',
        polarity: FinancialPolarity.income,
        startMonth: 0,
        endMonth: 12,
        amount: 50000.0,
        isBaseline: true,
      );
      expect(tEvent, isNot(equals(other)));
    });

    test('instances differing by amount are not equal', () {
      const other = FinancialEvent(
        id: 'e1',
        name: 'Salary',
        polarity: FinancialPolarity.income,
        startMonth: 0,
        endMonth: 11,
        amount: 60000.0,
        isBaseline: true,
      );
      expect(tEvent, isNot(equals(other)));
    });

    test('instances differing by isBaseline are not equal', () {
      const other = FinancialEvent(
        id: 'e1',
        name: 'Salary',
        polarity: FinancialPolarity.income,
        startMonth: 0,
        endMonth: 11,
        amount: 50000.0,
        isBaseline: false,
      );
      expect(tEvent, isNot(equals(other)));
    });

    test('copyWith creates a copy with updated fields', () {
      final updated = tEvent.copyWith(name: 'Updated Salary', amount: 55000.0);
      expect(
        updated,
        equals(
          const FinancialEvent(
            id: 'e1',
            name: 'Updated Salary',
            polarity: FinancialPolarity.income,
            startMonth: 0,
            endMonth: 11,
            amount: 55000.0,
            isBaseline: true,
          ),
        ),
      );
    });
  });
}
