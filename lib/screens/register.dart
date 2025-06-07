import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import '../providers/auth_service.dart';
import '../models/register_model.dart';
import '../utils/RegisterDialogUtils.dart';
import '../widgets/theme_switch_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = Get.find<AuthService>();
  bool _obscurePassword = true;
  bool _obscureRePassword = true;
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

  Future<void> _register() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      final formData = _formKey.currentState!.value;
      debugPrint('Form data: $formData');

      try {
        // Format phone number
        String phoneNumber = formData['phone'];
        if (!phoneNumber.startsWith('+20')) {
          phoneNumber = phoneNumber.startsWith('0')
              ? '+20${phoneNumber.substring(1)}'
              : '+20$phoneNumber';
        }
        debugPrint('Formatted phone number: $phoneNumber');

        final registerRequest = RegisterRequestModel(
          displayName: formData['name'],
          phoneNumber: phoneNumber,
          email: formData['email'],
          password: formData['password'],
          rePassword: formData['rePassword'],
        );

        // Debug log the request
        debugPrint('Register request: ${registerRequest.toJson()}');

        final response = await _authService.register(registerRequest);

        // Debug log the response
        debugPrint('Register response: ${response.success}, ${response.message}');

        // Check if registration was actually successful
        if (response.success) {
          // Show success dialog and navigate to login
          await DialogUtils.showRegistrationSuccessDialog(
            onContinue: () {
              Get.back(); // Close dialog
              Get.offAllNamed('/Login'); // Navigate to login page
            },
          );
        } else {
          // Show error if registration failed
          throw Exception(response.message ?? 'Registration failed');
        }
      } catch (e) {
        String errorMessage = e.toString().replaceAll('Exception:', '').trim();
        debugPrint('Registration error: $errorMessage');

        // Check if the error message indicates success (some APIs return success in error format)
        if (errorMessage.toLowerCase().contains('success') ||
            errorMessage.toLowerCase().contains('created') ||
            errorMessage.toLowerCase().contains('registered')) {
          // If error message indicates success, treat as success
          await DialogUtils.showRegistrationSuccessDialog(
            onContinue: () {
              Get.back(); // Close dialog
              Get.offAllNamed('/Login'); // Navigate to login page
            },
          );
        } else {
          // Handle actual errors
          if (errorMessage.toLowerCase().contains('connection') ||
              errorMessage.toLowerCase().contains('timeout') ||
              errorMessage.toLowerCase().contains('network')) {
            await DialogUtils.showNetworkErrorDialog(
              message: errorMessage,
              onRetry: _register,
            );
          } else {
            await DialogUtils.showErrorDialog(
              title: 'Registration Failed',
              message: errorMessage,
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      debugPrint('Form validation failed');
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
                      onPressed: () => Get.toNamed('/Welcome'),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const Spacer(),
                    const ThemeSwitchWidget(showLabel: false),
                  ],
                ),

                const SizedBox(height: 20),

                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Logo
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
                            Icons.person_add_rounded,
                            size: 50,
                            color: colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Create Account',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Join us and start your journey',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Registration Form
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
                                _buildFormField(
                                  name: 'name',
                                  label: 'Full Name',
                                  icon: Icons.person_outline_rounded,
                                  hint: 'Enter your full name',
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(errorText: 'Name is required'),
                                    FormBuilderValidators.minLength(3, errorText: 'Name must be at least 3 characters'),
                                    FormBuilderValidators.maxLength(50, errorText: 'Name must be less than 50 characters'),
                                    FormBuilderValidators.match(
                                      RegExp(r'^[A-Za-z\s]+(?:\d{0,5})?$'),
                                      errorText: 'Name should contain only letters, spaces, and optional digits (max 5).',
                                    ),
                                  ]),
                                ),

                                const SizedBox(height: 20),

                                _buildFormField(
                                  name: 'phone',
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  hint: '+201234567890',
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Phone number is required';
                                    }
                                    final val = value.trim();
                                    if (val.startsWith('+20')) {
                                      if (!RegExp(r'^\+20\d{10}$').hasMatch(val)) {
                                        return 'Phone must start with +20 followed by 10 digits';
                                      }
                                    } else if (val.startsWith('0')) {
                                      if (!RegExp(r'^0\d{10}$').hasMatch(val)) {
                                        return 'Phone must have 11 digits starting with 0';
                                      }
                                    } else {
                                      if (!RegExp(r'^\d{10}$').hasMatch(val)) {
                                        return 'Phone must have 10 digits if not starting with +20 or 0';
                                      }
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                _buildFormField(
                                  name: 'email',
                                  label: 'Email Address',
                                  icon: Icons.email_outlined,
                                  hint: 'yourname@gmail.com',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(errorText: 'Email is required'),
                                    FormBuilderValidators.email(errorText: 'Please enter a valid email'),
                                    FormBuilderValidators.match(
                                      RegExp(r'^[a-zA-Z0-9](?:[a-zA-Z0-9._]*[a-zA-Z0-9])?@gmail\.com$'),
                                      errorText: 'Must be a valid Gmail address',
                                    ),
                                  ]),
                                ),

                                const SizedBox(height: 20),

                                _buildPasswordField(
                                  name: 'password',
                                  label: 'Password',
                                  isObscure: _obscurePassword,
                                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    if (value.length > 20) {
                                      return 'Password must be at most 20 characters';
                                    }
                                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                      return 'Password must contain at least one uppercase letter';
                                    }
                                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                                      return 'Password must contain at least one lowercase letter';
                                    }
                                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                                      return 'Password must contain at least one number';
                                    }
                                    if (!RegExp(r'[@#!%*?&]').hasMatch(value)) {
                                      return 'Password must contain at least one special character (@#!%*?&)';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                _buildPasswordField(
                                  name: 'rePassword',
                                  label: 'Confirm Password',
                                  isObscure: _obscureRePassword,
                                  onToggleVisibility: () => setState(() => _obscureRePassword = !_obscureRePassword),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    final password = _formKey.currentState?.fields['password']?.value;
                                    if (value != password) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 32),

                                // Register Button
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
                                    : ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_add_rounded,
                                        size: 20,
                                        color: colorScheme.onPrimary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Create Account',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Login Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
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

  Widget _buildFormField({
    required String name,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
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
      keyboardType: keyboardType,
      validator: validator,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
    );
  }

  Widget _buildPasswordField({
    required String name,
    required String label,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FormBuilderTextField(
      name: name,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: '••••••••',
        prefixIcon: Icon(Icons.lock_outline_rounded, color: colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: colorScheme.primary,
          ),
          onPressed: onToggleVisibility,
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
      validator: validator,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
    );
  }
}
