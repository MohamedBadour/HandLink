import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import '../providers/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _resetPassword(String newPassword) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final identifier = "your-identifier"; // **REPLACE with your identifier logic**
      await _authService.resetPassword(identifier, newPassword);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successful'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed('/Login');

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())), // Simplified error display
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.symmetric(vertical: 50.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  FormBuilderTextField(
                    name: 'newPassword',
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Password is required'),
                      FormBuilderValidators.minLength(8, errorText: 'Must be at least 8 characters'),
                      FormBuilderValidators.match(
                        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'),
                        errorText: 'Must include letters, numbers, and special characters',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 25.0),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.teal)
                        : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final newPassword = _formKey.currentState?.fields['newPassword']?.value;
                          _resetPassword(newPassword);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}