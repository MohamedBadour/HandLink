import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class ThemeSwitchWidget extends StatelessWidget {
  final bool showLabel;
  final double iconSize;

  const ThemeSwitchWidget({
    Key? key,
    this.showLabel = true,
    this.iconSize = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      return GestureDetector(
        onTap: () => themeController.toggleTheme(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                themeController.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: iconSize,
                color: colorScheme.primary,
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  themeController.isDarkMode ? 'Dark' : 'Light',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => themeController.toggleTheme(),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: child,
              );
            },
            child: Icon(
              themeController.isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              key: ValueKey(themeController.isDarkMode),
              color: colorScheme.primary,
            ),
          ),
          tooltip: themeController.isDarkMode
              ? 'Switch to Light Mode'
              : 'Switch to Dark Mode',
        ),
      );
    });
  }
}
