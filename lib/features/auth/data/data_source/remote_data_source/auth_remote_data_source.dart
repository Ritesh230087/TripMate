import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import '../../../domain/entity/auth_entity.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<void> registerUser(AuthEntity user, File? image) async {
    try {
      FormData formData = FormData.fromMap({
        "fullName": user.fullName,
        "email": user.email,
        "phone": user.phone,
        "password": user.password,
        "confirmPassword": user.password, // Required by backend
        "gender": user.gender,
        "dob": user.dob,
        if (image != null)
          "profilePic": await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      final response = await _dio.post(
        ApiEndpoints.register,
        data: formData,
      );

      if (response.statusCode != 201) {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? "Registration failed");
    }
  }

  Future<String> loginUser(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        return response.data['token'];
      } else {
        throw Exception(response.statusMessage);
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? "Login failed");
    }
  }


  Future<void> updateFcmToken(String fcmToken) async {
    try {
      // Get the JWT token from shared prefs
      final tokenResult = await serviceLocator<TokenSharedPrefs>().getToken();
      final token = tokenResult.getOrElse(() => '');

      await _dio.put(
        "${ApiEndpoints.baseUrl}auth/update-fcm",
        data: {"fcmToken": fcmToken},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "FCM update failed");
    }
  }


  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        "${ApiEndpoints.baseUrl}auth/forgot-password",
        data: {"email": email},
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? "Error sending reset email");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? "Network error");
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
  try {
    final response = await _dio.put(
      "${ApiEndpoints.baseUrl}auth/reset-password/$token",
      data: {"password": newPassword},
    );

    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? "Failed to reset password");
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? "Network error");
  }
}


Future<String> loginWithGoogle(String idToken) async {
  try {
    final response = await _dio.post(
      "${ApiEndpoints.baseUrl}auth/google-login",
      data: {"idToken": idToken},
    );

    if (response.statusCode == 200) {
      return response.data['token'];
    } else {
      throw Exception("Google Login Failed");
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? "Network Error");
  }
}

}