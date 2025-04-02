import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handlink/providers/auth_service.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/theme.dart';
import 'screens/model.dart';
import 'screens/aboutus.dart';
import 'screens/forgetpassword.dart';
import 'screens/verification.dart';
import 'screens/resetpassword.dart';

void main() {
  Get.put(AuthService()); // Singleton AuthService
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Use GetMaterialApp for GetX
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme(context),
      darkTheme: ThemeConfig.darkTheme(context),
      initialRoute: '/Welcome',
      getPages: [
        GetPage(name: '/Welcome', page: () => const WelcomeScreen()),
        GetPage(name: '/Login', page: () => const LoginPage()),
        GetPage(name: '/Register', page: () => const RegisterPage()),
        GetPage(name: '/Model', page: () => const ModelPage()),
        GetPage(name: '/AboutUs', page: () => const AboutUsPage()),
        GetPage(name: '/ForgetPassword', page: () => ForgotPasswordPage()),
        GetPage(name: '/Verify', page: () => VerifyPage()),
        GetPage(name: '/ResetPassword', page: () => ResetPasswordPage()),
      ],
    );
  }
}