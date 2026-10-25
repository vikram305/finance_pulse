import 'package:finance_pulse/domain/entities/projection_node.dart';
import 'package:finance_pulse/domain/usecases/calculate_resilience_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculateResilienceScore useCase;

  setUp(() {
    useCase = const CalculateResilienceScore();
  });

  group('CalculateResilienceScore UseCase', () {
    test(
      'scenario where balance goes negative at month 3 -> runway = 3 -> score = 25.0',
      () {
        final nodes = List.generate(
          12,
          (i) => ProjectionNode(
            monthIndex: i,
            startingBalance: 100,
            netCashFlow: -25,
            endingBalance: i < 3 ? 100.0 - (25.0 * i) : -10.0,
            activeEventIds: const [],
          ),
        );

        final result = useCase(scenarioId: 's1', nodes: nodes);
        expect(result.scenarioId, equals('s1'));
        expect(result.score, equals(25.0));
      },
    );

    test(
      'scenario where balance stays positive for all 12 months -> runway = 12 -> score = 100.0',
      () {
        final nodes = List.generate(
          12,
          (i) => ProjectionNode(
            monthIndex: i,
            startingBalance: 1000,
            netCashFlow: 100,
            endingBalance: 1000.0 + (100.0 * (i + 1)),
            activeEventIds: const [],
          ),
        );

        final result = useCase(scenarioId: 's1', nodes: nodes);
        expect(result.score, equals(100.0));
      },
    );

    test(
      'scenario where balance stays positive for 24 months -> runway = 12 (capped) -> score = 100.0',
      () {
        final nodes = List.generate(
          24,
          (i) => ProjectionNode(
            monthIndex: i,
            startingBalance: 1000,
            netCashFlow: 100,
            endingBalance: 1000.0 + (100.0 * (i + 1)),
            activeEventIds: const [],
          ),
        );

        final result = useCase(scenarioId: 's1', nodes: nodes);
        expect(result.score, equals(100.0));
      },
    );

    test('scenario with runway = 6 months -> score = 50.0', () {
      final nodes = List.generate(
        12,
        (i) => ProjectionNode(
          monthIndex: i,
          startingBalance: 100,
          netCashFlow: -20,
          endingBalance: i < 6 ? 100.0 - (15.0 * (i + 1)) : 0.0,
          activeEventIds: const [],
        ),
      );

      final result = useCase(scenarioId: 's1', nodes: nodes);
      expect(result.score, equals(50.0));
    });

    test('scenario with runway = 0 (negative from month 0) -> score = 0.0', () {
      final nodes = List.generate(
        12,
        (i) => ProjectionNode(
          monthIndex: i,
          startingBalance: 0,
          netCashFlow: -100,
          endingBalance: -100.0 * (i + 1),
          activeEventIds: const [],
        ),
      );

      final result = useCase(scenarioId: 's1', nodes: nodes);
      expect(result.score, equals(0.0));
    });

    test('empty nodes list -> runway = 0 -> score = 0.0', () {
      final result = useCase(scenarioId: 's1', nodes: const []);
      expect(result.score, equals(0.0));
    });
  });
}
