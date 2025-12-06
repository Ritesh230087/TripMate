import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String gender;
  final String dob;
  final String? image; // Path to the image file

  const AuthEntity({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
    required this.dob,
    this.image,
  });

  @override
  List<Object?> get props => [id, email, fullName, image];
}