import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/features/auth/data/data_source/remote_data_source/auth_remote_data_source.dart';

class ResetPasswordView extends StatefulWidget {
  final String token;
  const ResetPasswordView({super.key, required this.token});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSuccess = false;
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _handleResetPassword() async {
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.red);
      return;
    }
    if (pass.length < 6) {
      _showSnackBar("Password must be at least 6 characters", Colors.red);
      return;
    }
    if (pass != confirm) {
      _showSnackBar("Passwords do not match", Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await serviceLocator<AuthRemoteDataSource>().resetPassword(widget.token, pass);
      setState(() => _isSuccess = true);
    } catch (e) {
      _showSnackBar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9), // Beige Theme
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Back Button
              _buildRoundButton(Icons.arrow_back, () => Navigator.pop(context)),
              const SizedBox(height: 40),

              // Key Icon Header
              _buildIconHeader(Icons.vpn_key_outlined),
              const SizedBox(height: 24),

              Text(
                "Create New\nPassword",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Your new password must be different\nfrom previously used passwords.",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 40),

              // Card Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: _isSuccess ? _buildSuccessUI() : _buildInputUI(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("New Password"),
        _buildPasswordField(_passwordController, "••••••••"),
        const SizedBox(height: 20),
        _buildLabel("Confirm Password"),
        _buildPasswordField(_confirmController, "••••••••"),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text("Update Password", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Color(0xFF2E7D32), size: 32),
        ),
        const SizedBox(height: 20),
        Text("Password Updated!", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text("Your password has been changed\nsuccessfully.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock_outline, color: Color(0xFF8B4513), size: 20),
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 18),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildIconHeader(IconData icon) {
    return Container(
      height: 60, width: 60,
      decoration: BoxDecoration(color: const Color(0xFFF2E8DA), borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: const Color(0xFF8B4513), size: 30),
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}