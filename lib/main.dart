import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/theme_controller.dart';
import 'controllers/prediction_controller.dart';
import 'screens/app_theme.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/model.dart';
import 'screens/about_us.dart';
import 'screens/forgot_password.dart';
import 'screens/verification.dart';
import 'screens/reset_password.dart';
import 'screens/telegram_connect.dart';
import 'screens/user_profile.dart';
import 'screens/edit_profile.dart';
import 'screens/prediction_history.dart';
import 'providers/auth_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style to match your app theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF2196F3), // Your primary color
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF2196F3),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize controllers immediately without delay
  Get.put(ThemeController());
  Get.put(AuthService());
  Get.put(PredictionController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      title: 'HandLink',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,

      // Start directly with splash screen
      initialRoute: '/Splash',

      // Route definitions
      getPages: [
        GetPage(
          name: '/Splash',
          page: () => const SplashScreen(),
          transition: Transition.noTransition, // Remove transition delay
          transitionDuration: Duration.zero,   // No transition duration
        ),
        GetPage(
          name: '/Welcome',
          page: () => const WelcomeScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/Login',
          page: () => const LoginPage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/Register',
          page: () => const RegisterPage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/Model',
          page: () => const ModelPage(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/AboutUs',
          page: () => const AboutUsPage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/ForgotPassword',
          page: () => const ForgotPasswordPage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/Verify',
          page: () => const VerifyPage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/ResetPassword',
          page: () => ResetPasswordPage(
            identifier: Get.arguments?['identifier'] ?? '',
          ),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/TelegramConnect',
          page: () => const TelegramConnectPage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/UserProfile',
          page: () => const UserProfilePage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/EditProfile',
          page: () => const EditProfilePage(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/PredictionHistory',
          page: () => const PredictionHistoryScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ],

      unknownRoute: GetPage(
        name: '/not_found',
        page: () => const WelcomeScreen(),
      ),
    ));
  }
}