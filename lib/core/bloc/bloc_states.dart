import 'package:equatable/equatable.dart';
import 'package:finance_pulse/core/bloc/filter.dart';
import 'package:finance_pulse/core/constants/app_strings.dart';

enum Status { initial, loading, success, failure, refresh, refreshFailure }

class FetchDataState<T> extends Equatable {
  const FetchDataState({
    this.data,
    this.error,
    this.filter,
    this.status = Status.initial,
  });

  /// list of fetched items
  final T? data;

  /// API call status of the first page
  final Status status;

  /// holds the error for the latest API call if any
  final String? error;

  /// filters used to fetch the list
  final Filter? filter;

  /// API call status of the latest subsequent page

  String get errorMessage {
    if (error is Exception) return error.toString();

    return AppStrings.somethingWentWrong;
  }

  FetchDataState<T> copyWith({
    String? error,
    Status? status,
    T? data,
    Filter? filter,
  }) {
    return FetchDataState<T>(
      data: data ?? this.data,
      error: error ?? this.error,
      filter: filter ?? this.filter,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [data, error, filter, status];
}
