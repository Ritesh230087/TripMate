import 'dart:io';
import 'package:equatable/equatable.dart';

class RiderKycEntity extends Equatable {
  // Step 2
  final File? citizenshipFront;
  final File? citizenshipBack;
  // Step 3
  final String licenseNumber;
  final String licenseExpiry;
  final String licenseIssue;
  final File? licenseImage;
  final File? selfieWithLicense;
  // Step 4
  final String vehicleModel;
  final String vehicleYear;
  final String vehiclePlate;
  final File? vehiclePhoto;
  final File? billbookPage2;
  final File? billbookPage3;

  const RiderKycEntity({
    this.citizenshipFront, this.citizenshipBack,
    this.licenseNumber = '', this.licenseExpiry = '', this.licenseIssue = '',
    this.licenseImage, this.selfieWithLicense,
    this.vehicleModel = '', this.vehicleYear = '', this.vehiclePlate = '',
    this.vehiclePhoto, this.billbookPage2, this.billbookPage3,
  });

  @override
  List<Object?> get props => [licenseNumber, vehiclePlate];
}