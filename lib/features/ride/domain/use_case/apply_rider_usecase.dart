import 'package:dartz/dartz.dart';
import 'package:tripmate/app/use_case/usecase.dart';
import 'package:tripmate/core/error/failure.dart';
import 'package:tripmate/features/ride/domain/entity/rider_kyc_entity.dart';
import 'package:tripmate/features/ride/domain/repository/rider_kyc_repository.dart';

class ApplyRiderUseCase implements UsecaseWithParams<void, RiderKycEntity> {
  final IRiderRepository repository;

  ApplyRiderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RiderKycEntity params) {
    return repository.applyForRider(params);
  }
}