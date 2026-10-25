import 'package:equatable/equatable.dart';

class ProjectionNode extends Equatable {
  final int monthIndex;
  final double startingBalance;
  final double netCashFlow;
  final double endingBalance;
  final List<String> activeEventIds;

  const ProjectionNode({
    required this.monthIndex,
    required this.startingBalance,
    required this.netCashFlow,
    required this.endingBalance,
    required this.activeEventIds,
  });

  @override
  List<Object?> get props => [
    monthIndex,
    startingBalance,
    netCashFlow,
    endingBalance,
    activeEventIds,
  ];
}
