import 'package:esewa_flutter_sdk/esewa_config.dart';

class EsewaPaymentConfig {
  // ✅ These are the specific SDK credentials from your documentation
  static const String clientId = "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R";
  static const String secretId = "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==";
  
  static EsewaConfig getConfiguration() {
    return EsewaConfig(
      clientId: clientId,
      secretId: secretId,
      environment: Environment.test, // Use Environment.live for production
    );
  }
}