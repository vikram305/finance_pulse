import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SandboxEvents', () {
    const tEventA = FinancialEvent(
      id: 'e1',
      name: 'Rent',
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: 35,
      amount: 30000.0,
      isBaseline: false,
    );
    const tEventB = FinancialEvent(
      id: 'e2',
      name: 'Bonus',
      polarity: FinancialPolarity.income,
      startMonth: 1,
      endMonth: 1,
      amount: 50000.0,
      isBaseline: true,
    );

    group('SandboxInitialized', () {
      test('supports value equality', () {
        expect(
          const SandboxInitialized(liquidBalance: 1000, monthlyNetIncome: 500),
          equals(
            const SandboxInitialized(
              liquidBalance: 1000,
              monthlyNetIncome: 500,
            ),
          ),
        );
      });

      test('differentiates by liquidBalance', () {
        expect(
          const SandboxInitialized(liquidBalance: 1000, monthlyNetIncome: 500),
          isNot(
            equals(
              const SandboxInitialized(
                liquidBalance: 2000,
                monthlyNetIncome: 500,
              ),
            ),
          ),
        );
      });

      test('differentiates by monthlyNetIncome', () {
        expect(
          const SandboxInitialized(liquidBalance: 1000, monthlyNetIncome: 500),
          isNot(
            equals(
              const SandboxInitialized(
                liquidBalance: 1000,
                monthlyNetIncome: 600,
              ),
            ),
          ),
        );
      });
    });

    group('FinancialEventAdded', () {
      test('supports value equality', () {
        expect(
          const FinancialEventAdded(scenarioId: 's1', event: tEventA),
          equals(const FinancialEventAdded(scenarioId: 's1', event: tEventA)),
        );
      });

      test('differentiates by scenarioId', () {
        expect(
          const FinancialEventAdded(scenarioId: 's1', event: tEventA),
          isNot(
            equals(const FinancialEventAdded(scenarioId: 's2', event: tEventA)),
          ),
        );
      });

      test('differentiates by event', () {
        expect(
          const FinancialEventAdded(scenarioId: 's1', event: tEventA),
          isNot(
            equals(const FinancialEventAdded(scenarioId: 's1', event: tEventB)),
          ),
        );
      });
    });

    group('FinancialEventUpdated', () {
      test('supports value equality', () {
        expect(
          const FinancialEventUpdated(scenarioId: 's1', event: tEventA),
          equals(const FinancialEventUpdated(scenarioId: 's1', event: tEventA)),
        );
      });

      test('differentiates by scenarioId', () {
        expect(
          const FinancialEventUpdated(scenarioId: 's1', event: tEventA),
          isNot(
            equals(
              const FinancialEventUpdated(scenarioId: 's2', event: tEventA),
            ),
          ),
        );
      });

      test('differentiates by event', () {
        expect(
          const FinancialEventUpdated(scenarioId: 's1', event: tEventA),
          isNot(
            equals(
              const FinancialEventUpdated(scenarioId: 's1', event: tEventB),
            ),
          ),
        );
      });
    });

    group('FinancialEventDeleted', () {
      test('supports value equality', () {
        expect(
          const FinancialEventDeleted(scenarioId: 's1', eventId: 'e1'),
          equals(const FinancialEventDeleted(scenarioId: 's1', eventId: 'e1')),
        );
      });

      test('differentiates by scenarioId', () {
        expect(
          const FinancialEventDeleted(scenarioId: 's1', eventId: 'e1'),
          isNot(
            equals(
              const FinancialEventDeleted(scenarioId: 's2', eventId: 'e1'),
            ),
          ),
        );
      });

      test('differentiates by eventId', () {
        expect(
          const FinancialEventDeleted(scenarioId: 's1', eventId: 'e1'),
          isNot(
            equals(
              const FinancialEventDeleted(scenarioId: 's1', eventId: 'e2'),
            ),
          ),
        );
      });
    });

    group('FinancialEventStartMonthChanged', () {
      test('supports value equality', () {
        expect(
          const FinancialEventStartMonthChanged(
            scenarioId: 's1',
            eventId: 'e1',
            newStartMonth: 3,
          ),
          equals(
            const FinancialEventStartMonthChanged(
              scenarioId: 's1',
              eventId: 'e1',
              newStartMonth: 3,
            ),
          ),
        );
      });

      test('differentiates by scenarioId', () {
        expect(
          const FinancialEventStartMonthChanged(
            scenarioId: 's1',
            eventId: 'e1',
            newStartMonth: 3,
          ),
          isNot(
            equals(
              const FinancialEventStartMonthChanged(
                scenarioId: 's2',
                eventId: 'e1',
                newStartMonth: 3,
              ),
            ),
          ),
        );
      });

      test('differentiates by eventId', () {
        expect(
          const FinancialEventStartMonthChanged(
            scenarioId: 's1',
            eventId: 'e1',
            newStartMonth: 3,
          ),
          isNot(
            equals(
              const FinancialEventStartMonthChanged(
                scenarioId: 's1',
                eventId: 'e2',
                newStartMonth: 3,
              ),
            ),
          ),
        );
      });

      test('differentiates by newStartMonth', () {
        expect(
          const FinancialEventStartMonthChanged(
            scenarioId: 's1',
            eventId: 'e1',
            newStartMonth: 3,
          ),
          isNot(
            equals(
              const FinancialEventStartMonthChanged(
                scenarioId: 's1',
                eventId: 'e1',
                newStartMonth: 5,
              ),
            ),
          ),
        );
      });
    });

    group('ScenarioForked', () {
      test('supports value equality', () {
        expect(
          const ScenarioForked(newScenarioName: 'Scenario B'),
          equals(const ScenarioForked(newScenarioName: 'Scenario B')),
        );
      });

      test('differentiates by newScenarioName', () {
        expect(
          const ScenarioForked(newScenarioName: 'Scenario B'),
          isNot(equals(const ScenarioForked(newScenarioName: 'Scenario C'))),
        );
      });
    });

    group('ScenarioRenamed', () {
      test('supports value equality', () {
        expect(
          const ScenarioRenamed(scenarioId: 's1', newName: 'Plan A'),
          equals(const ScenarioRenamed(scenarioId: 's1', newName: 'Plan A')),
        );
      });

      test('differentiates by scenarioId', () {
        expect(
          const ScenarioRenamed(scenarioId: 's1', newName: 'Plan A'),
          isNot(
            equals(const ScenarioRenamed(scenarioId: 's2', newName: 'Plan A')),
          ),
        );
      });

      test('differentiates by newName', () {
        expect(
          const ScenarioRenamed(scenarioId: 's1', newName: 'Plan A'),
          isNot(
            equals(const ScenarioRenamed(scenarioId: 's1', newName: 'Plan B')),
          ),
        );
      });
    });

    group('ScenarioDuplicated', () {
      test('supports value equality', () {
        expect(
          const ScenarioDuplicated(scenarioId: 's1'),
          equals(const ScenarioDuplicated(scenarioId: 's1')),
        );
      });

      test('differentiates by scenarioId', () {
        expect(
          const ScenarioDuplicated(scenarioId: 's1'),
          isNot(equals(const ScenarioDuplicated(scenarioId: 's2'))),
        );
      });
    });

    group('ScenarioDeleted', () {
      test('supports value equality', () {
        expect(
          const ScenarioDeleted(scenarioId: 's1'),
          equals(const ScenarioDeleted(scenarioId: 's1')),
        );
      });

      test('differentiates by scenarioId', () {
        expect(
          const ScenarioDeleted(scenarioId: 's1'),
          isNot(equals(const ScenarioDeleted(scenarioId: 's2'))),
        );
      });
    });

    group('ProjectionWindowChanged', () {
      test('supports value equality', () {
        expect(
          const ProjectionWindowChanged(months: 24),
          equals(const ProjectionWindowChanged(months: 24)),
        );
      });

      test('differentiates by months', () {
        expect(
          const ProjectionWindowChanged(months: 24),
          isNot(equals(const ProjectionWindowChanged(months: 36))),
        );
      });
    });
  });
}

