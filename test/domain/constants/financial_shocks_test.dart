import 'package:finance_pulse/domain/constants/financial_shocks.dart';
import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialShocks Catalogue', () {
    test(
      'jobLoss(monthlyNetIncome: 80000) returns a shock whose event has amount = 80000',
      () {
        final shock = FinancialShocks.jobLoss(monthlyNetIncome: 80000);
        expect(shock.events.length, equals(1));
        expect(shock.events.first.amount, equals(80000.0));
        expect(shock.events.first.polarity, equals(FinancialPolarity.income));
        expect(shock.events.first.startMonth, equals(0));
        expect(shock.events.first.endMonth, equals(5));
      },
    );

    test(
      'jobLoss(monthlyNetIncome: 40000) returns a shock whose event has amount = 40000',
      () {
        final shock = FinancialShocks.jobLoss(monthlyNetIncome: 40000);
        expect(shock.events.first.amount, equals(40000.0));
      },
    );

    test('medicalEmergency has amount = 200000 at month 0', () {
      final shock = FinancialShocks.medicalEmergency;
      expect(shock.events.length, equals(1));
      expect(shock.events.first.amount, equals(200000.0));
      expect(shock.events.first.startMonth, equals(0));
      expect(shock.events.first.endMonth, equals(0));
      expect(shock.events.first.polarity, equals(FinancialPolarity.expense));
    });

    test(
      'rentSpike has amount = 12000 for full projection window (months 0-35)',
      () {
        final shock = FinancialShocks.rentSpike;
        expect(shock.events.length, equals(1));
        expect(shock.events.first.amount, equals(12000.0));
        expect(shock.events.first.startMonth, equals(0));
        expect(shock.events.first.endMonth, equals(35));
        expect(shock.events.first.polarity, equals(FinancialPolarity.expense));
      },
    );

    test('emiShock has amount = 15000 with endMonth = 23 (24 months)', () {
      final shock = FinancialShocks.emiShock;
      expect(shock.events.length, equals(1));
      expect(shock.events.first.amount, equals(15000.0));
      expect(shock.events.first.startMonth, equals(0));
      expect(shock.events.first.endMonth, equals(23));
      expect(shock.events.first.polarity, equals(FinancialPolarity.expense));
    });
  });
}
