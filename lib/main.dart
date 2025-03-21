import 'package:flutter/material.dart';
import 'package:handlink/providers/auth_service.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/theme.dart';
import 'screens/model.dart';
import 'screens/aboutus.dart';
import 'package:get/get.dart';

void main() {
  Get.put(AuthService()); // Singleton AuthService
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Use GetMaterialApp instead of MaterialApp
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme(context),
      darkTheme: ThemeConfig.darkTheme(context),
      initialRoute: '/Welcome',
      routes: {
        '/Welcome': (context) => const WelcomeScreen(),
        '/Login': (context) => const LoginPage(),
        '/Register': (context) => const RegisterPage(),
        '/Model': (context) => const ModelPage(),
        '/AboutUs': (context) => const AboutUsPage(),
      },
    );
  }
}
