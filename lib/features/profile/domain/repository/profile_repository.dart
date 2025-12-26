// import 'dart:io';
// import 'package:dartz/dartz.dart';
// import 'package:tripmate/core/error/failure.dart';
// import '../entity/profile_entity.dart';

// abstract interface class IProfileRepository {
//   Future<Either<Failure, ProfileEntity>> getUserProfile();
//   Future<Either<Failure, ProfileEntity>> updateFullProfile(ProfileEntity profile, File? image);
// }








import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tripmate/core/error/failure.dart';
import '../entity/profile_entity.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getUserProfile();

  // ✅ Must use curly braces {} for named parameters to match the implementation
  Future<Either<Failure, ProfileEntity>> updateFullProfile(
    ProfileEntity profile, {
    File? profilePic,
    File? licenseImg,
    File? selfieImg,
    File? bikeImg,
    File? bb2,
    File? bb3,
  });
}