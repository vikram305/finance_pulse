import 'package:equatable/equatable.dart';

enum FinancialPolarity { income, expense }

class FinancialEvent extends Equatable {
  final String id;
  final String name;
  final FinancialPolarity polarity;
  final int startMonth;
  final int endMonth;
  final double amount;
  final bool isBaseline;

  const FinancialEvent({
    required this.id,
    required this.name,
    required this.polarity,
    required this.startMonth,
    required this.endMonth,
    required this.amount,
    required this.isBaseline,
  });

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
