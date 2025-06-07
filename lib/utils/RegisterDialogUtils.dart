import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
                buttonText ?? 'Done',
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

  // FIXED: Registration success dialog with proper navigation
  static Future<void> showRegistrationSuccessDialog({
    VoidCallback? onContinue,
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
          'Registration Successful!',
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
              'Your account has been created successfully! You can now sign in with your credentials.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can verify your account through our Telegram bot later to activate additional features.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onContinue ?? () {
                Get.back();
                Get.offAllNamed('/Login');
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text('Continue to Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                const url = 'https://t.me/SignLanguageG27_Bot';
                try {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                } catch (e) {
                  debugPrint('Could not launch Telegram: $e');
                }
                // Still navigate to login after attempting to open Telegram
                Get.back();
                Get.offAllNamed('/Login');
              },
              icon: const Icon(Icons.telegram_rounded),
              label: const Text('Verify on Telegram & Login'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
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
