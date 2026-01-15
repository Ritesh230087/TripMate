import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/core/common/snackbar/my_snack_bar.dart'; // ✅ Added custom snackbar import
import 'package:tripmate/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';
import 'package:tripmate/features/auth/domain/repository/auth_repository.dart';
import 'package:tripmate/features/auth/domain/use_case/login_usecase.dart';
import 'package:tripmate/features/auth/presentation/view/register_view.dart';
import 'package:tripmate/features/home/presentation/view/home_view.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "417514761148-rdlo8th4050kp4bbi9floib11r4i621j.apps.googleusercontent.com",
  );

  LoginViewModel(this._loginUseCase) : super(LoginState.initial()) {
    on<LoginUserEvent>(_onLogin);
    on<LoginWithGoogleEvent>(_onGoogleLogin); 
    
    on<NavigateToRegisterEvent>((event, emit) {
      Navigator.push(event.context, MaterialPageRoute(builder: (_) => const RegisterView()));
    });
  }

  // --- MANUAL LOGIN ---
  Future<void> _onLogin(LoginUserEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));
    await result.fold(
      (failure) async {
        emit(state.copyWith(isLoading: false));
        // ✅ Use custom snackbar for failure
        showMySnackBar(
          context: event.context,
          message: failure.message,
          isError: true,
        );
      },
      (token) async => await _handleLoginSuccess(token, event.context, emit),
    );
  }

  // --- GOOGLE LOGIN ---
  Future<void> _onGoogleLogin(LoginWithGoogleEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        emit(state.copyWith(isLoading: false));
        return; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        final backendToken = await serviceLocator<AuthRemoteDataSource>().loginWithGoogle(idToken);
        await _handleLoginSuccess(backendToken, event.context, emit);
      } else {
        throw Exception("Failed to get Google ID Token");
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // ✅ Use custom snackbar for Google errors
      showMySnackBar(
        context: event.context,
        message: "Google Sign-In Error: $e",
        isError: true,
      );
    }
  }

  // ✅ Unified Success Handler
  Future<void> _handleLoginSuccess(String token, BuildContext context, Emitter<LoginState> emit) async {
    final tokenPrefs = serviceLocator<TokenSharedPrefs>();
    await tokenPrefs.saveToken(token);

    try {
      final payload = json.decode(utf8.decode(base64.decode(base64.normalize(token.split(".")[1]))));
      final String userId = payload['id'] ?? payload['_id']; 
      await tokenPrefs.saveUserId(userId);
    } catch (e) { 
      debugPrint("❌ Error decoding token ID: $e"); 
    }

    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await serviceLocator<IAuthRepository>().updateFcmToken(fcmToken);
      }
    } catch (e) { 
      debugPrint("⚠️ FCM Sync Error: $e"); 
    }

    emit(state.copyWith(isLoading: false, isSuccess: true));
    
    // ✅ Show success snackbar before moving to Home
    showMySnackBar(
      context: context,
      message: "Login Successful!",
    );

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeView()));
  }
}