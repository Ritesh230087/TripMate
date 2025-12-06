import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tripmate/app/use_case/usecase.dart';
import 'package:tripmate/core/error/failure.dart';
import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String gender;
  final String dob;
  final File? image;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
    required this.dob,
    this.image,
  });

  @override
  List<Object?> get props => [fullName, email, phone, image];
}

class RegisterUseCase implements UsecaseWithParams<void, RegisterParams> {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) {
    return _repository.registerUser(
      AuthEntity(
        fullName: params.fullName,
        email: params.email,
        phone: params.phone,
        password: params.password,
        gender: params.gender,
        dob: params.dob,
      ),
      params.image,
    );
  }
}