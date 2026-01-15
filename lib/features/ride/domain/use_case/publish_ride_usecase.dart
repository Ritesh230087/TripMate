import 'package:dartz/dartz.dart';
import 'package:tripmate/app/use_case/usecase.dart';
import 'package:tripmate/core/error/failure.dart';
import '../entity/ride_entity.dart';
import '../repository/ride_repository.dart';

class PublishRideUseCase implements UsecaseWithParams<void, RideEntity> {
  final IRideRepository repository;
  PublishRideUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RideEntity params) {
    return repository.publishRide(params);
  }
}