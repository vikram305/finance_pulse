import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:finance_pulse/core/bloc/bloc_events.dart';
import 'package:finance_pulse/core/bloc/bloc_states.dart';
import 'package:finance_pulse/core/bloc/filter.dart';
import 'package:finance_pulse/core/error/failure.dart';

abstract class BaseBloc<T> extends Bloc<FetchDataEvent, FetchDataState<T>> {
  BaseBloc() : super(FetchDataState<T>(status: Status.initial)) {
    on<FetchData>((event, emit) async {
      if (event.refresh) {
        emit(state.copyWith(status: Status.refresh));
      } else {
        emit(state.copyWith(status: Status.loading));
      }

      final result = await operation(filter: event.filter ?? const NoFilter());
      if (isClosed) return;
      result.fold(
        (l) {
          emit(
            state.copyWith(
              status: event.refresh ? Status.refreshFailure : Status.failure,
              filter: event.filter,
            ),
          );
        },
        (r) {
          emit(
            FetchDataState(
              status: Status.success,
              filter: event.filter,
              data: r,
            ),
          );
        },
      );
    });
  }

  Future<Either<Failure, T>> operation({required Filter filter});
}
