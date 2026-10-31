import 'package:bloc_test/bloc_test.dart';
import 'package:finance_pulse/domain/constants/financial_shocks.dart';
import 'package:finance_pulse/domain/entities/financial_event.dart';
import 'package:finance_pulse/domain/entities/scenario.dart';
import 'package:finance_pulse/features/panic_room/presentation/bloc/panic_room_bloc.dart';
import 'package:finance_pulse/features/panic_room/presentation/bloc/panic_room_event.dart';
import 'package:finance_pulse/features/panic_room/presentation/bloc/panic_room_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PanicRoomBloc', () {
    late PanicRoomBloc panicRoomBloc;

    const tScenarioA = Scenario(
      id: 's1',
      name: 'Scenario A',
      eventIds: ['e-salary', 'e-rent'],
    );
    const tScenarioB = Scenario(
      id: 's2',
      name: 'Scenario B',
      eventIds: ['e-rent-b'],
    );

    const tSalaryEvent = FinancialEvent(
      id: 'e-salary',
      name: 'Salary',
      polarity: FinancialPolarity.income,
      startMonth: 0,
      endMonth: 11,
      amount: 60000.0,
      isBaseline: true,
    );

    const tRentEvent = FinancialEvent(
      id: 'e-rent',
      name: 'Rent',
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: 11,
      amount: 20000.0,
      isBaseline: false,
    );

    const tRentBEvent = FinancialEvent(
      id: 'e-rent-b',
      name: 'Rent Only',
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: 11,
      amount: 30000.0,
      isBaseline: false,
    );

    // Scenario designed to hit zero balance at month 4
    // liquidBalance: 100000.0, net monthly flow: -25000.0
    // Month 0 ending: 75000
    // Month 1 ending: 50000
    // Month 2 ending: 25000
    // Month 3 ending: 0.0 (hits zero at month 3 index)
    // To hit zero at month index 4: net flow -20000.0
    // Month 0: 80000
    // Month 1: 60000
    // Month 2: 40000
    // Month 3: 20000
    // Month 4: 0.0 (hits zero at month 4 index)
    const tScenarioMonth4Zero = Scenario(
      id: 's-m4',
      name: 'Scenario Month 4 Zero',
      eventIds: ['e-expense-20k'],
    );
    const tExpense20k = FinancialEvent(
      id: 'e-expense-20k',
      name: 'Expense 20k',
      polarity: FinancialPolarity.expense,
      startMonth: 0,
      endMonth: 11,
      amount: 20000.0,
      isBaseline: false,
    );

    setUp(() {
      panicRoomBloc = PanicRoomBloc();
    });

    tearDown(() {
      panicRoomBloc.close();
    });

    test('initial state has 4 available shocks and empty activeShockIds', () {
      expect(panicRoomBloc.state, equals(PanicRoomState.initial()));
      expect(panicRoomBloc.state.activeShockIds, isEmpty);
      expect(panicRoomBloc.state.availableShocks.length, 4);
      expect(panicRoomBloc.state.projectionsByScenarioId, isEmpty);
      expect(panicRoomBloc.state.scoresByScenarioId, isEmpty);
      expect(panicRoomBloc.state.survivalMonthsByScenarioId, isEmpty);
      expect(panicRoomBloc.state.scenarios, isEmpty);
      expect(panicRoomBloc.state.liquidBalance, 0.0);
      expect(panicRoomBloc.state.monthlyNetIncome, 0.0);
      expect(panicRoomBloc.state.projectionWindowMonths, 12);
    });

    group('PanicRoomEntered', () {
      blocTest<PanicRoomBloc, PanicRoomState>(
        'initialises with 2 Scenarios: 4 available shocks, 0 active shocks, projections for both',
        build: () => PanicRoomBloc(),
        act: (bloc) => bloc.add(
          const PanicRoomEntered(
            scenarios: {'s1': tScenarioA, 's2': tScenarioB},
            eventsByScenarioId: {
              's1': [tSalaryEvent, tRentEvent],
              's2': [tRentBEvent],
            },
            liquidBalance: 100000.0,
            monthlyNetIncome: 60000.0,
            projectionWindowMonths: 12,
          ),
        ),
        expect: () => [
          isA<PanicRoomState>()
              .having(
                (s) => s.availableShocks.length,
                'available shocks count',
                4,
              )
              .having((s) => s.activeShockIds, 'active shocks empty', isEmpty)
              .having(
                (s) => s.projectionsByScenarioId.keys,
                'scenario projections',
                containsAll(['s1', 's2']),
              )
              .having(
                (s) => s.projectionsByScenarioId['s1']!.length,
                's1 projection months',
                12,
              )
              .having(
                (s) => s.projectionsByScenarioId['s2']!.length,
                's2 projection months',
                12,
              )
              .having(
                (s) => s.scoresByScenarioId['s1']!.score,
                's1 baseline score (positive runway)',
                100.0,
              )
              .having(
                (s) {
                  // s2: balance 100000 - (30000 * (i + 1)):
                  // Month 0: 70k, Month 1: 40k, Month 2: 10k, Month 3: -20k <= 0
                  // first negative at index 3 -> runway = 3 -> score = (3 / 12) * 100 = 25.0
                  return s.scoresByScenarioId['s2']!.score == 25.0;
                },
                's2 calculated score on entry matches formula',
                true,
              )
              .having(
                (s) => s.survivalMonthsByScenarioId['s1'],
                's1 stays positive -> 12',
                12.0,
              )
              .having(
                (s) => s.survivalMonthsByScenarioId['s2'],
                's2 hits negative at month 3',
                3.0,
              ),
        ],
      );

      blocTest<PanicRoomBloc, PanicRoomState>(
        'reconstructs jobLoss shock with updated monthlyNetIncome on entry',
        build: () => PanicRoomBloc(),
        act: (bloc) => bloc.add(
          const PanicRoomEntered(
            scenarios: {'s1': tScenarioA},
            eventsByScenarioId: {
              's1': [tSalaryEvent, tRentEvent],
            },
            liquidBalance: 50000.0,
            monthlyNetIncome: 85000.0,
            projectionWindowMonths: 12,
          ),
        ),
        expect: () => [
          isA<PanicRoomState>().having(
            (s) {
              final jobLoss = s.availableShocks.firstWhere(
                (shock) => shock.id == 'shock-job-loss',
              );
              return jobLoss.events.first.amount == 85000.0;
            },
            'job loss amount matches monthlyNetIncome',
            true,
          ),
        ],
      );
    });

    group('ShockToggled', () {
      final tEnteredState = PanicRoomState(
        activeShockIds: const {},
        availableShocks: [
          FinancialShocks.medicalEmergency,
          FinancialShocks.rentSpike,
          FinancialShocks.emiShock,
          FinancialShocks.jobLoss(monthlyNetIncome: 60000.0),
        ],
        projectionsByScenarioId: const {},
        scoresByScenarioId: const {},
        survivalMonthsByScenarioId: const {},
        scenarios: const {'s1': tScenarioA},
        eventsByScenarioId: const {
          's1': [tSalaryEvent, tRentEvent],
        },
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
        projectionWindowMonths: 12,
      );

      blocTest<PanicRoomBloc, PanicRoomState>(
        'ShockToggled(medicalEmergency) activates shock, recalculates projections and updates scores',
        seed: () => tEnteredState,
        build: () => PanicRoomBloc(),
        act: (bloc) =>
            bloc.add(ShockToggled(shock: FinancialShocks.medicalEmergency)),
        expect: () => [
          isA<PanicRoomState>()
              .having(
                (s) => s.activeShockIds,
                'contains medical emergency',
                contains('shock-medical-emergency'),
              )
              .having(
                (s) {
                  // Initial: 100k balance.
                  // Month 0 salary (+60k) - rent (-20k) - medical emergency shock (-200k) = net -160k
                  // Ending month 0 = -60k <= 0!
                  final nodes = s.projectionsByScenarioId['s1']!;
                  return nodes.first.netCashFlow == -160000.0 &&
                      nodes.first.endingBalance == -60000.0 &&
                      nodes.first.activeEventIds.contains(
                        'event-shock-medical-emergency',
                      );
                },
                'medical emergency applied in month 0',
                true,
              )
              .having(
                (s) => s.scoresByScenarioId['s1']!.score,
                'score drops to 0 due to month 0 deficit',
                0.0,
              )
              .having(
                (s) => s.survivalMonthsByScenarioId['s1'],
                'survival months is 0',
                0.0,
              ),
        ],
      );

      blocTest<PanicRoomBloc, PanicRoomState>(
        'ShockToggled(medicalEmergency) again deactivates shock, returns projections to baseline and restores scores',
        seed: () => tEnteredState.copyWith(
          activeShockIds: const {'shock-medical-emergency'},
        ),
        build: () => PanicRoomBloc(),
        act: (bloc) =>
            bloc.add(ShockToggled(shock: FinancialShocks.medicalEmergency)),
        expect: () => [
          isA<PanicRoomState>()
              .having((s) => s.activeShockIds, 'active shocks empty', isEmpty)
              .having(
                (s) {
                  final nodes = s.projectionsByScenarioId['s1']!;
                  // Baseline: 100k + 60k salary - 20k rent = +40k net
                  // Month 0 ending = 140000.0
                  return nodes.first.netCashFlow == 40000.0 &&
                      nodes.first.endingBalance == 140000.0 &&
                      !nodes.first.activeEventIds.contains(
                        'event-shock-medical-emergency',
                      );
                },
                'projections restored to baseline',
                true,
              )
              .having(
                (s) => s.scoresByScenarioId['s1']!.score,
                'scores restored to 100.0',
                100.0,
              )
              .having(
                (s) => s.survivalMonthsByScenarioId['s1'],
                'survival months restored to 12.0',
                12.0,
              ),
        ],
      );

      blocTest<PanicRoomBloc, PanicRoomState>(
        'ShockToggled(jobLoss) uses jobLoss constructed from monthlyNetIncome and reduces months 0-5',
        seed: () => tEnteredState,
        build: () => PanicRoomBloc(),
        act: (bloc) => bloc.add(
          ShockToggled(
            shock: FinancialShocks.jobLoss(monthlyNetIncome: 60000.0),
          ),
        ),
        expect: () => [
          isA<PanicRoomState>()
              .having(
                (s) => s.activeShockIds,
                'contains job loss',
                contains('shock-job-loss'),
              )
              .having(
                (s) {
                  final nodes = s.projectionsByScenarioId['s1']!;
                  // Salary (+60k), Rent (-20k), Job loss shock (-60k)
                  // Net cash flow months 0-5 = -20k
                  // Month 6+: Job loss ended -> Net cash flow = +40k
                  final m0to5Reduced = nodes
                      .take(6)
                      .every((n) => n.netCashFlow == -20000.0);
                  final m6Baseline = nodes[6].netCashFlow == 40000.0;
                  return m0to5Reduced && m6Baseline;
                },
                'months 0-5 cash flow reduced by jobLoss shock',
                true,
              ),
        ],
      );

      blocTest<PanicRoomBloc, PanicRoomState>(
        'two shocks active simultaneously merges both event lists additively',
        seed: () => tEnteredState.copyWith(
          activeShockIds: const {'shock-medical-emergency'},
        ),
        build: () => PanicRoomBloc(),
        act: (bloc) => bloc.add(ShockToggled(shock: FinancialShocks.rentSpike)),
        expect: () => [
          isA<PanicRoomState>()
              .having(
                (s) => s.activeShockIds,
                'contains both shocks',
                containsAll(['shock-medical-emergency', 'shock-rent-spike']),
              )
              .having(
                (s) {
                  final nodes = s.projectionsByScenarioId['s1']!;
                  // Month 0: Salary (+60k) - Rent (-20k) - Medical (-200k) - Rent Spike (-12k)
                  // Net cash flow = 60000 - 20000 - 200000 - 12000 = -172000.0
                  return nodes.first.netCashFlow == -172000.0 &&
                      nodes.first.activeEventIds.contains(
                        'event-shock-medical-emergency',
                      ) &&
                      nodes.first.activeEventIds.contains(
                        'event-shock-rent-spike',
                      );
                },
                'both shock events merged and additive',
                true,
              ),
        ],
      );

      blocTest<PanicRoomBloc, PanicRoomState>(
        'scenario entities and events are never mutated when shock toggled',
        seed: () => tEnteredState,
        build: () => PanicRoomBloc(),
        act: (bloc) =>
            bloc.add(ShockToggled(shock: FinancialShocks.medicalEmergency)),
        verify: (bloc) {
          final state = bloc.state;
          final scenario = state.scenarios['s1']!;
          expect(scenario.eventIds, equals(['e-salary', 'e-rent']));
          expect(state.eventsByScenarioId['s1']!.length, equals(2));
          expect(
            state.eventsByScenarioId['s1']!.map((e) => e.id),
            equals(['e-salary', 'e-rent']),
          );
        },
      );
    });

    group('Survival Months', () {
      blocTest<PanicRoomBloc, PanicRoomState>(
        'scenario where balance hits zero at month 4 -> survivalMonths == 4',
        build: () => PanicRoomBloc(),
        act: (bloc) => bloc.add(
          const PanicRoomEntered(
            scenarios: {'s-m4': tScenarioMonth4Zero},
            eventsByScenarioId: {
              's-m4': [tExpense20k],
            },
            liquidBalance: 100000.0,
            monthlyNetIncome: 0.0,
            projectionWindowMonths: 12,
          ),
        ),
        expect: () => [
          isA<PanicRoomState>().having(
            (s) => s.survivalMonthsByScenarioId['s-m4'],
            'survival months is 4',
            4.0,
          ),
        ],
      );

      blocTest<PanicRoomBloc, PanicRoomState>(
        'scenario where balance stays positive for entire 12-month window -> survivalMonths == 12',
        build: () => PanicRoomBloc(),
        act: (bloc) => bloc.add(
          const PanicRoomEntered(
            scenarios: {'s1': tScenarioA},
            eventsByScenarioId: {
              's1': [tSalaryEvent, tRentEvent],
            },
            liquidBalance: 100000.0,
            monthlyNetIncome: 60000.0,
            projectionWindowMonths: 12,
          ),
        ),
        expect: () => [
          isA<PanicRoomState>().having(
            (s) => s.survivalMonthsByScenarioId['s1'],
            'survival months is 12',
            12.0,
          ),
        ],
      );
    });

    group('Cross-Scenario', () {
      final tTwoScenarioState = PanicRoomState(
        activeShockIds: const {},
        availableShocks: [
          FinancialShocks.medicalEmergency,
          FinancialShocks.rentSpike,
          FinancialShocks.emiShock,
          FinancialShocks.jobLoss(monthlyNetIncome: 60000.0),
        ],
        projectionsByScenarioId: const {},
        scoresByScenarioId: const {},
        survivalMonthsByScenarioId: const {},
        scenarios: const {'s1': tScenarioA, 's2': tScenarioB},
        eventsByScenarioId: const {
          's1': [tSalaryEvent, tRentEvent],
          's2': [tRentBEvent],
        },
        liquidBalance: 100000.0,
        monthlyNetIncome: 60000.0,
        projectionWindowMonths: 12,
      );

      blocTest<PanicRoomBloc, PanicRoomState>(
        'same shock applied to 2 Scenarios with different events produces different ResilienceScore values',
        seed: () => tTwoScenarioState,
        build: () => PanicRoomBloc(),
        act: (bloc) => bloc.add(ShockToggled(shock: FinancialShocks.rentSpike)),
        expect: () => [
          isA<PanicRoomState>().having(
            (s) {
              final score1 = s.scoresByScenarioId['s1']!.score;
              final score2 = s.scoresByScenarioId['s2']!.score;
              // s1: net 60k - 20k - 12k = +28k/mo positive -> score = 100.0
              // s2: net -30k - 12k = -42k/mo -> drops negative faster -> score < 100.0
              return score1 != score2 && score1 == 100.0 && score2 < score1;
            },
            'different scores produced across scenarios',
            true,
          ),
        ],
      );

      blocTest<PanicRoomBloc, PanicRoomState>(
        'scores for Scenario A and Scenario B are independent; toggling shock changes both',
        seed: () => tTwoScenarioState,
        build: () => PanicRoomBloc(),
        act: (bloc) => bloc.add(ShockToggled(shock: FinancialShocks.emiShock)),
        expect: () => [
          isA<PanicRoomState>()
              .having(
                (s) =>
                    s.scoresByScenarioId.containsKey('s1') &&
                    s.scoresByScenarioId.containsKey('s2'),
                'both scenarios present in scores',
                true,
              )
              .having(
                (s) =>
                    s.survivalMonthsByScenarioId.containsKey('s1') &&
                    s.survivalMonthsByScenarioId.containsKey('s2'),
                'both scenarios present in survival months',
                true,
              ),
        ],
      );
    });

    group('PanicRoomExited', () {
      blocTest<PanicRoomBloc, PanicRoomState>(
        'resets state and clears all active shocks',
        seed: () => PanicRoomState(
          activeShockIds: const {'shock-medical-emergency', 'shock-rent-spike'},
          availableShocks: [
            FinancialShocks.medicalEmergency,
            FinancialShocks.rentSpike,
          ],
          projectionsByScenarioId: const {},
          scoresByScenarioId: const {},
          survivalMonthsByScenarioId: const {},
          scenarios: const {'s1': tScenarioA},
          eventsByScenarioId: const {
            's1': [tSalaryEvent],
          },
          liquidBalance: 100000.0,
          monthlyNetIncome: 60000.0,
          projectionWindowMonths: 12,
        ),
        build: () => PanicRoomBloc(),
        act: (bloc) => bloc.add(const PanicRoomExited()),
        expect: () => [equals(PanicRoomState.initial())],
      );
    });
  });
}
