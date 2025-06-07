import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/theme_controller.dart';
import 'controllers/prediction_controller.dart';
import 'screens/app_theme.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/model.dart';
import 'screens/aboutus.dart';
import 'screens/forgetpassword.dart';
import 'screens/verification.dart';
import 'screens/reset_password.dart';
import 'screens/telegramconnect.dart';
import 'screens/sign_language_chat_screen.dart';
import 'screens/user_profile.dart';
import 'screens/prediction_history_screen.dart';
import 'providers/auth_service.dart';

void main() async {
  // Ensure Flutter binding is initialized before accessing platform-specific APIs
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(ThemeController());
  Get.put(AuthService());
  Get.put(PredictionController());

  // Run app without checking login state here
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme controller
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      title: 'HandLink',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,

      // Use a splash screen as initial route to check login state
      initialRoute: '/Splash',

      // Route definitions
      getPages: [
        GetPage(
          name: '/Splash',
          page: () => const SplashScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
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
          name: '/Chatbot',
          page: () => const SignLanguageChatScreen(),
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
          name: '/PredictionHistory',
          page: () => const PredictionHistoryScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ],

      // Default transition for unknown routes
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const WelcomeScreen(),
      ),
    ));
  }
}

// Splash Screen to check login state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    try {
      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 1500));

      final authService = Get.find<AuthService>();

      // Force a thorough login check
      final isLoggedIn = await authService.isLoggedIn();

      print('SplashScreen - Login check result: $isLoggedIn'); // Debug print

      // Double-check by verifying stored data
      final prefs = await SharedPreferences.getInstance();
      final storedLoginState = prefs.getBool('isLoggedIn') ?? false;
      final hasEmail = prefs.getString('login_email') != null;
      final appState = prefs.getString('app_state') ?? '';

      print('SplashScreen - Stored login: $storedLoginState, hasEmail: $hasEmail, appState: $appState');

      // Navigate based on login state with extra verification
      if (isLoggedIn && storedLoginState && hasEmail && appState != 'logged_out') {
        print('SplashScreen - Navigating to Model (logged in)');
        Get.offAllNamed('/Model');
      } else {
        print('SplashScreen - Navigating to Welcome (not logged in)');
        // Ensure we're in logged out state
        await prefs.setString('app_state', 'logged_out');
        await prefs.setBool('isLoggedIn', false);
        Get.offAllNamed('/Welcome');
      }
    } catch (e) {
      print('Error checking login state: $e');
      // If there's an error, go to welcome screen and clear any login state
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        await prefs.setString('app_state', 'logged_out');
      } catch (e2) {
        print('Error clearing login state: $e2');
      }
      Get.offAllNamed('/Welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Icon(
              Icons.sign_language,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            // App name
            Text(
              'HandLink',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
