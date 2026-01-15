import 'package:dartz/dartz.dart';
import 'package:tripmate/core/error/failure.dart';
import '../entity/rider_kyc_entity.dart';

abstract interface class IRiderRepository {
  Future<Either<Failure, void>> applyForRider(RiderKycEntity kycData);
}