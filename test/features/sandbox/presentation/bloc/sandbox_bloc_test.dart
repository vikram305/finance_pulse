import 'package:bloc_test/bloc_test.dart';
import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:finance_pulse/domain/entities/scenario.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_bloc.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_event.dart';
import 'package:finance_pulse/features/sandbox/presentation/bloc/sandbox_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SandboxBloc', () {
    late SandboxBloc sandboxBloc;

    setUp(() {
      sandboxBloc = SandboxBloc();
    });

    tearDown(() {
      sandboxBloc.close();
    });

    test('initial state has empty scenarios and default projection window', () {
      expect(sandboxBloc.state, const SandboxState.initial());
      expect(sandboxBloc.state.scenarios, isEmpty);
      expect(sandboxBloc.state.eventsByScenarioId, isEmpty);
      expect(sandboxBloc.state.projectionsByScenarioId, isEmpty);
      expect(sandboxBloc.state.projectionWindowMonths, 12);
      expect(sandboxBloc.state.liquidBalance, 0.0);
      expect(sandboxBloc.state.monthlyNetIncome, 0.0);
    });

    group('SandboxInitialized', () {
      blocTest<SandboxBloc, SandboxState>(
        'emits state with 1 Scenario, 3 Strawman events, and 12-month projections',
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const SandboxInitialized(
            liquidBalance: 100000,
            monthlyNetIncome: 60000,
          ),
        ),
        expect: () => [
          isA<SandboxState>()
              .having((s) => s.scenarios.length, 'scenarios count', 1)
              .having((s) => s.liquidBalance, 'liquidBalance', 100000.0)
              .having((s) => s.monthlyNetIncome, 'monthlyNetIncome', 60000.0)
              .having((s) => s.projectionWindowMonths, 'projectionWindowMonths', 12)
              .having((s) {
                final scenario = s.scenarios.values.first;
                return scenario.name;
              }, 'scenario name', 'Scenario A')
              .having((s) {
                final scenario = s.scenarios.values.first;
                final events = s.eventsByScenarioId[scenario.id]!;
                return events.length;
              }, 'events count', 3)
              .having((s) {
                final scenario = s.scenarios.values.first;
                final events = s.eventsByScenarioId[scenario.id]!;
                final rent = events.firstWhere((e) => e.name == 'Rent');
                return rent.amount == 30000.0 &&
                    rent.polarity == FinancialPolarity.expense &&
                    rent.startMonth == 0 &&
                    rent.endMonth == 35 &&
                    rent.isBaseline == false;
              }, 'rent event validity', true)
              .having((s) {
                final scenario = s.scenarios.values.first;
                final events = s.eventsByScenarioId[scenario.id]!;
                final living = events.firstWhere((e) => e.name == 'Living Costs');
                return living.amount == 18000.0 &&
                    living.polarity == FinancialPolarity.expense &&
                    living.startMonth == 0 &&
                    living.endMonth == 35 &&
                    living.isBaseline == false;
              }, 'living costs event validity', true)
              .having((s) {
                final scenario = s.scenarios.values.first;
                final events = s.eventsByScenarioId[scenario.id]!;
                final emi = events.firstWhere((e) => e.name == 'EMI');
                return emi.amount == 12000.0 &&
                    emi.polarity == FinancialPolarity.expense &&
                    emi.startMonth == 0 &&
                    emi.endMonth == 35 &&
                    emi.isBaseline == false;
              }, 'emi event validity', true)
              .having((s) {
                final scenario = s.scenarios.values.first;
                final nodes = s.projectionsByScenarioId[scenario.id]!;
                return nodes.length == 12 &&
                    nodes.first.monthIndex == 0 &&
                    nodes.first.startingBalance == 100000.0 &&
                    nodes.first.netCashFlow == -60000.0 &&
                    nodes.first.endingBalance == 40000.0;
              }, 'projections validity', true),
        ],
      );
    });

    group('Event CRUD', () {
      const tScenarioId = 'scenario-1';
      const tRentEvent = FinancialEvent(
        id: 'event-rent',
        name: 'Rent',
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 35,
        amount: 30000.0,
        isBaseline: false,
      );
      const tScenario = Scenario(
        id: tScenarioId,
        name: 'Scenario A',
        eventIds: ['event-rent'],
      );
      final tInitialState = SandboxState(
        scenarios: const {tScenarioId: tScenario},
        eventsByScenarioId: const {
          tScenarioId: [tRentEvent],
        },
        projectionsByScenarioId: const {},
        projectionWindowMonths: 12,
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
      );

      const tBonusEvent = FinancialEvent(
        id: 'event-bonus',
        name: 'Bonus',
        polarity: FinancialPolarity.income,
        startMonth: 2,
        endMonth: 2,
        amount: 20000.0,
        isBaseline: true,
      );

      blocTest<SandboxBloc, SandboxState>(
        'FinancialEventAdded adds event to scenario and recalculates projections',
        seed: () => tInitialState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const FinancialEventAdded(
            scenarioId: tScenarioId,
            event: tBonusEvent,
          ),
        ),
        expect: () => [
          isA<SandboxState>()
              .having(
                (s) => s.eventsByScenarioId[tScenarioId]?.length,
                'events count',
                2,
              )
              .having(
                (s) => s.scenarios[tScenarioId]?.eventIds,
                'scenario eventIds',
                ['event-rent', 'event-bonus'],
              )
              .having(
                (s) => s.eventsByScenarioId[tScenarioId]?.last,
                'added event',
                tBonusEvent,
              )
              .having(
                (s) => s.projectionsByScenarioId[tScenarioId]?[2].netCashFlow,
                'month 2 netCashFlow reflects bonus (+20000 - 30000 = -10000)',
                -10000.0,
              ),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'FinancialEventUpdated replaces event with same id and recalculates projections',
        seed: () => tInitialState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const FinancialEventUpdated(
            scenarioId: tScenarioId,
            event: FinancialEvent(
              id: 'event-rent',
              name: 'Rent Discounted',
              polarity: FinancialPolarity.expense,
              startMonth: 0,
              endMonth: 35,
              amount: 25000.0,
              isBaseline: true,
            ),
          ),
        ),
        expect: () => [
          isA<SandboxState>()
              .having(
                (s) => s.eventsByScenarioId[tScenarioId]?.length,
                'events count',
                1,
              )
              .having(
                (s) => s.eventsByScenarioId[tScenarioId]?.first.name,
                'updated name',
                'Rent Discounted',
              )
              .having(
                (s) => s.eventsByScenarioId[tScenarioId]?.first.amount,
                'updated amount',
                25000.0,
              )
              .having(
                (s) => s.projectionsByScenarioId[tScenarioId]?[0].netCashFlow,
                'month 0 netCashFlow updated',
                -25000.0,
              ),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'FinancialEventDeleted removes event and recalculates projections',
        seed: () => tInitialState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const FinancialEventDeleted(
            scenarioId: tScenarioId,
            eventId: 'event-rent',
          ),
        ),
        expect: () => [
          isA<SandboxState>()
              .having(
                (s) => s.eventsByScenarioId[tScenarioId]?.isEmpty,
                'events empty',
                true,
              )
              .having(
                (s) => s.scenarios[tScenarioId]?.eventIds.isEmpty,
                'scenario eventIds empty',
                true,
              )
              .having(
                (s) => s.projectionsByScenarioId[tScenarioId]?[0].netCashFlow,
                'month 0 netCashFlow is 0 after deleting expense',
                0.0,
              ),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'FinancialEventStartMonthChanged updates startMonth only and recalculates projections',
        seed: () => tInitialState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const FinancialEventStartMonthChanged(
            scenarioId: tScenarioId,
            eventId: 'event-rent',
            newStartMonth: 3,
          ),
        ),
        expect: () => [
          isA<SandboxState>()
              .having(
                (s) => s.eventsByScenarioId[tScenarioId]?.first.startMonth,
                'updated startMonth',
                3,
              )
              .having(
                (s) => s.eventsByScenarioId[tScenarioId]?.first.endMonth,
                'endMonth unchanged',
                35,
              )
              .having(
                (s) => s.eventsByScenarioId[tScenarioId]?.first.amount,
                'amount unchanged',
                30000.0,
              )
              .having(
                (s) => s.projectionsByScenarioId[tScenarioId]?[0].netCashFlow,
                'month 0 netCashFlow is 0 before rent starts',
                0.0,
              )
              .having(
                (s) => s.projectionsByScenarioId[tScenarioId]?[3].netCashFlow,
                'month 3 netCashFlow reflects rent start',
                -30000.0,
              ),
        ],
      );
    });

    group('Scenario operations', () {
      const tScenarioAId = 'scenario-a';
      const tScenarioBId = 'scenario-b';

      const tRentEvent = FinancialEvent(
        id: 'event-rent',
        name: 'Rent',
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 35,
        amount: 30000.0,
        isBaseline: false,
      );

      const tScenarioA = Scenario(
        id: tScenarioAId,
        name: 'Scenario A',
        eventIds: ['event-rent'],
      );

      const tScenarioB = Scenario(
        id: tScenarioBId,
        name: 'Scenario B',
        eventIds: [],
      );

      final tSingleScenarioState = SandboxState(
        scenarios: const {tScenarioAId: tScenarioA},
        eventsByScenarioId: const {
          tScenarioAId: [tRentEvent],
        },
        projectionsByScenarioId: const {},
        projectionWindowMonths: 12,
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
      );

      final tTwoScenariosState = SandboxState(
        scenarios: const {
          tScenarioAId: tScenarioA,
          tScenarioBId: tScenarioB,
        },
        eventsByScenarioId: const {
          tScenarioAId: [tRentEvent],
          tScenarioBId: [],
        },
        projectionsByScenarioId: const {},
        projectionWindowMonths: 12,
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
      );

      blocTest<SandboxBloc, SandboxState>(
        'ScenarioForked with 1 active Scenario creates 2nd scenario with unique UUID and projections for both',
        seed: () => tSingleScenarioState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ScenarioForked(newScenarioName: 'Scenario B'),
        ),
        expect: () => [
          isA<SandboxState>()
              .having((s) => s.scenarios.length, 'scenarios count', 2)
              .having((s) => s.scenarios.containsKey(tScenarioAId), 'retains Scenario A', true)
              .having((s) {
                final forkedScenario = s.scenarios.values.firstWhere((sc) => sc.id != tScenarioAId);
                return forkedScenario.name == 'Scenario B' &&
                    forkedScenario.id.isNotEmpty &&
                    forkedScenario.id != tScenarioAId;
              }, 'forked scenario name and unique id', true)
              .having((s) => s.projectionsByScenarioId.length, 'projections cover both scenarios', 2),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'ScenarioForked with 2 active Scenarios leaves state unchanged',
        seed: () => tTwoScenariosState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ScenarioForked(newScenarioName: 'Scenario C'),
        ),
        expect: () => [],
      );

      blocTest<SandboxBloc, SandboxState>(
        'ScenarioRenamed updates Scenario name while preserving other fields',
        seed: () => tSingleScenarioState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ScenarioRenamed(
            scenarioId: tScenarioAId,
            newName: 'Conservative Plan',
          ),
        ),
        expect: () => [
          isA<SandboxState>()
              .having((s) => s.scenarios[tScenarioAId]?.name, 'renamed scenario', 'Conservative Plan')
              .having((s) => s.scenarios[tScenarioAId]?.id, 'id unchanged', tScenarioAId)
              .having((s) => s.eventsByScenarioId[tScenarioAId]?.length, 'events unchanged', 1),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'ScenarioDuplicated produces deep copy with new UUIDs and copy suffix',
        seed: () => tSingleScenarioState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ScenarioDuplicated(scenarioId: tScenarioAId),
        ),
        expect: () => [
          isA<SandboxState>()
              .having((s) => s.scenarios.length, 'scenarios count', 2)
              .having((s) {
                final clonedScenario = s.scenarios.values.firstWhere((sc) => sc.id != tScenarioAId);
                final clonedEvents = s.eventsByScenarioId[clonedScenario.id]!;
                final clonedRent = clonedEvents.first;
                return clonedScenario.name == 'Scenario A (Copy)' &&
                    clonedScenario.id != tScenarioAId &&
                    clonedRent.id != tRentEvent.id &&
                    clonedRent.name == tRentEvent.name &&
                    clonedRent.amount == tRentEvent.amount;
              }, 'deep copy with new UUIDs and copy suffix', true)
              .having((s) => s.projectionsByScenarioId.length, 'projections cover both', 2),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'editing cloned event does not corrupt original Scenario events',
        seed: () {
          const clonedScenarioId = 'scenario-copy';
          const clonedRentEvent = FinancialEvent(
            id: 'cloned-rent',
            name: 'Rent',
            polarity: FinancialPolarity.expense,
            startMonth: 0,
            endMonth: 35,
            amount: 30000.0,
            isBaseline: false,
          );
          return SandboxState(
            scenarios: const {
              tScenarioAId: tScenarioA,
              clonedScenarioId: Scenario(
                id: clonedScenarioId,
                name: 'Scenario A (Copy)',
                eventIds: ['cloned-rent'],
              ),
            },
            eventsByScenarioId: const {
              tScenarioAId: [tRentEvent],
              clonedScenarioId: [clonedRentEvent],
            },
            projectionsByScenarioId: const {},
            projectionWindowMonths: 12,
            liquidBalance: 100000.0,
            monthlyNetIncome: 60000.0,
          );
        },
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const FinancialEventUpdated(
            scenarioId: 'scenario-copy',
            event: FinancialEvent(
              id: 'cloned-rent',
              name: 'Rent Modified',
              polarity: FinancialPolarity.expense,
              startMonth: 0,
              endMonth: 35,
              amount: 50000.0,
              isBaseline: false,
            ),
          ),
        ),
        expect: () => [
          isA<SandboxState>()
              .having(
                (s) => s.eventsByScenarioId[tScenarioAId]?.first.amount,
                'original Scenario A event amount remains unchanged',
                30000.0,
              )
              .having(
                (s) => s.eventsByScenarioId['scenario-copy']?.first.amount,
                'cloned event updated in copy',
                50000.0,
              ),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'ScenarioDuplicated with 2 active Scenarios leaves state unchanged',
        seed: () => tTwoScenariosState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ScenarioDuplicated(scenarioId: tScenarioAId),
        ),
        expect: () => [],
      );

      blocTest<SandboxBloc, SandboxState>(
        'ScenarioDeleted with 2 Scenarios leaves 1 Scenario',
        seed: () => tTwoScenariosState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ScenarioDeleted(scenarioId: tScenarioBId),
        ),
        expect: () => [
          isA<SandboxState>()
              .having((s) => s.scenarios.length, 'scenarios count', 1)
              .having((s) => s.scenarios.containsKey(tScenarioAId), 'Scenario A remains', true)
              .having((s) => s.scenarios.containsKey(tScenarioBId), 'Scenario B removed', false)
              .having((s) => s.projectionsByScenarioId.containsKey(tScenarioBId), 'Scenario B projections removed', false),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'ScenarioDeleted with 1 Scenario leaves state unchanged',
        seed: () => tSingleScenarioState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ScenarioDeleted(scenarioId: tScenarioAId),
        ),
        expect: () => [],
      );
    });

    group('Projection Window', () {
      const tScenarioId = 'scenario-1';
      const tRentEvent = FinancialEvent(
        id: 'event-rent',
        name: 'Rent',
        polarity: FinancialPolarity.expense,
        startMonth: 0,
        endMonth: 35,
        amount: 30000.0,
        isBaseline: false,
      );
      const tScenario = Scenario(
        id: tScenarioId,
        name: 'Scenario A',
        eventIds: ['event-rent'],
      );
      final tInitialState = SandboxState(
        scenarios: const {tScenarioId: tScenario},
        eventsByScenarioId: const {
          tScenarioId: [tRentEvent],
        },
        projectionsByScenarioId: const {},
        projectionWindowMonths: 12,
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
      );

      blocTest<SandboxBloc, SandboxState>(
        'ProjectionWindowChanged(months: 24) recalculates projections to 24 nodes',
        seed: () => tInitialState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ProjectionWindowChanged(months: 24),
        ),
        expect: () => [
          isA<SandboxState>()
              .having((s) => s.projectionWindowMonths, 'projectionWindowMonths', 24)
              .having(
                (s) => s.projectionsByScenarioId[tScenarioId]?.length,
                'projections length is 24',
                24,
              ),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'ProjectionWindowChanged(months: 36) recalculates projections to 36 nodes',
        seed: () => tInitialState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ProjectionWindowChanged(months: 36),
        ),
        expect: () => [
          isA<SandboxState>()
              .having((s) => s.projectionWindowMonths, 'projectionWindowMonths', 36)
              .having(
                (s) => s.projectionsByScenarioId[tScenarioId]?.length,
                'projections length is 36',
                36,
              ),
        ],
      );

      blocTest<SandboxBloc, SandboxState>(
        'ProjectionWindowChanged(months: 99) leaves state unchanged for invalid window',
        seed: () => tInitialState,
        build: () => SandboxBloc(),
        act: (bloc) => bloc.add(
          const ProjectionWindowChanged(months: 99),
        ),
        expect: () => [],
      );
    });
  });
}
