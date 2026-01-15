import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/payment/esewa_config.dart';

class EsewaService {
  static void pay({
    required String productId,
    required String productName,
    required double amount,
    required Function(EsewaPaymentSuccessResult) onSuccess,
    required Function() onFailure,
  }) {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaPaymentConfig.getConfiguration(),
        esewaPayment: EsewaPayment(
          productId: productId,
          productName: "EPAYTEST", // ✅ Change this to match the test merchant code
          productPrice: amount.toInt().toString(), 
          callbackUrl: "https://your-backend.com/api/payment/verify", 
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult result) {
          debugPrint("✅ eSewa Success: ${result.refId}");
          onSuccess(result);
        },
        onPaymentFailure: () => onFailure(),
        onPaymentCancellation: () => onFailure(),
      );
    } catch (e) {
      onFailure();
    }
  }
}