import 'package:dartz/dartz.dart';
import 'package:tripmate/app/use_case/usecase.dart';
import 'package:tripmate/core/error/failure.dart';
import 'package:tripmate/features/ride/domain/repository/ride_repository.dart';

class SendRequestParams {
  final String rideId;
  final String riderId;
  final double meetingPointLat;
  final double meetingPointLng;
  final double dropPointLat;
  final double dropPointLng;
  final double passengerPickupLat;
  final double passengerPickupLng;
  final double passengerDropoffLat;
  final double passengerDropoffLng;

  final int pickupDetour;
  final int pickupWalk;
  final int dropoffDetour;
  final int dropoffWalk;
  final String matchType;

  SendRequestParams({
    required this.rideId,
    required this.riderId,
    required this.meetingPointLat,
    required this.meetingPointLng,
    required this.dropPointLat,
    required this.dropPointLng,
    required this.passengerPickupLat,
    required this.passengerPickupLng,
    required this.passengerDropoffLat,
    required this.passengerDropoffLng,
    required this.pickupDetour,
    required this.pickupWalk,
    required this.dropoffDetour,
    required this.dropoffWalk,
    required this.matchType,
  });
}

class SendRequestUseCase implements UsecaseWithParams<void, SendRequestParams> {
  final IRideRepository repository;
  SendRequestUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendRequestParams params) {
    return repository.sendRequest(params);
  }
}