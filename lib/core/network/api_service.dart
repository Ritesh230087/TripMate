import 'package:dio/dio.dart';
import 'package:tripmate/app/constant/api_endpoints.dart';
import 'dio_error_interceptor.dart';

class ApiService {
  final Dio _dio;
  Dio get dio => _dio;

  ApiService(this._dio) {
    _dio
      ..options.baseUrl = ApiEndpoints.baseUrl
      ..options.connectTimeout = ApiEndpoints.connectionTimeout
      ..options.receiveTimeout = ApiEndpoints.receiveTimeout
      ..options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      }
      ..interceptors.add(DioErrorInterceptor());
  }
}