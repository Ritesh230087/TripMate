// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppTheme {
//   AppTheme._();

//   // Exact Colors from Screenshot
//   static const Color backgroundColor = Color(0xFFF9F5E9); // Correct background
//   static const Color primaryColor = Color(0xFF8B4513);   // Button brown
//   static const Color inputFillColor = Color(0xFFFFFBF5); // Very light cream for text fields
//   static const Color borderColor = Color(0xFFE8D5C4);    // Exact border color
//   static const Color textColor = Color(0xFF1A1A1A);      // Very dark text
//   static const Color labelColor = Color(0xFF2D2D2D);     // Label color
//   static const Color iconColor = Color(0xFFB8956D);      // Brown icons
//   static const Color lockCircleColor = Color(0xFFBB8D6C); // Lock circle brown

//   static ThemeData getApplicationTheme() {
//     return ThemeData(
//       useMaterial3: true,
//       scaffoldBackgroundColor: backgroundColor,
//       primaryColor: primaryColor,
      
//       // Text Theme
//       textTheme: TextTheme(
//         displayLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: textColor),
//         displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: textColor),
//         bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: textColor),
//         bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: textColor),
//         labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
//       ),

//       // Input Decoration - 10px radius, E8D5C4 border
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: inputFillColor,
//         contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: borderColor, width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: borderColor, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: primaryColor, width: 1.5),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.red, width: 1),
//         ),
//         hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 15),
//       ),

//       // Button Theme
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
//           minimumSize: const Size(double.infinity, 52),
//         ),
//       ),
//     );
//   }
// }






























import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Exact Colors from Screenshot
  static const Color backgroundColor = Color(0xFFF9F5E9); // Correct background
  static const Color primaryColor = Color(0xFF8B4513);   // Button brown
  static const Color inputFillColor = Color(0xFFFFFFFF); // Pure white for text fields
  static const Color borderColor = Color(0xFFE8D5C4);    // Exact border color
  static const Color textColor = Color(0xFF1A1A1A);      // Very dark text
  static const Color labelColor = Color(0xFF2D2D2D);     // Label color
  static const Color iconColor = Color(0xFFB8956D);      // Brown icons
  static const Color lockCircleColor = Color(0xFFBB8D6C); // Lock circle brown

  static ThemeData getApplicationTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: textColor),
        displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: textColor),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: textColor),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: textColor),
        labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),

      // Input Decoration - 10px radius, E8D5C4 border
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 15),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }
}