import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tripmate/features/auth/presentation/view/login_view.dart';
import 'package:tripmate/features/profile/domain/use_case/get_profile_usecase.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_event.dart';
import 'package:tripmate/features/profile/presentation/view_model/profile_state.dart';

class ProfileViewModel extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  
  ProfileViewModel({
    required this.getProfileUseCase,
  }) : super(ProfileState()) {
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

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    Navigator.pushAndRemoveUntil(
      event.context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }
}