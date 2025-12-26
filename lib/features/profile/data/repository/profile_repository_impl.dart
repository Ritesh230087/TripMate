import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tripmate/core/error/failure.dart';
import 'package:tripmate/features/profile/data/data_source/remote_data_source/profile_remote_data_source.dart';
import 'package:tripmate/features/profile/domain/entity/profile_entity.dart';
import 'package:tripmate/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ProfileEntity>> getUserProfile() async {
    try {
      final model = await remoteDataSource.getUserProfile();
      return Right(model.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateFullProfile(
    ProfileEntity profile, {
    File? profilePic,
    File? licenseImg,
    File? selfieImg,
    File? bikeImg,
    File? bb2,
    File? bb3,
  }) async {
    try {
      final model = await remoteDataSource.updateFullProfile(
        profile,
        profilePic: profilePic,
        licenseImg: licenseImg,
        selfieImg: selfieImg,
        bikeImg: bikeImg,
        bb2: bb2,
        bb3: bb3,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}