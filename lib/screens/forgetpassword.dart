import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import '../providers/auth_service.dart';
import '../widgets/theme_switch_widget.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = Get.find<AuthService>();
  bool _isLoading = false;
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

  Future<void> _sendResetCode() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final identifier = _formKey.currentState!.value['emailOrPhone'];
        final isEmail = identifier.contains('@');

        if (isEmail) {
          await _authService.requestPasswordResetByEmail(identifier);
        } else {
          await _authService.requestPasswordResetByTelegram(identifier);
        }

        if (!mounted) return;

        Get.snackbar(
          'Success',
          'Reset code sent successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        Get.toNamed('/Verify', arguments: {
          'identifier': identifier,
        });
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Theme.of(context).colorScheme.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.05),
              colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const Spacer(),
                    const ThemeSwitchWidget(showLabel: false),
                  ],
                ),

                const SizedBox(height: 40),

                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            size: 50,
                            color: colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Forgot Password?',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Don\'t worry! Enter your email or phone number and we\'ll send you a reset code.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Form
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: FormBuilder(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FormBuilderTextField(
                                  name: 'emailOrPhone',
                                  autofillHints: const [AutofillHints.username],
                                  decoration: InputDecoration(
                                    labelText: 'Email or Phone',
                                    hintText: 'Enter your email or phone number',
                                    prefixIcon: Icon(
                                      Icons.contact_mail_rounded,
                                      color: colorScheme.primary,
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: colorScheme.error),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: colorScheme.error, width: 2),
                                    ),
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText: 'Email or Phone is required'),
                                        (value) {
                                      if (value == null || value.isEmpty) return null;

                                      if (value.contains('@')) {
                                        final emailReg = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                                        if (!emailReg.hasMatch(value)) {
                                          return 'Enter a valid Gmail address';
                                        }
                                      } else {
                                        final phoneReg = RegExp(r'^\+20\d{10}$');
                                        if (!phoneReg.hasMatch(value)) {
                                          return 'Enter a valid Egyptian phone number (+20XXXXXXXXXX)';
                                        }
                                      }
                                      return null;
                                    },
                                  ]),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Send Button
                                _isLoading
                                    ? Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                )
                                    : ElevatedButton.icon(
                                  onPressed: _sendResetCode,
                                  icon: Icon(
                                    Icons.send_rounded,
                                    size: 20,
                                    color: colorScheme.onPrimary,
                                  ),
                                  label: Text(
                                    'Send Reset Code',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Back to Login
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Remember your password? ',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.toNamed('/Login'),
                                      child: Text(
                                        'Sign In',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Help Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.help_outline_rounded,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Need Help?',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'If you\'re having trouble, contact our support team for assistance.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}