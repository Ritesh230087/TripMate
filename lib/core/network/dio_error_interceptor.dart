import 'package:dio/dio.dart';

class DioErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = "An unexpected error occurred";
    if (err.response != null) {
      errorMessage = err.response?.data['message'] ?? err.response?.statusMessage ?? "Server Error";
    } else {
      errorMessage = "Connection Error. Please check your internet.";
    }
    super.onError(
      DioException(
        requestOptions: err.requestOptions,
        error: errorMessage,
        response: err.response,
        type: err.type,
      ),
      handler,
    );
  }
}