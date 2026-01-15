import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  bool _isSuccess = false; 
  bool _isLoading = false;

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await serviceLocator<AuthRemoteDataSource>().forgotPassword(email);
      setState(() => _isSuccess = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      resizeToAvoidBottomInset: true, // Fixes overflow when keyboard opens
      body: SafeArea(
        child: SingleChildScrollView( // Fixes RenderFlex overflow
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 40),
              
              // Lock Icon Header
              Container(
                height: 60, width: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2E8DA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lock_outline, color: Color(0xFF8B4513), size: 30),
              ),
              const SizedBox(height: 24),
              
              Text(
                "Forgot\nPassword?",
                style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A1A), height: 1.1),
              ),
              const SizedBox(height: 12),
              Text(
                "Don't worry! Enter your email linked\nto your account.",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 40),
              
              // Main Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: _isSuccess ? _buildSuccessContent() : _buildInputContent(),
              ),
              const SizedBox(height: 40), // Extra space for keyboard
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Email Address", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              icon: const Icon(Icons.email_outlined, color: Color(0xFF8B4513), size: 20),
              hintText: "hello@example.com",
              hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text("Send Reset Code", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Color(0xFF2E7D32), size: 32),
        ),
        const SizedBox(height: 20),
        Text("Check your inbox", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 12),
        Text(
          "We have sent a password reset\nlink to your email address.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600], height: 1.4),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0F0F0),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text("Back to Login", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}