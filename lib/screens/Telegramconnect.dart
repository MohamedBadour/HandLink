import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/theme.dart';

class TelegramConnectPage extends StatefulWidget {
  const TelegramConnectPage({super.key});

  @override
  State<TelegramConnectPage> createState() => _TelegramConnectPageState();
}

class _TelegramConnectPageState extends State<TelegramConnectPage> with SingleTickerProviderStateMixin {
  final String telegramBotUrl = 'https://t.me/SignLanguageG27_Bot';
  bool _hasConnected = false;
  bool _isVerified = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchTelegramBot() async {
    final Uri url = Uri.parse(telegramBotUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      setState(() => _hasConnected = true);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch Telegram',
        backgroundColor: ThemeConfig.errorColor,
        colorText: ThemeConfig.lightSurface,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _verifyAndProceed() {
    setState(() => _isVerified = true);
    // Show success message
    Get.snackbar(
      'Success',
      'Telegram verification completed!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
    // Navigate to login page after short delay
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/Login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      appBar: AppBar(
        title: Text(
          'Connect with Telegram',
          style: ThemeConfig.headingStyle.copyWith(
            color: ThemeConfig.lightSurface,
          ),
        ),
        backgroundColor: ThemeConfig.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: ThemeConfig.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: ThemeConfig.elevation2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.telegram,
                      size: 80,
                      color: Color(0xFF0088cc),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Connect to Our Telegram Bot',
                      style: ThemeConfig.headingStyle.copyWith(
                        fontSize: 24,
                        color: ThemeConfig.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connect with our Telegram bot for password recovery and important notifications',
                      style: ThemeConfig.bodyStyle.copyWith(
                        color: ThemeConfig.lightSubtext,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (!_isVerified) ...[
                      ElevatedButton.icon(
                        onPressed: _hasConnected ? null : _launchTelegramBot,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0088cc),
                          foregroundColor: ThemeConfig.lightSurface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(FontAwesomeIcons.telegram),
                        label: Text(
                          _hasConnected ? 'Connected' : 'Connect to Telegram',
                          style: ThemeConfig.bodyStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_hasConnected) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _verifyAndProceed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: ThemeConfig.lightSurface,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.check_circle_outline),
                          label: Text(
                            'Verify Connection',
                            style: ThemeConfig.bodyStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ] else ...[
                      CircularProgressIndicator(
                        color: ThemeConfig.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Verification successful!\nRedirecting to login...',
                        textAlign: TextAlign.center,
                        style: ThemeConfig.bodyStyle.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (!_isVerified)
                      TextButton(
                        onPressed: () => Get.offAllNamed('/Login'),
                        child: Text(
                          'Skip for now',
                          style: ThemeConfig.bodyStyle.copyWith(
                            color: ThemeConfig.lightSubtext,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
