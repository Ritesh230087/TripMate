// import 'dart:io';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_event.dart';
// import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_state.dart';
// import 'package:tripmate/features/auth/presentation/view_model/register_viewmodel/register_viewmodel.dart';

// class RegisterView extends StatefulWidget {
//   const RegisterView({super.key});

//   @override
//   State<RegisterView> createState() => _RegisterViewState();
// }

// class _RegisterViewState extends State<RegisterView> {
//   final _formKey = GlobalKey<FormState>();
  
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _dobController = TextEditingController();
  
//   String? _gender;
//   File? _image;

//   Future<void> _pickImage(ImageSource source) async {
//     final status = await (source == ImageSource.camera ? Permission.camera : Permission.photos).request();
//     if (status.isGranted) {
//       final img = await ImagePicker().pickImage(source: source);
//       if (img != null) setState(() => _image = File(img.path));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F1E8), // Exact background color
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF7D4E2A)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Back", 
//           style: GoogleFonts.inter(
//             color: const Color(0xFF7D4E2A), 
//             fontSize: 16, 
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         titleSpacing: -10,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Create Account", 
//                 style: GoogleFonts.inter(
//                   fontSize: 28, 
//                   fontWeight: FontWeight.w700, 
//                   color: const Color(0xFF2B2B2B),
//                 ),
//               ),
//               Text(
//                 "Join TripMate Community", 
//                 style: GoogleFonts.inter(
//                   fontSize: 14, 
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               const SizedBox(height: 30),

//               // Full Name
//               _buildLabel("Full Name"),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.person, color: Color(0xFFC4A07A), size: 22),
//                   filled: true,
//                   fillColor: Color(0xFFFCFAF7),
//                 ),
//                 style: GoogleFonts.inter(fontSize: 15, color: Color(0xFF2B2B2B)),
//                 validator: (v) => v!.isEmpty ? "Required" : null,
//               ),
//               const SizedBox(height: 16),

//               // Email
//               _buildLabel("Email"),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFC4A07A), size: 22),
//                   filled: true,
//                   fillColor: Color(0xFFFCFAF7),
//                 ),
//                 style: GoogleFonts.inter(fontSize: 15, color: Color(0xFF2B2B2B)),
//                 validator: (v) => v!.isEmpty ? "Required" : null,
//               ),
//               const SizedBox(height: 16),

//               // Phone
//               _buildLabel("Phone"),
//               TextFormField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.phone, color: Color(0xFFC4A07A), size: 22),
//                   filled: true,
//                   fillColor: Color(0xFFFCFAF7),
//                 ),
//                 style: GoogleFonts.inter(fontSize: 15, color: Color(0xFF2B2B2B)),
//                 validator: (v) => v!.isEmpty ? "Required" : null,
//               ),
//               const SizedBox(height: 16),

//               // Password with Lock Circle
//               _buildLabel("Password"),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Container(
//                       width: 24,
//                       height: 24,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFB8856D),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.lock, size: 14, color: Colors.white),
//                     ),
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFFFCFAF7),
//                 ),
//                 style: GoogleFonts.inter(fontSize: 15, color: Color(0xFF2B2B2B)),
//                 validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
//               ),
//               const SizedBox(height: 16),

//               // Confirm Password with Lock Circle
//               _buildLabel("Confirm Password"),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   prefixIcon: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Container(
//                       width: 24,
//                       height: 24,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFFB8856D),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.lock, size: 14, color: Colors.white),
//                     ),
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFFFCFAF7),
//                 ),
//                 style: GoogleFonts.inter(fontSize: 15, color: Color(0xFF2B2B2B)),
//                 validator: (v) => v != _passwordController.text ? "Mismatch" : null,
//               ),
//               const SizedBox(height: 16),

//               // Gender Dropdown
//               _buildLabel("Gender"),
//               DropdownButtonFormField<String>(
//                 value: _gender,
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.person, color: Color(0xFFC4A07A), size: 22),
//                   filled: true,
//                   fillColor: Color(0xFFFCFAF7),
//                 ),
//                 style: GoogleFonts.inter(fontSize: 15, color: Color(0xFF2B2B2B)),
//                 dropdownColor: const Color(0xFFFCFAF7),
//                 items: ["Male", "Female", "Other"]
//                     .map((e) => DropdownMenuItem(
//                           value: e, 
//                           child: Text(e, style: GoogleFonts.inter(fontSize: 15)),
//                         ))
//                     .toList(),
//                 onChanged: (v) => setState(() => _gender = v),
//               ),
//               const SizedBox(height: 16),

//               // Date of Birth
//               _buildLabel("Date of Birth"),
//               TextFormField(
//                 controller: _dobController,
//                 readOnly: true,
//                 onTap: () async {
//                   DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime(2000),
//                     firstDate: DateTime(1950),
//                     lastDate: DateTime.now(),
//                     builder: (context, child) {
//                       return Theme(
//                         data: ThemeData.light().copyWith(
//                           colorScheme: const ColorScheme.light(
//                             primary: Color(0xFF7D4E2A),
//                             onPrimary: Colors.white,
//                             onSurface: Colors.black,
//                           ),
//                         ),
//                         child: child!,
//                       );
//                     },
//                   );
//                   if (picked != null) {
//                     _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
//                   }
//                 },
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.calendar_today_outlined, color: Color(0xFFC4A07A), size: 20),
//                   suffixIcon: Icon(Icons.calendar_month_outlined, size: 20, color: Colors.grey),
//                   filled: true,
//                   fillColor: Color(0xFFFCFAF7),
//                 ),
//                 style: GoogleFonts.inter(fontSize: 15, color: Color(0xFF2B2B2B)),
//               ),
//               const SizedBox(height: 16),

//               // Profile Picture Upload
//               _buildLabel("Profile Picture (optional)"),
//               Container(
//                 height: 55,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFCFAF7),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: const Color(0xFFE8E0D5)),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.camera_alt_outlined, color: Color(0xFFC4A07A), size: 22),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         _image == null ? "Upload Profile Picture" : "Image Selected",
//                         style: GoogleFonts.inter(
//                           color: const Color(0xFF7B7B7B), 
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => _pickImage(ImageSource.gallery),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFE8D4C0),
//                         foregroundColor: const Color(0xFF6B4E3D),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//                         minimumSize: const Size(80, 32),
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//                       ),
//                       child: Text(
//                         "Capture", 
//                         style: GoogleFonts.inter(
//                           fontSize: 13, 
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (_image != null) 
//                 Padding(
//                   padding: const EdgeInsets.only(top: 5), 
//                   child: Text(
//                     _image!.path.split('/').last, 
//                     style: const TextStyle(fontSize: 12, color: Colors.green),
//                   ),
//                 ),

//               const SizedBox(height: 30),

//               // Create Account Button
//               BlocBuilder<RegisterViewModel, RegisterState>(
//                 builder: (context, state) {
//                   return SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           context.read<RegisterViewModel>().add(RegisterUserEvent(
//                                 context: context,
//                                 fullName: _nameController.text,
//                                 email: _emailController.text,
//                                 phone: _phoneController.text,
//                                 password: _passwordController.text,
//                                 gender: _gender ?? "Male",
//                                 dob: _dobController.text,
//                                 image: _image,
//                               ));
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF7D4E2A),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                       child: state.isLoading 
//                           ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5) 
//                           : Text(
//                               "Create Account", 
//                               style: GoogleFonts.inter(
//                                 fontSize: 18, 
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 20),
              
//               // Login Link
//               Center(
//                 child: RichText(
//                   text: TextSpan(
//                     text: "Already have an account?",
//                     style: GoogleFonts.inter(color: const Color(0xFF6B6B6B), fontSize: 15),
//                     children: [
//                       TextSpan(
//                         text: "Login",
//                         style: GoogleFonts.inter(
//                           color: const Color(0xFF7D4E2A), 
//                           fontWeight: FontWeight.w600,
//                           fontSize: 15,
//                         ),
//                         recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Text(
//         text, 
//         style: GoogleFonts.inter(
//           fontSize: 15, 
//           fontWeight: FontWeight.w600, 
//           color: const Color(0xFF3D3D3D),
//         ),
//       ),
//     );
//   }
// }









































import 'dart:io';
import 'package:flutter/gestures.dart';
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

  Future<void> _pickImage(ImageSource source) async {
    final status = await (source == ImageSource.camera ? Permission.camera : Permission.photos).request();
    if (status.isGranted) {
      final img = await ImagePicker().pickImage(source: source);
      if (img != null) setState(() => _image = File(img.path));
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
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
        title: Text(
          "Back", 
          style: GoogleFonts.inter(
            color: const Color(0xFF8B4513), 
            fontSize: 16, 
            fontWeight: FontWeight.w500,
          ),
        ),
        titleSpacing: -10,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account", 
                style: GoogleFonts.inter(
                  fontSize: 26, 
                  fontWeight: FontWeight.w700, 
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                "Join TripMate Community", 
                style: GoogleFonts.inter(
                  fontSize: 13, 
                  color: const Color(0xFF7B7B7B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),

              // Full Name
              _buildLabel("Full Name"),
              _buildInputField(
                controller: _nameController,
                icon: Icons.person,
                iconColor: const Color(0xFFB8956D),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Email
              _buildLabel("Email"),
              _buildInputField(
                controller: _emailController,
                icon: Icons.email_outlined,
                iconColor: const Color(0xFFB8956D),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Phone
              _buildLabel("Phone"),
              _buildInputField(
                controller: _phoneController,
                icon: Icons.phone,
                iconColor: const Color(0xFFB8956D),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Password
              _buildLabel("Password"),
              _buildInputField(
                controller: _passwordController,
                icon: Icons.lock,
                obscureText: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBB8D6C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, size: 12, color: Colors.white),
                  ),
                ),
                validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _buildLabel("Confirm Password"),
              _buildInputField(
                controller: _confirmPasswordController,
                icon: Icons.lock,
                obscureText: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBB8D6C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, size: 12, color: Colors.white),
                  ),
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
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF1A1A1A)),
                  dropdownColor: const Color(0xFFFFFBF5),
                  items: ["Male", "Female", "Other"]
                      .map((e) => DropdownMenuItem(
                            value: e, 
                            child: Text(e, style: GoogleFonts.inter(fontSize: 15)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _gender = v),
                ),
              ),
              const SizedBox(height: 16),

              // Date of Birth
              _buildLabel("Date of Birth"),
              _buildInputField(
                controller: _dobController,
                icon: Icons.calendar_today_outlined,
                iconColor: const Color(0xFFB8956D),
                readOnly: true,
                suffixIcon: const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.grey),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF8B4513),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Profile Picture
              _buildLabel("Profile Picture (optional)"),
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white
                  
                  ,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8D5C4), width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt_outlined, color: Color(0xFFB8956D), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _image == null ? "Upload Profile Picture" : "Image Selected",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8B8B8B), 
                          fontSize: 15,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBDCC8),
                        foregroundColor: const Color(0xFF6B4E3D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        minimumSize: const Size(75, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                      ),
                      child: Text(
                        "Capture", 
                        style: GoogleFonts.inter(
                          fontSize: 13, 
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_image != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 5), 
                  child: Text(
                    _image!.path.split('/').last, 
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.green),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: state.isLoading 
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5) 
                          : Text(
                              "Create Account", 
                              style: GoogleFonts.inter(
                                fontSize: 17, 
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              
              // Login Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: GoogleFonts.inter(color: const Color(0xFF6B6B6B), fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8B4513), 
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text, 
        style: GoogleFonts.inter(
          fontSize: 14, 
          fontWeight: FontWeight.w600, 
          color: const Color(0xFF2D2D2D),
        ),
      ),
    );
  }
}