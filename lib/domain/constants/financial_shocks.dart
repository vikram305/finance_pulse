import '../entities/financial_event.dart';
import '../entities/financial_shock.dart';

class FinancialShocks {
  const FinancialShocks._();

  static final FinancialShock medicalEmergency = FinancialShock(
    id: 'shock-medical-emergency',
    label: 'Medical Emergency',
    events: const [
      FinancialEvent(
        id: 'event-shock-medical-emergency',
        name: 'Medical Emergency',
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 0,
        amount: 200000.0,
        isBaseline: false,
      ),
    ],
  );

  static final FinancialShock rentSpike = FinancialShock(
    id: 'shock-rent-spike',
    label: 'Rent Spike',
    events: const [
      FinancialEvent(
        id: 'event-shock-rent-spike',
        name: 'Rent Spike',
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 35,
        amount: 12000.0,
        isBaseline: false,
      ),
    ],
  );

  static final FinancialShock emiShock = FinancialShock(
    id: 'shock-emi-shock',
    label: 'EMI Shock',
    events: const [
      FinancialEvent(
        id: 'event-shock-emi-shock',
        name: 'EMI Shock',
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 23,
        amount: 15000.0,
        isBaseline: false,
      ),
    ],
  );

  static FinancialShock jobLoss({required double monthlyNetIncome}) {
    return FinancialShock(
      id: 'shock-job-loss',
      label: 'Job Loss',
      events: [
        FinancialEvent(
          id: 'event-shock-job-loss',
          name: 'Job Loss',
          polarity: FinancialPolarity.income,
          startMonth: 0,
          endMonth: 5,
          amount: monthlyNetIncome,
          isBaseline: false,
        ),
      ],
    );
  }
}
