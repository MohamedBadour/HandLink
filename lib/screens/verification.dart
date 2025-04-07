import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import '../providers/auth_service.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = Get.find<AuthService>();
  bool _isLoading = false;
  late String identifier;

  @override
  void initState() {
    super.initState();
    identifier = Get.arguments['identifier'] ?? '';
    print('Verifying for identifier: $identifier');
  }

  Future<void> _verifyCode(String code) async {
    if (identifier.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid identifier',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Attempting to verify code: $code for identifier: $identifier');

      final response = await _authService.verifyResetCode(identifier, code);
      print('Verification response: $response');

      if (!mounted) return;

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Verification successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.toNamed('/ResetPassword', arguments: {
          'identifier': identifier,
        });
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Verification failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Verification error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enter Verification Code',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FormBuilderTextField(
                    name: 'code',
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.security),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Please enter the code'),
                      FormBuilderValidators.numeric(errorText: 'Code must be numeric'),
                      FormBuilderValidators.maxLength(6, errorText: 'Code must be 6 digits'),
                      FormBuilderValidators.minLength(6, errorText: 'Code must be 6 digits'),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          final code = _formKey.currentState?.value['code'];
                          _verifyCode(code);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Verify Code',
                        style: TextStyle(fontSize: 16),
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