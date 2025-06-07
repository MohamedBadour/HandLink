import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:HandLink/main.dart';
import 'package:HandLink/controllers/theme_controller.dart';
import 'package:HandLink/providers/auth_service.dart';

void main() {
  setUpAll(() {
    // Initialize GetX controllers before all tests
    Get.put(ThemeController());
    Get.put(AuthService());
  });

  testWidgets('App shows splash screen on startup', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen is shown
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('HandLink'), findsOneWidget);
    expect(find.byIcon(Icons.sign_language), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}