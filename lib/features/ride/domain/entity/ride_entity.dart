import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class RideEntity extends Equatable {
  final String? id;
  final String riderId;
  final String from;
  final LatLng fromLatLng;
  final String to;
  final LatLng toLatLng;
  final String date;
  final String time;
  final double price;
  final List<LatLng>? routePath;
  final String? riderName;
  final String? riderImage;
  final String? vehicleName;
  final double riderRating; // Rating for this specific rider
  final List<String>? riderTags; // Top tags for the rider
  final String status;

  final LatLng? pickupMeetingPoint; 
  final LatLng? dropMeetingPoint;
  final LatLng? passengerActualPickup; 
  final LatLng? passengerActualDropoff;

  final String? acceptedPassengerName;
  final String? acceptedPassengerImage;
  final String? acceptedPassengerPhone;
  final bool isBooked;

  // Payment Info
  final String paymentMethod; // 'cash', 'esewa', 'pending'
  final String paymentStatus; // 'unpaid', 'paid'


    final String? riderPhone; // Added
  final String? vehiclePlateNumber; // Added
  final String? vehicleModel; // Added

  // Match Info
  final String? matchType;
  final int pickupDetour;
  final int pickupWalk;
  final int dropoffDetour;
  final int dropoffWalk;
  final int totalDetour;
  final int totalWalk;

  const RideEntity({
    this.id,
    required this.riderId,
    required this.from,
    required this.fromLatLng,
    required this.to,
    required this.toLatLng,
    required this.date,
    required this.time,
    required this.price,
    this.riderName,
    this.riderImage,
    this.vehicleName,
    this.riderRating = 0.0,
    this.riderTags,
    this.status = 'active',
    this.pickupMeetingPoint,
    this.dropMeetingPoint,
    this.passengerActualPickup,
    this.passengerActualDropoff,
    this.paymentMethod = 'pending',
    this.paymentStatus = 'unpaid',
    this.matchType,
    this.pickupDetour = 0,
    this.pickupWalk = 0,
    this.dropoffDetour = 0,
    this.dropoffWalk = 0,
    this.totalDetour = 0,
    this.totalWalk = 0,
    this.routePath,
    this.acceptedPassengerName,
    this.acceptedPassengerImage,
    this.acceptedPassengerPhone,
    this.isBooked = false,

   this.riderPhone, // Added
  this.vehiclePlateNumber, // Added
  this.vehicleModel, // Added
  });

  @override
  List<Object?> get props => [id, status, isBooked, paymentStatus];
}