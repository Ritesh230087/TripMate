import 'dart:io';
import 'package:flutter/material.dart';

abstract class RiderKycEvent {}

class SubmitKycEvent extends RiderKycEvent {
  final BuildContext context;
  
  // Step 3 Data
  final File? citizenshipFront;
  final File? citizenshipBack;
  final String licenseNumber;
  final String licenseExpiryDate;
  final String licenseIssueDate;
  final File? licenseImage;
  final File? selfieWithLicense;

  // Step 4 Data
  final String vehicleModel;
  final String vehicleProductionYear;
  final String vehiclePlateNumber;
  final File? vehiclePhoto;
  final File? billbookPage2;
  final File? billbookPage3;

  SubmitKycEvent({
    required this.context,
    this.citizenshipFront,
    this.citizenshipBack,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    required this.licenseIssueDate,
    this.licenseImage,
    this.selfieWithLicense,
    required this.vehicleModel,
    required this.vehicleProductionYear,
    required this.vehiclePlateNumber,
    this.vehiclePhoto,
    this.billbookPage2,
    this.billbookPage3,
  });
}