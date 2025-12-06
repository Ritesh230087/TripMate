import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ApiFailure extends Failure {
  const ApiFailure({required super.message});
}

class SharedPrefsFailure extends Failure {
  const SharedPrefsFailure({required super.message});
}