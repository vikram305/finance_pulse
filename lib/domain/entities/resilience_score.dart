import 'package:equatable/equatable.dart';

/// Represents a scenario's calculated resilience score (0.0 to 100.0).
///
/// The score is derived by dividing the runway months (months until ending balance
/// reaches zero or below) by a 12-month target ceiling and scaling to a 0–100 range.
///
/// Note: In the presentation UI, this value MUST always be labelled
/// "Projected Resilience" (never "Resilience Score") to communicate its simulation nature.
class ResilienceScore extends Equatable {
  /// The identifier of the scenario for which this score was calculated.
  final String scenarioId;

  /// The resilience metric, clamped between 0.0 and 100.0.
  final double score;

  /// Creates a [ResilienceScore] instance.
  const ResilienceScore({required this.scenarioId, required this.score});

  @override
  List<Object?> get props => [scenarioId, score];
}
