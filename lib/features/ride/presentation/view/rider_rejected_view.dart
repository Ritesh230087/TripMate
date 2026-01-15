import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/features/profile/domain/entity/profile_entity.dart';
import 'package:tripmate/features/ride/presentation/view/rider_verification_view.dart';
import 'package:tripmate/features/ride/presentation/view_model/rider_kyc_view_model.dart';

class RiderRejectedView extends StatelessWidget {
  final ProfileEntity user;
  const RiderRejectedView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_outlined, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text("Application Rejected", style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            Text("Your rider application was rejected by the admin.", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
              child: Column(
                children: [
                  Text("Reason:", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 8),
                  Text(user.kycRejectionReason ?? "Document not clear.", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Verification View to Edit/Resubmit with ViewModel Provided
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) => serviceLocator<RiderKycViewModel>(),
                        child: RiderVerificationView(currentUser: user),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B4513), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Edit & Re-Submit", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}