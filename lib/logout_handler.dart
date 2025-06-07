import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../providers/auth_service.dart';

Future<void> handleLogout() async {
  try {
    final authService = Get.find<AuthService>();
    await authService.logout();

    print('Logout successful, navigating to Welcome'); // Debug print

    // Navigate to welcome screen and clear all previous routes
    Get.offAllNamed('/Welcome');

    // Optional: Show success message
    Get.snackbar(
      'Success',
      'You have been logged out successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    print('Logout error: $e'); // Debug print

    // Show error message
    Get.snackbar(
      'Error',
      'Logout failed: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}