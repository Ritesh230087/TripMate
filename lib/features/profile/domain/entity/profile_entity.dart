import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? image;
  final String riderStatus; 
  final String? kycRejectionReason;
  final Map<String, dynamic>? kycDetails; 

  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.image,
    this.riderStatus = 'none',
    this.kycRejectionReason,
    this.kycDetails,
  });

  @override
  List<Object?> get props => [id, fullName, email, phone, image, riderStatus, kycRejectionReason, kycDetails];
}