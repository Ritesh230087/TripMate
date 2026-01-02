import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/features/auth/domain/use_case/register_use_case.dart';
import 'package:tripmate/core/common/snackbar/my_snack_bar.dart'; // ✅ Add this import
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
        // ✅ Use your custom snackbar for error
        showMySnackBar(
          context: event.context, 
          message: failure.message, 
          isError: true
        );
      },
      (success) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        // ✅ Use your custom snackbar for success
        showMySnackBar(
          context: event.context, 
          message: "Registration Successful"
        );
        Navigator.pop(event.context); 
      },
    );
  }
}