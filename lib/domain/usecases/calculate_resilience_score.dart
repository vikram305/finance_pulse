import '../engine/projection_engine.dart';
import '../entities/projection_node.dart';
import '../entities/resilience_score.dart';

class CalculateResilienceScore {
  final ProjectionEngine _projectionEngine;

  const CalculateResilienceScore([ProjectionEngine? projectionEngine])
    : _projectionEngine = projectionEngine ?? const ProjectionEngine();

  ResilienceScore call({
    required String scenarioId,
    required List<ProjectionNode> nodes,
  }) {
    return _projectionEngine.calculateResilienceScore(scenarioId, nodes);
  }
}
