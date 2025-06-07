import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogUtils {
  static Future<void> showSuccessDialog({
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    final theme = Theme.of(Get.context!);
    final colorScheme = theme.colorScheme;

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed ?? () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                buttonText ?? 'OK',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> showErrorDialog({
    required String title,
    required String message,
  }) async {
    final theme = Theme.of(Get.context!);
    final colorScheme = theme.colorScheme;

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_rounded,
                color: colorScheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'OK',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showLoginSuccessDialog() async {
    final theme = Theme.of(Get.context!);
    final colorScheme = theme.colorScheme;

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          'Login Successful!',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome back! You have successfully logged into your account.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Continue',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> showNetworkErrorDialog({
    required String message,
    required VoidCallback onRetry,
  }) async {
    final theme = Theme.of(Get.context!);
    final colorScheme = theme.colorScheme;

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          'Connection Error',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: colorScheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    onRetry();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Retry',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}