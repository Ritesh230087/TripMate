import 'package:equatable/equatable.dart';

class RideRequestEntity extends Equatable {
  final String id;
  final String passengerName;
  final String passengerImage;
  final double passengerRating;
  final List<String>? passengerTags; 
  final String fromLocation;
  final String toLocation;
  final double price;
  final String date;
  final String time;
  
  final int pickupDetour;
  final int pickupWalk;
  final int dropoffDetour;
  final int dropoffWalk;
  final String matchType;

  const RideRequestEntity({
    required this.id,
    required this.passengerName,
    required this.passengerImage,
    required this.passengerRating,
    this.passengerTags,
    required this.fromLocation,
    required this.toLocation,
    required this.price,
    required this.date,
    required this.time,
    required this.pickupDetour,
    required this.pickupWalk,
    required this.dropoffDetour,
    required this.dropoffWalk,
    required this.matchType,
  });

  @override
  List<Object?> get props => [id];
}