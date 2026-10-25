import 'package:equatable/equatable.dart';

class ResilienceScore extends Equatable {
  final String scenarioId;
  final double score;

  const ResilienceScore({required this.scenarioId, required this.score});

  @override
  List<Object?> get props => [scenarioId, score];
}
