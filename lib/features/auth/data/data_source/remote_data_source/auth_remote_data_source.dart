import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
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
}