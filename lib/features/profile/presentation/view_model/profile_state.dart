import 'package:tripmate/features/profile/domain/entity/profile_entity.dart';

class ProfileState {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? error;

  ProfileState({this.isLoading = false, this.profile, this.error});
}