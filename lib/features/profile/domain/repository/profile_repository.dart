import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tripmate/core/error/failure.dart';
import '../entity/profile_entity.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getUserProfile();
  Future<Either<Failure, ProfileEntity>> updateUserProfile(ProfileEntity profile, File? image);
}