import 'package:finance_pulse/domain/entities/resilience_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResilienceScore', () {
    const tScore = ResilienceScore(scenarioId: 's1', score: 75.0);

    test('two instances with identical values are equal', () {
      const other = ResilienceScore(scenarioId: 's1', score: 75.0);
      expect(tScore, equals(other));
    });

    test('instances differing by scenarioId are not equal', () {
      const other = ResilienceScore(scenarioId: 's2', score: 75.0);
      expect(tScore, isNot(equals(other)));
    });

    test('instances differing by score are not equal', () {
      const other = ResilienceScore(scenarioId: 's1', score: 50.0);
      expect(tScore, isNot(equals(other)));
    });
  });
}
