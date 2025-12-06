import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/app/use_case/usecase.dart';
import 'package:tripmate/core/error/failure.dart';
import '../repository/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class LoginUseCase implements UsecaseWithParams<String, LoginParams> {
  final IAuthRepository _repository;
  final TokenSharedPrefs _tokenSharedPrefs;

  LoginUseCase(this._repository, this._tokenSharedPrefs);

  @override
  Future<Either<Failure, String>> call(LoginParams params) async {
    final result = await _repository.loginUser(params.email, params.password);
    return result.fold(
      (failure) => Left(failure),
      (token) async {
        await _tokenSharedPrefs.saveToken(token);
        return Right(token);
      },
    );
  }
}