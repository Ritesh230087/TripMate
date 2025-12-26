import 'package:tripmate/features/profile/domain/entity/profile_entity.dart';

class ProfileApiModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String? image;
  final String role;
  final String riderStatus;
  final String? kycRejectionReason;
  final Map<String, dynamic>? kycDetails;

  // Stats mapped from the backend response
  final int ridesTaken;
  final double totalSpent;
  final int ridesDone;
  final double totalEarned;
  final double rating;

  ProfileApiModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    this.image,
    required this.role,
    required this.riderStatus,
    this.kycRejectionReason,
    this.kycDetails,
    required this.ridesTaken,
    required this.totalSpent,
    required this.ridesDone,
    required this.totalEarned,
    required this.rating,
  });

factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
  final userData = json['user'] ?? json;
  final statsData = json['stats'] ?? {};
  final bool isRider = userData['role'] == 'rider';

  return ProfileApiModel(
    id: userData['_id'] ?? '',
    fullName: userData['fullName'] ?? '',
    email: userData['email'] ?? '',
    phone: userData['phone'] ?? '',
    gender: userData['gender'] ?? 'Other',
    dob: userData['dob'] ?? '',
    image: userData['profilePic'],
    role: userData['role'] ?? 'passenger',
    riderStatus: userData['riderStatus'] ?? 'none',
    kycRejectionReason: userData['kycRejectionReason'],
    
    // ✅ ENSURE THIS MAP USES THE EXACT BACKEND KEYS
    kycDetails: userData['kycDetails'] != null 
        ? Map<String, dynamic>.from(userData['kycDetails']) 
        : null,
    
    ridesTaken: statsData['ridesTaken'] ?? 0,
    totalSpent: (statsData['totalSpent'] ?? 0.0).toDouble(),
    ridesDone: statsData['ridesDone'] ?? 0,
    totalEarned: (statsData['totalEarned'] ?? 0.0).toDouble(),
    rating: (statsData['rating'] ?? 5.0).toDouble(),
  );
}

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      gender: gender,
      dob: dob,
      image: image,
      role: role,
      riderStatus: riderStatus,
      kycRejectionReason: kycRejectionReason,
      kycDetails: kycDetails,
      ridesTaken: ridesTaken,
      totalSpent: totalSpent,
      ridesDone: ridesDone,
      totalEarned: totalEarned,
      rating: rating,
    );
  }
}