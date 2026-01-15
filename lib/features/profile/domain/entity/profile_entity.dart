import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String? image;
  final String role;
  final String riderStatus;
  
  // Real Data Stats
  final int ridesTaken;
  final double totalSpent;
  final int ridesDone;
  final double totalEarned;
  final double riderRating;
  final double passengerRating;
  final List<String> riderTags;
  final List<String> passengerTags;

  final String? kycRejectionReason;
  final Map<String, dynamic>? kycDetails;

  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    this.image,
    required this.role,
    this.riderStatus = 'none',
    this.ridesTaken = 0,
    this.totalSpent = 0.0,
    this.ridesDone = 0,
    this.totalEarned = 0.0,
    this.riderRating = 5.0,
    this.passengerRating = 5.0,
    this.riderTags = const [],
    this.passengerTags = const [],
    this.kycRejectionReason,
    this.kycDetails,
  });

  @override
  List<Object?> get props => [id, email, role, ridesTaken, totalEarned, kycDetails, kycRejectionReason, riderRating, passengerRating, riderTags, passengerTags];
}