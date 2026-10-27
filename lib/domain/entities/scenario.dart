import 'package:equatable/equatable.dart';

/// A named, independent container of ordered financial event IDs.
///
/// Scenarios allow users to explore and contrast competing financial futures
/// via A/B forking. Event definitions are resolved from the repository or state
/// using the ordered [eventIds] list.
class Scenario extends Equatable {
  /// Unique identifier (UUID) for this scenario.
  final String id;

  /// User-defined display name for the scenario (e.g. "Scenario A", "Buy a Car").
  final String name;

  /// Ordered sequence of [FinancialEvent] IDs contained within this scenario.
  final List<String> eventIds;

  /// Creates an immutable [Scenario] instance.
  const Scenario({
    required this.id,
    required this.name,
    this.eventIds = const [],
  });

  /// Returns a copy of this [Scenario] with the given fields replaced.
  Scenario copyWith({
    String? id,
    String? name,
    List<String>? eventIds,
  }) {
    return Scenario(
      id: id ?? this.id,
      name: name ?? this.name,
      eventIds: eventIds ?? this.eventIds,
    );
  }

  @override
  List<Object?> get props => [id, name, eventIds];
}
