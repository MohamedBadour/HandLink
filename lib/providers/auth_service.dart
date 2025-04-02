import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/register_model.dart';
import '../models/login_model.dart';

class AuthService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  final String _baseUrl = "http://sign-language.runasp.net/api/Account";

  // LOGIN
  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    final String url = "$_baseUrl/login";
    _logger.d("Login request to $url with payload: ${requestModel.toJson()}");

    try {
      final response = await _dio.post(
        url,
        data: requestModel.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logger.d("Login response status: ${response.statusCode}");
      _logger.d("Login response body: ${response.data}");

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception('Login failed: ${response.statusCode} ${response.data}');
      }
    } on DioException catch (e) {
      _logger.e("Login error: ${e.response?.data ?? e.message}");
      throw Exception('An error occurred during login: ${e.response?.data ?? e.message}');
    }
  }

  // REGISTER
  Future<RegisterResponseModel> register(RegisterRequestModel requestModel) async {
    final String url = "$_baseUrl/register";
    _logger.d("Register request to $url with payload: ${requestModel.toJson()}");

    try {
      final response = await _dio.post(
        url,
        data: requestModel.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logger.d("Register response status: ${response.statusCode}");
      _logger.d("Register response body: ${response.data}");

      if (response.statusCode == 200) {
        return RegisterResponseModel.fromJson(response.data);
      } else {
        throw Exception('Registration failed: ${response.statusCode} ${response.data}');
      }
    } on DioException catch (e) {
      _logger.e("Registration error: ${e.response?.data ?? e.message}");
      throw Exception('An error occurred during registration: ${e.response?.data ?? e.message}');
    }
  }

  // REQUEST PASSWORD RESET BY EMAIL
  Future<void> requestPasswordResetByEmail(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/forgotPasswordByEmail'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode == 200) {
      _logger.d("Password reset email sent successfully.");
    } else {
      _logger.e("Failed to send password reset email: ${response.statusCode} ${response.body}");
      throw Exception('Failed to send password reset email.');
    }
  }

  // REQUEST PASSWORD RESET BY TELEGRAM
  Future<void> requestPasswordResetByTelegram(String telegram) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/forgotPasswordByTelegram'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'telegram': telegram}),
    );

    if (response.statusCode == 200) {
      _logger.d("Password reset request via Telegram sent successfully.");
    } else {
      _logger.e("Failed to send password reset request via Telegram: ${response.statusCode} ${response.body}");
      throw Exception('Failed to send password reset request via Telegram.');
    }
  }

  // VERIFY RESET CODE
  Future<void> verifyResetCode(String code) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/verifyResetCode'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'code': code}),
    );

    if (response.statusCode == 200) {
      _logger.d("Verification code verified successfully.");
    } else {
      _logger.e("Failed to verify code: ${response.statusCode} ${response.body}");
      throw Exception('Failed to verify code.');
    }
  }

  // Store user credentials
  Future<void> storeCredentials(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setString('user', json.encode(data['user']));
    _logger.d("User credentials stored successfully.");
  }

  // Reset Password
  Future<void> resetPassword(String identifier, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isEmail = identifier.contains('@');

      final response = await _dio.post(
        "$_baseUrl/resetPassword",
        data: {
          'identifier': identifier,
          'newPassword': newPassword,
          'isEmail': isEmail,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        await clearStoredCredentials();
        _logger.d("Password reset successfully.");
        return;
      }

      final errorMessage = response.data is Map && response.data.containsKey('message')
          ? response.data['message']
          : 'Password reset failed. Status Code: ${response.statusCode}';
      throw Exception(errorMessage);

    } on DioException catch (e) {
      final errorMessage = e.response?.data is Map && e.response?.data.containsKey('message')
          ? e.response?.data['message']
          : 'Failed to reset password. Details: ${e.message}';
      _logger.e(errorMessage);
      throw Exception(errorMessage);
    }
  }

  // Clear stored credentials
  Future<void> clearStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _logger.d("Stored credentials cleared.");
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getString('token') != null;
    _logger.d("User is ${isLoggedIn ? '' : 'not '}logged in.");
    return isLoggedIn;
  }

  // Logout
  Future<void> logout() async {
    await clearStoredCredentials();
    _logger.d("User logged out.");
  }
}