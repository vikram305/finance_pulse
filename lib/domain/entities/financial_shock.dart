import 'package:equatable/equatable.dart';

import 'financial_event.dart';

class FinancialShock extends Equatable {
  final String id;
  final String label;
  final List<FinancialEvent> events;

  const FinancialShock({
    required this.id,
    required this.label,
    required this.events,
  });

  FinancialShock copyWith({
    String? id,
    String? label,
    List<FinancialEvent>? events,
  }) {
    return FinancialShock(
      id: id ?? this.id,
      label: label ?? this.label,
      events: events ?? this.events,
    );
  }

  @override
  List<Object?> get props => [id, label, events];
}
