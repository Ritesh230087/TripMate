import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tripmate/app/service_locator/service_locator.dart';
import 'package:tripmate/app/shared_pref/token_shared_pref.dart';
import 'package:tripmate/features/auth/presentation/view/login_view.dart';
import 'package:tripmate/features/home/presentation/view/home_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: const Offset(1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNext();
      }
    });
  }

  // ✅ AUTO-LOGIN LOGIC
  void _navigateToNext() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    
    final tokenPrefs = serviceLocator<TokenSharedPrefs>();
    final tokenResult = await tokenPrefs.getToken();
    
    // Check if token exists and is not empty
    bool isLoggedIn = false;
    tokenResult.fold((failure) => isLoggedIn = false, (token) => isLoggedIn = token.isNotEmpty);

    if (!mounted) return;

    // Decide destination
    Widget destination = isLoggedIn ? const HomeView() : const LoginView();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0, right: 0,
            child: Column(
              children: [
                Text("TripMate", style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w900, color: const Color(0xFF6D5D42), letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text("Connecting Rides, Connecting People", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF8B4513))),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: 300, width: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 60,
                    child: Container(width: screenWidth, height: 6, decoration: BoxDecoration(color: const Color(0xFF8B4513).withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
                  ),
                  SlideTransition(
                    position: _offsetAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: SizedBox(height: 200, width: 300, child: Lottie.asset('assets/animations/motorcycle.json', fit: BoxFit.contain)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}