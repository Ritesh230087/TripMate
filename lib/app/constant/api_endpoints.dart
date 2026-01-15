class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  // static const String baseUrl = "http://10.248.241.105:5000/api/";
  static const String baseUrl = "http://192.168.1.87:5000/api/";                               //home
  // static const String baseUrl = "http://172.21.99.144:5000/api/";                                //college
  static const String notifications = "notifications";
  

  static const String login = "auth/login";
  static const String register = "auth/register";
  static const String userProfile = "auth/me"; 
  // static const String imageUrl = "http://10.248.241.105:5000/";
  static const String imageUrl = "http://192.168.1.87:5000/";                                //home
  // static const String imageUrl = "http://172.21.99.144:5000/";                                 //college
}