import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;

  const Failure([this.message]);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);

  @override
  List<Object?> get props => [];
}

class InternetFailure extends Failure {
  const InternetFailure();

  @override
  List<Object?> get props => [];
}

class BadFilterFailure extends Failure {
  const BadFilterFailure();

  @override
  List<Object?> get props => [];
}
