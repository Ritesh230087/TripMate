import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/features/profile/domain/entity/profile_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final ProfileEntity profile;
  final File? image;
  
  const UpdateProfileEvent({required this.profile, this.image});

  @override
  List<Object?> get props => [profile, image];
}

// ✅ DEFINE THIS CLASS EXACTLY LIKE THIS
class LogoutEvent extends ProfileEvent {
  final BuildContext context;
  
  const LogoutEvent({required this.context});

  @override
  List<Object?> get props => [context];
}