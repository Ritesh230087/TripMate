import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tripmate/core/error/failure.dart';
import 'package:tripmate/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:tripmate/features/auth/domain/entity/auth_entity.dart';
import 'package:tripmate/features/auth/domain/repository/auth_repository.dart';

class AuthRemoteRepository implements IAuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRemoteRepository(this._dataSource);

  @override
  Future<Either<Failure, void>> registerUser(AuthEntity user, File? image) async {
    try {
      await _dataSource.registerUser(user, image);
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> loginUser(String email, String password) async {
    try {
      final token = await _dataSource.loginUser(email, password);
      return Right(token);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}