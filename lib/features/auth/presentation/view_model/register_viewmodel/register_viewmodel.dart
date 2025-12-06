import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/features/auth/domain/use_case/register_use_case.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterViewModel extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterViewModel(this._registerUseCase) : super(RegisterState.initial()) {
    on<RegisterUserEvent>(_onRegister);
  }

  Future<void> _onRegister(RegisterUserEvent event, Emitter<RegisterState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _registerUseCase(RegisterParams(
      fullName: event.fullName,
      email: event.email,
      phone: event.phone,
      password: event.password,
      gender: event.gender,
      dob: event.dob,
      image: event.image,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        ScaffoldMessenger.of(event.context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
      },
      (success) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        ScaffoldMessenger.of(event.context).showSnackBar(const SnackBar(content: Text("Registration Successful"), backgroundColor: Colors.green));
        Navigator.pop(event.context); // Navigate back to Login
      },
    );
  }
}