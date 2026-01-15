import 'package:dartz/dartz.dart';
import 'package:tripmate/core/error/failure.dart';
import 'package:tripmate/features/ride/domain/use_case/send_request_usecase.dart';
import '../entity/ride_entity.dart';

abstract interface class IRideRepository {
  Future<Either<Failure, void>> publishRide(RideEntity ride);
  Future<Either<Failure, void>> sendRequest(SendRequestParams params);
}