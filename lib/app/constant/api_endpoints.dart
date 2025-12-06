class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // 10.0.2.2 for Android Emulator. Use your PC IP (e.g. 192.168.1.X) for physical device.
  static const String baseUrl = "http://10.0.2.2:5000/api/";

  static const String login = "auth/login";
  static const String register = "auth/register";
  static const String imageUrl = "http://10.0.2.2:5000/";
}