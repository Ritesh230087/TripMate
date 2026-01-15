import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EsewaPaymentSuccessPage extends StatelessWidget {
  final VoidCallback onNext;
  const EsewaPaymentSuccessPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified, color: Color(0xFF00A884), size: 100),
        const SizedBox(height: 24),
        Text("Payment Successful!", 
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF00A884))),
        const SizedBox(height: 12),
        const Text("Your transaction has been verified.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 40),
        SizedBox(
          width: 200, height: 50,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884), shape: StadiumBorder()),
            child: const Text("Done", style: TextStyle(color: Colors.white)),
          ),
        )
      ],
    );
  }
}

class EsewaPaymentFailedPage extends StatelessWidget {
  final VoidCallback onRetry;
  const EsewaPaymentFailedPage({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 100),
        const SizedBox(height: 24),
        Text("Payment Failed", 
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 12),
        const Text("Something went wrong with the transaction.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 40),
        TextButton(
          onPressed: onRetry,
          child: const Text("Try Another Method", style: TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}