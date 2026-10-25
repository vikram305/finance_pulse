import 'package:equatable/equatable.dart';

import 'financial_event.dart';

class Scenario extends Equatable {
  final String id;
  final String name;
  final List<String> eventIds;
  final List<FinancialEvent> events;

  const Scenario({
    required this.id,
    required this.name,
    this.eventIds = const [],
    this.events = const [],
  });

  Scenario copyWith({
    String? id,
    String? name,
    List<String>? eventIds,
    List<FinancialEvent>? events,
  }) {
    return Scenario(
      id: id ?? this.id,
      name: name ?? this.name,
      eventIds: eventIds ?? this.eventIds,
      events: events ?? this.events,
    );
  }

  @override
  List<Object?> get props => [id, name, eventIds, events];
}
