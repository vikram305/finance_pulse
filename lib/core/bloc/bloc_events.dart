import 'package:equatable/equatable.dart';
import 'package:finance_pulse/core/bloc/filter.dart';

abstract class FetchDataEvent extends Equatable {
  const FetchDataEvent();

  @override
  List<Object?> get props => [];
}

class FetchData extends FetchDataEvent {
  const FetchData({this.refresh = false, this.filter});

  final bool refresh;

  final Filter? filter;

  @override
  List<Object?> get props => [refresh, filter];
}
