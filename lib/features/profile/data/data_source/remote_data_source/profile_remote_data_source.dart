import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/core/network/api_service.dart';
import 'package:tripmate/features/profile/data/model/profile_api_model.dart';
import 'package:tripmate/features/profile/domain/entity/profile_entity.dart';

class ProfileRemoteDataSource {
  final ApiService _apiService;
  final TokenSharedPrefs _tokenSharedPrefs;

  ProfileRemoteDataSource(this._apiService, this._tokenSharedPrefs);

  Future<ProfileApiModel> getUserProfile() async {
    try {
      final tokenResult = await _tokenSharedPrefs.getToken();
      final token = tokenResult.getOrElse(() => '');

      final response = await _apiService.dio.get(
        "${ApiEndpoints.baseUrl}auth/me", // Endpoint to get current user
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return ProfileApiModel.fromJson(response.data['user']);
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<ProfileApiModel> updateUserProfile(ProfileEntity profile, File? image) async {
    try {
      final tokenResult = await _tokenSharedPrefs.getToken();
      final token = tokenResult.getOrElse(() => '');

      FormData formData = FormData.fromMap({
        "fullName": profile.fullName,
        "phone": profile.phone,
        if (image != null)
          "profilePic": await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
      });

      final response = await _apiService.dio.put(
        "${ApiEndpoints.baseUrl}auth/update", // Endpoint to update
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return ProfileApiModel.fromJson(response.data['user']);
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}