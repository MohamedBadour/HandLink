import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import '../providers/auth_service.dart';
import '../screens/theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = Get.find<AuthService>();
  bool _isLoading = false;

  Future<void> _sendResetCode() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final identifier = _formKey.currentState!.value['emailOrPhone'];
        final isEmail = identifier.contains('@');

        print('Sending reset code to: $identifier (${isEmail ? 'email' : 'phone'})');

        if (isEmail) {
          await _authService.requestPasswordResetByEmail(identifier);
        } else {
          await _authService.requestPasswordResetByTelegram(identifier);
        }

        if (!mounted) return;

        Get.snackbar(
          'Success',
          'Reset code sent successfully',
          backgroundColor: ThemeConfig.successColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        Get.toNamed('/Verify', arguments: {
          'identifier': identifier,
        });
      } catch (e) {
        print('Error sending reset code: $e');
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: ThemeConfig.errorColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
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
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: ThemeConfig.primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: const EdgeInsets.symmetric(vertical: 50.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: ThemeConfig.lightSurface,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: ThemeConfig.elevation2,
            ),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Reset Password',
                      style: ThemeConfig.headingStyle.copyWith(
                        fontSize: 28.0,
                        color: ThemeConfig.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  FormBuilderTextField(
                    name: 'emailOrPhone',
                    decoration: InputDecoration(
                      labelText: 'Email or Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(
                        Icons.contact_mail,
                        color: ThemeConfig.primaryColor,
                      ),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Email or Phone is required'),
                          (value) {
                        if (value != null && !value.contains('@')) {
                          final phoneRegExp = RegExp(r'^\+20\d{10}$');
                          if (!phoneRegExp.hasMatch(value)) {
                            return 'Enter valid Egyptian phone number (+20XXXXXXXXXX)';
                          }
                        }
                        return null;
                      },
                    ]),
                  ),
                  const SizedBox(height: 25.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: ThemeConfig.primaryColor,
                      ),
                    )
                        : ElevatedButton(
                      onPressed: _sendResetCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primaryColor,
                        foregroundColor: ThemeConfig.lightSurface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Send Reset Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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