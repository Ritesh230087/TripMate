import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/core/network/api_service.dart';
import 'package:tripmate/features/ride/domain/entity/rider_kyc_entity.dart';

class RiderRemoteDataSource {
  final ApiService _apiService;
  final TokenSharedPrefs _tokenSharedPrefs;

  RiderRemoteDataSource(this._apiService, this._tokenSharedPrefs);

Future<void> submitKyc(RiderKycEntity kyc) async {
  try {
    final token = (await _tokenSharedPrefs.getToken()).getOrElse(() => '');
    
    Map<String, dynamic> data = {
      "licenseNumber": kyc.licenseNumber,
      "licenseExpiryDate": kyc.licenseExpiry,
      "licenseIssueDate": kyc.licenseIssue,
      "vehicleModel": kyc.vehicleModel,
      "vehicleProductionYear": kyc.vehicleYear,
      "vehiclePlateNumber": kyc.vehiclePlate,
    };

    FormData formData = FormData.fromMap(data);
    
    Future<MultipartFile?> _prepareFile(File? file, String key) async {
      if (file != null && file.path.isNotEmpty) {
        return await MultipartFile.fromFile(
          file.path, 
          filename: '${key}_${DateTime.now().millisecondsSinceEpoch}.jpg'
        );
      }
      return null;
    }

    final fileFutures = await Future.wait([
      _prepareFile(kyc.citizenshipFront, "citizenshipFront"),
      _prepareFile(kyc.citizenshipBack, "citizenshipBack"),
      _prepareFile(kyc.licenseImage, "licenseImage"),
      _prepareFile(kyc.selfieWithLicense, "selfieWithLicense"),
      _prepareFile(kyc.vehiclePhoto, "vehiclePhoto"),
      _prepareFile(kyc.billbookPage2, "billbookPage2"),
      _prepareFile(kyc.billbookPage3, "billbookPage3"),
    ]);

    const keys = [
      "citizenshipFront", "citizenshipBack", "licenseImage", 
      "selfieWithLicense", "vehiclePhoto", "billbookPage2", "billbookPage3"
    ];

    for (int i = 0; i < fileFutures.length; i++) {
      if (fileFutures[i] != null) {
        formData.files.add(MapEntry(keys[i], fileFutures[i]!));
      }
    }

    final response = await _apiService.dio.post(
      "${ApiEndpoints.baseUrl}rider/kyc",
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        sendTimeout: const Duration(seconds: 60), 
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    if (response.statusCode != 200) throw Exception("Upload failed");
  } catch (e) {
    throw Exception(e.toString());
  }
}
} 