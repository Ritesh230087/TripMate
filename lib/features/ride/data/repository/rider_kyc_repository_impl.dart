import 'package:dartz/dartz.dart';
import 'package:tripmate/core/error/failure.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/rider_kyc_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/rider_kyc_entity.dart';
import 'package:tripmate/features/ride/domain/repository/rider_kyc_repository.dart';

class RiderRepositoryImpl implements IRiderRepository {
  final RiderRemoteDataSource remoteDataSource;

  RiderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> applyForRider(RiderKycEntity kycData) async {
    try {
      await remoteDataSource.submitKyc(kycData);
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}