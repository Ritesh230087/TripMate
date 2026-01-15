import 'package:dartz/dartz.dart';
import 'package:tripmate/core/error/failure.dart';
import 'package:tripmate/features/ride/data/data_source/remote_data_source/ride_remote_data_source.dart';
import 'package:tripmate/features/ride/domain/entity/ride_entity.dart';
import 'package:tripmate/features/ride/domain/repository/ride_repository.dart';
import 'package:tripmate/features/ride/domain/use_case/send_request_usecase.dart';

class RideRepositoryImpl implements IRideRepository {
  final RideRemoteDataSource dataSource;
  RideRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> publishRide(RideEntity ride) async {
    try {
      await dataSource.publishRide(ride);
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendRequest(SendRequestParams params) async {
    try {
      await dataSource.sendRequest(
        rideId: params.rideId,
        riderId: params.riderId,
        meetingPointLat: params.meetingPointLat,
        meetingPointLng: params.meetingPointLng,
        dropPointLat: params.dropPointLat,
        dropPointLng: params.dropPointLng,
        passengerPickupLat: params.passengerPickupLat,
        passengerPickupLng: params.passengerPickupLng,
        passengerDropoffLat: params.passengerDropoffLat,
        passengerDropoffLng: params.passengerDropoffLng,
        pickupDetour: params.pickupDetour,
        pickupWalk: params.pickupWalk,
        dropoffDetour: params.dropoffDetour,
        dropoffWalk: params.dropoffWalk,
        matchType: params.matchType,
      );
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}