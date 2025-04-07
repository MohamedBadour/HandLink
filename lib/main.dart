import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/model.dart';
import 'screens/aboutus.dart';
import 'screens/forgetpassword.dart';
import 'screens/verification.dart';
import 'screens/reset_password.dart';
import 'screens/Telegramconnect.dart';
import 'providers/auth_service.dart';
import 'screens/theme.dart';

void main() {
  Get.put(AuthService()); // Initialize AuthService
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme(context),
      darkTheme: ThemeConfig.darkTheme(context),
      initialRoute: '/Welcome',
      getPages: [
        GetPage(
          name: '/Welcome',
          page: () => const WelcomeScreen(),
        ),
        GetPage(
          name: '/Login',
          page: () => const LoginPage(),
        ),
        GetPage(
          name: '/Register',
          page: () => const RegisterPage(),
        ),
        GetPage(
          name: '/Model',
          page: () => const ModelPage(),
        ),
        GetPage(
          name: '/AboutUs',
          page: () => const AboutUsPage(),
        ),
        GetPage(
          name: '/ForgotPassword',
          page: () => const ForgotPasswordPage(),
        ),
        GetPage(
          name: '/Verify',
          page: () => const VerifyPage(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/ResetPassword',
          page: () => ResetPasswordPage(
            identifier: Get.arguments?['identifier'] ?? '',
          ),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/TelegramConnect',
          page: () => const TelegramConnectPage(),
        ),
      ],
    );
  }
}