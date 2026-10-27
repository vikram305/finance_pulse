import 'package:equatable/equatable.dart';

/// Defines the cash flow direction for a financial event.
///
/// Inflows contribute positively to projected liquid balance, while outflows
/// deplete liquid balance across active simulation months.
enum FinancialPolarity {
  /// Cash inflow (e.g., salary, investment dividend) that increases liquid balance.
  income,

  /// Cash outflow (e.g., rent, living costs, EMIs) that decreases liquid balance.
  expense,
}

/// An immutable domain entity representing a time-bound cash flow event.
///
/// Financial events model either user-confirmed baseline blocks or auto-generated
/// Strawman estimates on the projection timeline. Polarity determines whether
/// the event contributes to income or expense calculations.
class FinancialEvent extends Equatable {
  /// Unique identifier (UUID) for this event.
  final String id;

  /// User-visible name or label describing this event block.
  final String name;

  /// Flow direction indicating whether this event adds to or subtracts from cash flow.
  final FinancialPolarity polarity;

  /// Inclusive 0-indexed month on the timeline when this event begins taking effect.
  final int startMonth;

  /// Inclusive 0-indexed month on the timeline when this event stops taking effect.
  final int endMonth;

  /// Monetary magnitude per active month. Must be non-negative.
  final double amount;

  /// Indicates whether this block has been confirmed by the user (`true`)
  /// or is an auto-generated Strawman estimate awaiting user correction (`false`).
  final bool isBaseline;

  /// Creates a [FinancialEvent] entity with immutable cash flow specifications.
  const FinancialEvent({
    required this.id,
    required this.name,
    required this.polarity,
    required this.startMonth,
    required this.endMonth,
    required this.amount,
    required this.isBaseline,
  });

  /// Returns a copy of this [FinancialEvent] with the given fields replaced with new values.
  FinancialEvent copyWith({
    String? id,
    String? name,
    FinancialPolarity? polarity,
    int? startMonth,
    int? endMonth,
    double? amount,
    bool? isBaseline,
  }) {
    return FinancialEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      polarity: polarity ?? this.polarity,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      amount: amount ?? this.amount,
      isBaseline: isBaseline ?? this.isBaseline,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    polarity,
    startMonth,
    endMonth,
    amount,
    isBaseline,
  ];
}
