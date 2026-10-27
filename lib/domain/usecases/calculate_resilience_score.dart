import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/error/failure.dart';
import '../../core/usecase/usecase.dart';
import '../engine/projection_engine.dart';
import '../entities/projection_node.dart';
import '../entities/resilience_score.dart';

/// Parameter bundle for executing [CalculateResilienceScore].
class CalculateResilienceScoreParams extends Equatable {
  /// The unique identifier of the scenario being evaluated.
  final String scenarioId;

  /// The sequence of monthly projection nodes output by [ProjectionEngine].
  final List<ProjectionNode> nodes;

  /// Creates parameter bundle for resilience score evaluation.
  const CalculateResilienceScoreParams({
    required this.scenarioId,
    required this.nodes,
  });

  @override
  List<Object?> get props => [scenarioId, nodes];
}

/// Clean Architecture use case that orchestrates resilience score calculation
/// for a scenario based on its projection trajectory.
///
/// Evaluates runway months until ending balance reaches zero or below and scales
/// the result against a 12-month ceiling to yield a score in [0.0, 100.0].
class CalculateResilienceScore
    extends UseCase<ResilienceScore, CalculateResilienceScoreParams> {
  final ProjectionEngine _projectionEngine;

  /// Creates a [CalculateResilienceScore] usecase.
  ///
  /// Optionally accepts a custom [ProjectionEngine] instance.
  const CalculateResilienceScore([ProjectionEngine? projectionEngine])
    : _projectionEngine = projectionEngine ?? const ProjectionEngine();

  @override
  Future<Either<Failure, ResilienceScore>> call(
    CalculateResilienceScoreParams params,
  ) async {
    final score = _projectionEngine.calculateResilienceScore(
      params.scenarioId,
      params.nodes,
    );
    return Right(score);
  }
}
