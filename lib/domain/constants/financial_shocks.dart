import '../../core/constants/app_strings.dart';
import '../entities/financial_event.dart';
import '../entities/financial_shock.dart';

/// Predefined catalogue of standard financial stress shocks for the Panic Room.
///
/// Contains immutable predefined shocks used to test scenario resilience under
/// acute crises, persistent cost increases, intermediate debt, and personal income shocks.
class FinancialShocks {
  const FinancialShocks._();

  /// One-time acute crisis shock of ₹2,00,000 occurring at month 0.
  static final FinancialShock medicalEmergency = FinancialShock(
    id: 'shock-medical-emergency',
    label: AppStrings.shockMedicalEmergency,
    events: const [
      FinancialEvent(
        id: 'event-shock-medical-emergency',
        name: AppStrings.shockMedicalEmergency,
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 0,
        amount: 200000.0,
        isBaseline: false,
      ),
    ],
  );

  /// Long-term persistent cost escalation adding ₹12,000/month across the full 36-month window.
  static final FinancialShock rentSpike = FinancialShock(
    id: 'shock-rent-spike',
    label: AppStrings.shockRentSpike,
    events: const [
      FinancialEvent(
        id: 'event-shock-rent-spike',
        name: AppStrings.shockRentSpike,
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 35,
        amount: 12000.0,
        isBaseline: false,
      ),
    ],
  );

  /// Medium-term debt shock adding ₹15,000/month for a duration of 24 months (months 0–23).
  static final FinancialShock emiShock = FinancialShock(
    id: 'shock-emi-shock',
    label: AppStrings.shockEmiShock,
    events: const [
      FinancialEvent(
        id: 'event-shock-emi-shock',
        name: AppStrings.shockEmiShock,
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 23,
        amount: 15000.0,
        isBaseline: false,
      ),
    ],
  );

  /// Factory constructing an income-zeroing shock dynamically scaled to [monthlyNetIncome].
  ///
  /// Zeroes income for months 0–5 (6 months total). Its financial event carries
  /// [FinancialPolarity.income] matching the user's earned income magnitude, which
  /// is subtracted from active income during projection evaluation.
  static FinancialShock jobLoss({required double monthlyNetIncome}) {
    return FinancialShock(
      id: 'shock-job-loss',
      label: AppStrings.shockJobLoss,
      events: [
        FinancialEvent(
          id: 'event-shock-job-loss',
          name: AppStrings.shockJobLoss,
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
