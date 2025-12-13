import 'package:tripmate/features/profile/domain/entity/profile_entity.dart';

class ProfileApiModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? image;
  final String riderStatus;
  final String? kycRejectionReason;
  final Map<String, dynamic>? kycDetails;

  ProfileApiModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.image,
    required this.riderStatus,
    this.kycRejectionReason,
    this.kycDetails,
  });

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['profilePic'], 
      riderStatus: json['riderStatus'] ?? 'none',
      kycRejectionReason: json['kycRejectionReason'],
      kycDetails: json['kycDetails'] != null ? Map<String, dynamic>.from(json['kycDetails']) : null,
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      image: image,
      riderStatus: riderStatus,
      kycRejectionReason: kycRejectionReason,
      kycDetails: kycDetails,
    );
  }
}