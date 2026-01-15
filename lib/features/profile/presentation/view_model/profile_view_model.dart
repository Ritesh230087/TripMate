import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/features/auth/domain/repository/auth_repository.dart';
import 'package:tripmate/features/auth/presentation/view/login_view.dart';
import 'package:tripmate/features/profile/domain/use_case/get_profile_usecase.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_event.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_state.dart';

class ProfileViewModel extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  
  ProfileViewModel({required this.getProfileUseCase}) : super(ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<LogoutEvent>(_onLogout); 
  }

  Future<void> _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileState(isLoading: true));
    final result = await getProfileUseCase();
    result.fold(
      (failure) => emit(ProfileState(isLoading: false, error: failure.message)),
      (profile) => emit(ProfileState(isLoading: false, profile: profile)),
    );
  }

  // ✅ LOGOUT WITH FCM CLEARING
  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    try {
      // 1. Clear FCM Token on Backend so notifications stop
      await serviceLocator<IAuthRepository>().updateFcmToken("");

      // 2. Clear Local SharedPreferences (Token & UserID)
      await serviceLocator<TokenSharedPrefs>().clear();

      // 3. Navigate to Login and clear all previous routes
      if (event.context.mounted) {
        Navigator.pushAndRemoveUntil(
          event.context,
          MaterialPageRoute(builder: (context) => const LoginView()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Logout error: $e");
      // Fallback: Logout anyway if server fails
      await serviceLocator<TokenSharedPrefs>().clear();
      if (event.context.mounted) {
        Navigator.pushAndRemoveUntil(event.context, MaterialPageRoute(builder: (_) => const LoginView()), (r) => false);
      }
    }
  }
}