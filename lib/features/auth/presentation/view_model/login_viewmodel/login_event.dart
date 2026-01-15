import 'package:flutter/material.dart';

sealed class LoginEvent {}

class LoginUserEvent extends LoginEvent {
  final BuildContext context;
  final String email;
  final String password;
  LoginUserEvent({required this.context, required this.email, required this.password});
}

// Ensure this specific class is here
class LoginWithGoogleEvent extends LoginEvent {
  final BuildContext context;
  LoginWithGoogleEvent({required this.context});
}

class NavigateToRegisterEvent extends LoginEvent {
  final BuildContext context;
  NavigateToRegisterEvent({required this.context});
}