import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyPage extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  VerifyPage({super.key});

  Future<http.Response> verifyResetCode(String code) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/verifyResetCode'), // Use your backend URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'code': code}),
    );
    return response;
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
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: const EdgeInsets.symmetric(vertical: 50.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5.0)],
            ),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Enter Verification Code',
                      style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  FormBuilderTextField(
                    name: 'verification_code',
                    decoration: const InputDecoration(labelText: 'Verification Code', border: OutlineInputBorder()),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Verification code is required'),
                      FormBuilderValidators.match(RegExp(r'^\d{6}$'), errorText: 'Enter a 6-digit code'),
                    ]),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        final code = _formKey.currentState?.fields['verification_code']?.value;
                        final currentContext = context;

                        try {
                          final response = await verifyResetCode(code);
                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(currentContext).showSnackBar(
                              const SnackBar(content: Text('Verification successful'), backgroundColor: Colors.green),
                            );
                            Navigator.pushNamed(currentContext, '/ResetPassword');
                          } else {
                            final errorJson = jsonDecode(response.body);
                            final errorMessage = errorJson['message'] ?? 'Verification failed';
                            ScaffoldMessenger.of(currentContext).showSnackBar(
                              SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    ),
                    child: const Text('Verify', style: TextStyle(fontSize: 18.0, color: Colors.white)),
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