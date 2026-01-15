import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tripmate/core/error/failure.dart';
import '../entity/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, void>> registerUser(AuthEntity user, File? image);
  Future<Either<Failure, String>> loginUser(String email, String password);
  Future<Either<Failure, void>> updateFcmToken(String token);
}