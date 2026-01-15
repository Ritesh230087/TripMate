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
      final token = (await _tokenSharedPrefs.getToken()).getOrElse(() => '');
      final response = await _apiService.dio.get(
        "${ApiEndpoints.baseUrl}auth/me",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ProfileApiModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }


Future<ProfileApiModel> updateFullProfile(
    ProfileEntity profile, {
    File? profilePic, File? licenseImg, File? selfieImg,
    File? bikeImg, File? bb2, File? bb3,
  }) async {
    final token = (await _tokenSharedPrefs.getToken()).getOrElse(() => '');
    
    Map<String, dynamic> data = {
      "fullName": profile.fullName,
      "phone": profile.phone,
      "gender": profile.gender,
      "dob": profile.dob,
      "licenseNumber": profile.kycDetails?['licenseNumber'],
      "licenseExpiryDate": profile.kycDetails?['licenseExpiryDate'],
      "licenseIssueDate": profile.kycDetails?['licenseIssueDate'],
      "vehicleModel": profile.kycDetails?['vehicleModel'],
      "vehicleProductionYear": profile.kycDetails?['vehicleProductionYear'],
      "vehiclePlateNumber": profile.kycDetails?['vehiclePlateNumber'],
    };

    FormData formData = FormData.fromMap(data);
    
    Future<void> attach(String key, File? f) async {
      if (f != null && f.path.isNotEmpty && await f.exists()) {
        formData.files.add(MapEntry(key, await MultipartFile.fromFile(f.path)));
      }
    }

    await attach("profilePic", profilePic);
    await attach("licenseImage", licenseImg);
    await attach("selfieWithLicense", selfieImg);
    await attach("vehiclePhoto", bikeImg);
    await attach("billbookPage2", bb2);
    await attach("billbookPage3", bb3);

    final res = await _apiService.dio.put("${ApiEndpoints.baseUrl}auth/update",
        data: formData, options: Options(headers: {'Authorization': 'Bearer $token'}));
    
    return ProfileApiModel.fromJson(res.data);
  }
}