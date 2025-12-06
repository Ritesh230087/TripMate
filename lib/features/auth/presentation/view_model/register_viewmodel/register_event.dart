import 'dart:io';
import 'package:flutter/material.dart';

sealed class RegisterEvent {}

class RegisterUserEvent extends RegisterEvent {
  final BuildContext context;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String gender;
  final String dob;
  final File? image;

  RegisterUserEvent({
    required this.context,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
    required this.dob,
    this.image,
  });
}