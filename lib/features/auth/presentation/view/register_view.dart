import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_event.dart';
import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_state.dart';
import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  
  String? _gender;
  File? _image;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _pickImage(ImageSource source) async {
    await (source == ImageSource.camera ? Permission.camera : Permission.photos).request();
    
    try {
      final img = await ImagePicker().pickImage(source: source);
      if (img != null) {
        setState(() => _image = File(img.path));
      }
    } catch (e) {
      debugPrint("Image Picker Error: $e");
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFBF5),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF8B4513)),
              title: Text("Gallery", style: GoogleFonts.inter()),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF8B4513)),
              title: Text("Camera", style: GoogleFonts.inter()),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    IconData? icon,
    Color? iconColor,
    Widget? prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8D5C4), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: prefixIcon ?? Icon(icon, color: iconColor ?? const Color(0xFFB8956D), size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF1A1A1A)),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Back", style: GoogleFonts.inter(color: const Color(0xFF8B4513), fontSize: 16, fontWeight: FontWeight.w500)),
        titleSpacing: -10,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create Account", style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
              Text("Join TripMate Community", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7B7B7B), fontWeight: FontWeight.w400)),
              const SizedBox(height: 28),

              _buildLabel("Full Name"),
              _buildInputField(
                controller: _nameController,
                icon: Icons.person,
                iconColor: const Color(0xFFB8956D),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Email"),
              _buildInputField(
                controller: _emailController,
                icon: Icons.email_outlined,
                iconColor: const Color(0xFFB8956D),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              _buildLabel("Phone"),
              _buildInputField(
                controller: _phoneController,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone, color: Color(0xFFB8956D), size: 20),
                      const SizedBox(width: 8),
                      Image.network('https://flagcdn.com/w40/np.png', width: 24, height: 16, errorBuilder: (c,o,s) => const Icon(Icons.flag, size: 16)),
                      const SizedBox(width: 4),
                      Text("+977", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(height: 20, width: 1, color: Colors.grey[300]),
                    ],
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 10 ? "Invalid Phone" : null,
              ),
              const SizedBox(height: 16),

              // Password with Eye Icon
              _buildLabel("Password"),
              _buildInputField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: Color(0xFFBB8D6C), shape: BoxShape.circle),
                    child: const Icon(Icons.lock, size: 12, color: Colors.white),
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFFB8956D)),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
              ),
              const SizedBox(height: 16),

              // Confirm Password with Eye Icon
              _buildLabel("Confirm Password"),
              _buildInputField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: Color(0xFFBB8D6C), shape: BoxShape.circle),
                    child: const Icon(Icons.lock, size: 12, color: Colors.white),
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFFB8956D)),
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
                validator: (v) => v != _passwordController.text ? "Mismatch" : null,
              ),
              const SizedBox(height: 16),

              // Gender
              _buildLabel("Gender"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8D5C4), width: 1),
                ),
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Color(0xFFB8956D), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF1A1A1A)),
                  dropdownColor: const Color(0xFFFFFBF5),
                  hint: Text("Select Gender", style: GoogleFonts.inter(color: Colors.grey)),
                  items: ["Male", "Female", "Other"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 15)))).toList(),
                  onChanged: (v) => setState(() => _gender = v),
                ),
              ),
              const SizedBox(height: 16),

              // Date of Birth (Right Icon Brown)
              _buildLabel("Date of Birth"),
              _buildInputField(
                controller: _dobController,
                icon: Icons.calendar_month, // Left Brown
                iconColor: const Color(0xFF8B4513),
                readOnly: true,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF8B4513)), // Right Brown
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(primary: Color(0xFF8B4513), onPrimary: Colors.white, onSurface: Colors.black),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
                },
              ),
              const SizedBox(height: 16),

              // Profile Picture (Preview Image or Upload Button)
              _buildLabel("Profile Picture (optional)"),
              _image == null 
                ? Container(
                    height: 56,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE8D5C4), width: 1)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: Color(0xFFB8956D), size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text("Upload Profile Picture", style: GoogleFonts.inter(color: const Color(0xFF8B8B8B), fontSize: 15))),
                        ElevatedButton(
                          onPressed: _showImageSourceSheet,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEBDCC8), foregroundColor: const Color(0xFF6B4E3D), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), minimumSize: const Size(75, 32)),
                          child: Text("Capture", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8D5C4), width: 1),
                      image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 5, right: 5,
                          child: GestureDetector(
                            onTap: () => setState(() => _image = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

              const SizedBox(height: 28),

              // Create Account Button
              BlocBuilder<RegisterViewModel, RegisterState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_passwordController.text != _confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
                            return;
                          }
                          context.read<RegisterViewModel>().add(RegisterUserEvent(
                                context: context,
                                fullName: _nameController.text,
                                email: _emailController.text,
                                phone: _phoneController.text,
                                password: _passwordController.text,
                                gender: _gender ?? "Male",
                                dob: _dobController.text,
                                image: _image,
                              ));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B4513), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: state.isLoading 
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5) 
                          : Text("Create Account", style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2D2D2D))),
    );
  }
}