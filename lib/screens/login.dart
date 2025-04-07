import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import '../providers/auth_service.dart';
import '../models/login_model.dart';
import '../screens/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = Get.find<AuthService>();
  bool _obscurePassword = true;
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

  Future<void> _login() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final requestModel = LoginRequestModel(
          email: _formKey.currentState!.value['email'],
          password: _formKey.currentState!.value['password'],
        );
        await _authService.login(requestModel);
        Get.offAllNamed('/Model');
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: ThemeConfig.errorColor,
          colorText: ThemeConfig.lightSurface,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
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
          'Login',
          style: ThemeConfig.headingStyle.copyWith(
            color: ThemeConfig.lightSurface,
          ),
        ),
        backgroundColor: ThemeConfig.primaryColor,
        elevation: 0,
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
                        'Welcome Back',
                        style: ThemeConfig.headingStyle.copyWith(
                          fontSize: 28,
                          color: ThemeConfig.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: ThemeConfig.bodyStyle.copyWith(
                          color: ThemeConfig.lightSubtext,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed('/ForgotPassword'),
                          child: Text(
                            'Forgot Password?',
                            style: ThemeConfig.bodyStyle.copyWith(
                              color: ThemeConfig.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          color: ThemeConfig.primaryColor,
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _login,
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
                          'Login',
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
                            'Don\'t have an account? ',
                            style: ThemeConfig.bodyStyle.copyWith(
                              color: ThemeConfig.lightSubtext,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed('/Register'),
                            child: Text(
                              'Sign Up',
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

  Widget _buildEmailField() {
    return FormBuilderTextField(
      name: 'email',
      decoration: _getInputDecoration(
        'Email',
        Icons.email_outlined,
        'Enter your email',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Email is required'),
        FormBuilderValidators.email(errorText: 'Enter a valid email'),
      ]),
      style: ThemeConfig.bodyStyle.copyWith(
        color: ThemeConfig.lightText,
      ),
    );
  }

  Widget _buildPasswordField() {
    return FormBuilderTextField(
      name: 'password',
      obscureText: _obscurePassword,
      decoration: _getInputDecoration(
        'Password',
        Icons.lock_outline,
        'Enter your password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: ThemeConfig.primaryColor,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Password is required'),
        FormBuilderValidators.minLength(8, errorText: 'Password must be at least 8 characters'),
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