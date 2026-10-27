import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';

/// Base contract for all application use cases in Clean Architecture.
///
/// Encapsulates a single business logic operation, returning a [Future] of
/// an [Either] with a [Failure] on the left or the result [T] on the right.
abstract class UseCase<T, Params> {
  const UseCase();

  /// Executes the use case with the given [params].
  Future<Either<Failure, T>> call(Params params);
}

/// Parameter type indicating that a [UseCase] does not require any input arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

