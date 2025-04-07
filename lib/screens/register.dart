import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_service.dart';
import '../models/register_model.dart';
import '../screens/theme.dart';
import '../utils/dialog_utils.dart';

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
      try {
        final formData = _formKey.currentState!.value;

        // Format phone number
        String phoneNumber = formData['phone'];
        if (!phoneNumber.startsWith('+20')) {
          phoneNumber = phoneNumber.startsWith('0')
              ? '+20${phoneNumber.substring(1)}'
              : '+20$phoneNumber';
        }

        final registerRequest = RegisterRequestModel(
          displayName: formData['name'],
          phoneNumber: phoneNumber,
          email: formData['email'],
          password: formData['password'],
          rePassword: formData['rePassword'],
        );

        final response = await _authService.register(registerRequest);
        await DialogUtils.showRegistrationSuccessDialog();
        Get.offAllNamed('/TelegramConnect');

      } catch (e) {
        await DialogUtils.showErrorDialog(
          title: 'Registration Failed',
          message: e.toString().replaceAll('Exception:', '').trim(),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.lightBackground,
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: ThemeConfig.headingStyle.copyWith(
            color: ThemeConfig.lightSurface,
          ),
        ),
        backgroundColor: ThemeConfig.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.toNamed('/Welcome'),
        ),
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
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign Up',
                        style: ThemeConfig.headingStyle.copyWith(
                          color: ThemeConfig.primaryColor,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildFormField(
                        name: 'name',
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        hint: 'Enter your full name',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Name is required'),
                          FormBuilderValidators.minLength(2, errorText: 'Name is too short'),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        name: 'phone',
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        hint: '01XXXXXXXXX',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          final egyptianPhoneRegex = RegExp(r'^((\+20)|0)?1[0125][0-9]{8}$');
                          if (!egyptianPhoneRegex.hasMatch(value)) {
                            return 'Enter valid Egyptian phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        name: 'email',
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        hint: 'example@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Email is required'),
                          FormBuilderValidators.email(errorText: 'Enter a valid email'),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        name: 'password',
                        label: 'Password',
                        isObscure: _obscurePassword,
                        onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        name: 'rePassword',
                        label: 'Confirm Password',
                        isObscure: _obscureRePassword,
                        onToggleVisibility: () => setState(() => _obscureRePassword = !_obscureRePassword),
                        validator: (value) {
                          if (value != _formKey.currentState?.fields['password']?.value) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          color: ThemeConfig.primaryColor,
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConfig.primaryColor,
                          foregroundColor: ThemeConfig.lightSurface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Register',
                          style: ThemeConfig.bodyStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: ThemeConfig.bodyStyle.copyWith(
                              color: ThemeConfig.lightSubtext,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed('/Login'),
                            child: Text(
                              'Login',
                              style: ThemeConfig.bodyStyle.copyWith(
                                color: ThemeConfig.primaryColor,
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
    return FormBuilderTextField(
      name: name,
      decoration: _getInputDecoration(label, icon, hint),
      keyboardType: keyboardType,
      validator: validator,
      style: ThemeConfig.bodyStyle.copyWith(
        color: ThemeConfig.lightText,
      ),
    );
  }

  Widget _buildPasswordField({
    required String name,
    required String label,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return FormBuilderTextField(
      name: name,
      obscureText: isObscure,
      decoration: _getInputDecoration(
        label,
        Icons.lock_outline,
        '••••••••',
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: ThemeConfig.primaryColor,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator ?? FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Password is required'),
        FormBuilderValidators.minLength(8, errorText: 'Password must be at least 8 characters'),
            (value) {
          if (value != null &&
              !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$')
                  .hasMatch(value)) {
            return 'Password must include letters, numbers, and special characters';
          }
          return null;
        },
      ]),
      style: ThemeConfig.bodyStyle.copyWith(
        color: ThemeConfig.lightText,
      ),
    );
  }

  InputDecoration _getInputDecoration(
      String label,
      IconData icon,
      String hint, {
        Widget? suffixIcon,
      }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: ThemeConfig.primaryColor),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeConfig.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeConfig.primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeConfig.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeConfig.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeConfig.errorColor, width: 2),
      ),
      filled: true,
      fillColor: ThemeConfig.lightBackground,
      labelStyle: TextStyle(color: ThemeConfig.lightSubtext),
      hintStyle: TextStyle(color: ThemeConfig.lightSubtext.withOpacity(0.5)),
    );
  }
}