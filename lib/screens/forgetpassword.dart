import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:handlink/screens/theme.dart';
import '../providers/auth_service.dart'; // Import your AuthService

class ForgotPasswordPage extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = AuthService(); // Create an instance of AuthService

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: ThemeConfig.mainColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: const EdgeInsets.symmetric(vertical: 50.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [ThemeConfig.mainShadow],
            ),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: ThemeConfig.mainColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  FormBuilderTextField(
                    name: 'emailOrPhone',
                    decoration: const InputDecoration(labelText: 'Email or Phone', border: OutlineInputBorder()),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Email or Phone is required'),
                    ]),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        final input = _formKey.currentState?.fields['emailOrPhone']?.value;
                        try {
                          if (input.contains('@')) {
                            // Assume it's an email
                            await _authService.requestPasswordResetByEmail(input);
                          } else {
                            // Assume it's a phone number
                            await _authService.requestPasswordResetByTelegram(input);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Check your email or phone for the reset link'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Navigate to VerificationPage
                          Navigator.pushNamed(context, '/Verify');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.mainColor,
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    ),
                    child: const Text('Reset Password', style: TextStyle(fontSize: 18.0, color: Colors.white)),
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