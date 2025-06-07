import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Core Colors (keeping your existing colors)
  static const Color primaryColor = Color(0xFF2196F3);    // Vibrant Blue
  static const Color secondaryColor = Color(0xFF03A9F4);  // Light Blue
  static const Color accentColor = Color(0xFF00BCD4);     // Cyan
  static const Color successColor = Color(0xFF4CAF50);    // Green
  static const Color errorColor = Color(0xFFE53935);      // Red
  static const Color warningColor = Color(0xFFFFB300);    // Amber

  // Light Theme Colors - Enhanced for better visibility
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF2D3748);
  static const Color lightSubtext = Color(0xFF718096);
  static const Color lightOutline = Color(0xFFE2E8F0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A202C);
  static const Color darkSurface = Color(0xFF2D3748);
  static const Color darkText = Color(0xFFF7FAFC);
  static const Color darkSubtext = Color(0xFFA0AEC0);
  static const Color darkOutline = Color(0xFF4A5568);

  static const String fontName = 'Roboto';

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  );

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 32,
    letterSpacing: -0.5,
    color: lightText,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 28,
    letterSpacing: -0.5,
    color: lightText,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: -0.5,
    color: lightText,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    letterSpacing: 0.15,
    color: lightText,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 18,
    letterSpacing: 0.15,
    color: lightText,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: 0.15,
    color: lightText,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 0.15,
    color: lightText,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    letterSpacing: 0.15,
    color: lightSubtext,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.15,
    color: lightText,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.15,
    color: lightSubtext,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.15,
    color: lightSubtext,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 0.15,
    color: lightText,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    letterSpacing: 0.15,
    color: lightSubtext,
  );

  // Light Theme - Enhanced for better button visibility
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    textTheme: textTheme,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightSurface,
      background: lightBackground,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightText,
      onBackground: lightText,
      onError: Colors.white,
      outline: lightOutline,
      surfaceVariant: Color(0xFFF1F5F9),
      onSurfaceVariant: lightText,
      shadow: Color(0xFF000000),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: lightSurface,
      foregroundColor: lightText,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: lightText,
      ),
      iconTheme: IconThemeData(color: lightText),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
      color: lightSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shadowColor: primaryColor.withOpacity(0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  // Dark Theme - Enhanced
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    textTheme: textTheme.apply(bodyColor: darkText, displayColor: darkText),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurface,
      background: darkBackground,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkText,
      onBackground: darkText,
      onError: Colors.white,
      outline: darkOutline,
      surfaceVariant: Color(0xFF4A5568),
      onSurfaceVariant: darkText,
      shadow: Color(0xFF000000),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: darkSurface,
      foregroundColor: darkText,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: darkText,
      ),
      iconTheme: IconThemeData(color: darkText),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: darkSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shadowColor: primaryColor.withOpacity(0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  // Gradient Decorations (keeping your existing gradients)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
