import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/features/auth/domain/use_case/login_usecase.dart';
import 'package:tripmate/features/auth/presentation/view/register_view.dart';
import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_viewmodel.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;

  LoginViewModel(this._loginUseCase) : super(LoginState.initial()) {
    on<LoginUserEvent>(_onLogin);
    on<NavigateToRegisterEvent>(_onNavigateRegister);
  }

  Future<void> _onLogin(LoginUserEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        ScaffoldMessenger.of(event.context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
      },
      (token) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        ScaffoldMessenger.of(event.context).showSnackBar(const SnackBar(content: Text("Login Successful!"), backgroundColor: Colors.green));
        // TODO: Navigate to Home Dashboard here
      },
    );
  }

  void _onNavigateRegister(NavigateToRegisterEvent event, Emitter<LoginState> emit) {
    Navigator.push(
      event.context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => serviceLocator<RegisterViewModel>(),
          child: const RegisterView(),
        ),
      ),
    );
  }
}