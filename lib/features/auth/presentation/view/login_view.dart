import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/features/auth/presentation/view_model/login_viewmodel/login_event.dart';
import 'package:tripmate/features/auth/presentation/view_model/login_viewmodel/login_state.dart';
import 'package:tripmate/features/auth/presentation/view_model/login_viewmodel/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                
                // Logo
                Image.asset('assets/logo/TripMate_Logo.png', height: 160),
                
                const SizedBox(height: 12),
                Text(
                  "TripMate",
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6D5D42),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Connecting Rides, Connecting People",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9B8B77),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 45),

                // Heading
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome Back",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Email Label & Input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Email",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8D5C4), width: 1),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFB8956D), size: 24),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    style: GoogleFonts.inter(fontSize: 15, color: Color(0xFF1A1A1A)),
                    validator: (value) => value!.isEmpty ? "Enter email" : null,
                  ),
                ),
                const SizedBox(height: 18),

                // Password Label & Input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Password",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8D5C4), width: 1),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
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
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    style: GoogleFonts.inter(fontSize: 15, color: Color(0xFF1A1A1A)),
                    validator: (value) => value!.isEmpty ? "Enter password" : null,
                  ),
                ),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, 
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      "Forgot Password?", 
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8B4513), 
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Login Button
                BlocBuilder<LoginViewModel, LoginState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<LoginViewModel>().add(LoginUserEvent(
                                  context: context,
                                  email: _emailController.text,
                                  password: _passwordController.text,
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
                                "Login", 
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
                
                const SizedBox(height: 28),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: const Color(0xFFD9CEC0))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        "or", 
                        style: GoogleFonts.inter(color: const Color(0xFF8B8B8B), fontSize: 14),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: const Color(0xFFD9CEC0))),
                  ],
                ),
                const SizedBox(height: 28),

                // Google Sign In
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE8D5C4), width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/google_logo.png', height: 20, width: 20,
                          errorBuilder: (c,o,s) => const Icon(Icons.g_mobiledata, color: Colors.red, size: 22),),
                        const SizedBox(width: 12),
                        Text(
                          "Sign in with Google", 
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1A1A1A), 
                            fontSize: 15, 
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Create Account Link
                RichText(
                  text: TextSpan(
                    text: "New here? ",
                    style: GoogleFonts.inter(color: const Color(0xFF6B6B6B), fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Create Account",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8B4513), 
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.read<LoginViewModel>().add(NavigateToRegisterEvent(context: context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}