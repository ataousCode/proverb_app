// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppTheme {
//   // Colors
//   static const Color primaryColor = Color(0xFF6A5AE0);
//   static const Color secondaryColor = Color(0xFFFF8A65);
//   static const Color backgroundColor = Color(0xFFF5F5F7);
//   static const Color cardColor = Colors.white;
//   static const Color textColor = Color(0xFF1D1617);
//   static const Color subtitleColor = Color(0xFF7B6F72);
//   static const Color errorColor = Color(0xFFFF5252);
//   static const Color successColor = Color(0xFF4CAF50);

//   // Gradients
//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [Color(0xFF9775FA), Color(0xFF6A5AE0)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   // Text Styles
//   static TextStyle headlineStyle = GoogleFonts.poppins(
//     fontSize: 24,
//     fontWeight: FontWeight.bold,
//     color: textColor,
//   );

//   static TextStyle titleStyle = GoogleFonts.poppins(
//     fontSize: 18,
//     fontWeight: FontWeight.w600,
//     color: textColor,
//   );

//   static TextStyle bodyStyle = GoogleFonts.poppins(
//     fontSize: 16,
//     color: textColor,
//   );

//   static TextStyle subtitleStyle = GoogleFonts.poppins(
//     fontSize: 14,
//     color: subtitleColor,
//   );

//   static TextStyle buttonTextStyle = GoogleFonts.poppins(
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     color: Colors.white,
//   );

//   // ThemeData
//   static ThemeData lightTheme = ThemeData(
//     primaryColor: primaryColor,
//     scaffoldBackgroundColor: backgroundColor,
//     colorScheme: ColorScheme.light(
//       primary: primaryColor,
//       secondary: secondaryColor,
//       error: errorColor,
//     ),
//     appBarTheme: AppBarTheme(
//       elevation: 0,
//       color: backgroundColor,
//       iconTheme: IconThemeData(color: textColor),
//       titleTextStyle: titleStyle,
//     ),
//     cardTheme: CardTheme(
//       color: cardColor,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: primaryColor),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: errorColor),
//       ),
//       labelStyle: subtitleStyle,
//       hintStyle: subtitleStyle,
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding: EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         textStyle: buttonTextStyle,
//       ),
//     ),
//     textButtonTheme: TextButtonThemeData(
//       style: TextButton.styleFrom(
//         foregroundColor: primaryColor,
//         textStyle: GoogleFonts.poppins(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors for light theme
  static const Color primaryColorLight = Color(0xFF6A5AE0);
  static const Color backgroundColorLight = Color(0xFFF5F5F7);
  static const Color cardColorLight = Colors.white;
  static const Color textColorLight = Color(0xFF1D1617);

  // Colors for dark theme
  static const Color primaryColorDark = Color(0xFF5BCFC5); // Mint green
  static const Color backgroundColorDark = Color(0xFF1E1E2A); // Dark navy
  static const Color cardColorDark = Color(0xFF2A2A38); // Slightly lighter navy
  static const Color textColorDark = Colors.white;
  static const Color secondaryColorDark = Color(0xFFF16655); // Coral red

  // Text Styles - Light Theme
  static TextStyle headlineStyleLight = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColorLight,
  );

  static TextStyle titleStyleLight = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColorLight,
  );

  static TextStyle bodyStyleLight = GoogleFonts.poppins(
    fontSize: 16,
    color: textColorLight,
  );

  // Text Styles - Dark Theme
  static TextStyle headlineStyleDark = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColorDark,
  );

  static TextStyle titleStyleDark = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColorDark,
  );

  static TextStyle bodyStyleDark = GoogleFonts.poppins(
    fontSize: 16,
    color: textColorDark,
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColorLight,
    scaffoldBackgroundColor: backgroundColorLight,
    cardColor: cardColorLight,
    colorScheme: ColorScheme.light(
      primary: primaryColorLight,
      secondary: Colors.orange,
      background: backgroundColorLight,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColorLight,
      foregroundColor: textColorLight,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardColorLight,
      selectedItemColor: primaryColorLight,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    primaryColor: primaryColorDark,
    scaffoldBackgroundColor: backgroundColorDark,
    cardColor: cardColorDark,
    colorScheme: ColorScheme.dark(
      primary: primaryColorDark,
      secondary: secondaryColorDark,
      background: backgroundColorDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColorDark,
      foregroundColor: textColorDark,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundColorDark,
      selectedItemColor: primaryColorDark,
      unselectedItemColor: Colors.grey,
    ),
  );
}

// import 'package:flutter/material.dart';
// import 'package:proverbs/config/app_colors.dart';

// class AppTheme {
//   static final ThemeData darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     primaryColor: AppColors.primary,
//     scaffoldBackgroundColor: AppColors.background,
//     colorScheme: const ColorScheme.dark(
//       primary: AppColors.primary,
//       secondary: AppColors.secondary,
//       error: AppColors.error,
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: AppColors.background,
//       elevation: 0,
//       centerTitle: true,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: AppColors.inputBackground,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: AppColors.primary),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: AppColors.error),
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.white,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     ),
//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         side: const BorderSide(color: AppColors.primary),
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     ),
//     textButtonTheme: TextButtonThemeData(
//       style: TextButton.styleFrom(foregroundColor: AppColors.primary),
//     ),
//     dividerTheme: const DividerThemeData(color: AppColors.grey, thickness: 0.5),
//     cardTheme: CardTheme(
//       color: AppColors.cardBackground,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//   );
// }
