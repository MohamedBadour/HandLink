import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/register_model.dart';
import '../models/login_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  final Dio _dio;
  final Logger _logger;
  final String _baseUrl;

  AuthService() :
        _dio = Dio(),
        _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 75,
            colors: true,
            printEmojis: true,
            printTime: true,
          ),
        ),
        _baseUrl = "http://sign-language.runasp.net/api/Account";

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
    } on DioError catch (e) {
      _logger.e("Registration error: ${e.response?.data ?? e.message}");
      throw Exception('An error occurred during registration: ${e.response?.data ?? e.message}');
    }
  }
  /*
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
    } on DioError catch (e) {
      _logger.e("Registration error: ${e.response?.data ?? e.message}");
      throw Exception('An error occurred during registration: ${e.response?.data ?? e.message}');
    }
  }
   */

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
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      _logger.e("Login error: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data?['message'] ?? 'An error occurred during login');
    }
  }

  // REQUEST PASSWORD RESET BY EMAIL
  Future<void> requestPasswordResetByEmail(String email) async {
    try {
      _logger.d('Sending email reset request for: $email');
      final response = await _dio.post(
        '$_baseUrl/forgotPasswordByEmail',
        data: {
          'email': email,
          'type': 'email',
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logger.d("Password reset email response: ${response.statusCode}");

      if (response.statusCode == 200) {
        _logger.i("Password reset email sent successfully.");
      } else {
        throw Exception('Failed to send password reset email.');
      }
    } catch (e) {
      _logger.e("Error sending reset email: $e");
      throw Exception('Failed to send password reset email.');
    }
  }

  // REQUEST PASSWORD RESET BY TELEGRAM
  Future<void> requestPasswordResetByTelegram(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/forgotPasswordByTelegram',
        data: {
          'phoneNumber': phoneNumber,
          'type': 'phone',
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logger.d("Telegram reset response: ${response.statusCode}");

      if (response.statusCode == 200) {
        _logger.i("Password reset via Telegram sent successfully.");
      } else {
        throw Exception('Failed to send password reset via Telegram.');
      }
    } catch (e) {
      _logger.e("Error sending Telegram reset: $e");
      throw Exception('Failed to send password reset via Telegram.');
    }
  }

  // VERIFY RESET CODE
  Future<Map<String, dynamic>> verifyResetCode(String identifier, String code) async {
    try {
      final bool isEmail = identifier.contains('@');
      _logger.d('Verifying code for: $identifier (${isEmail ? 'email' : 'phone'})');

      final response = await _dio.post(
        '$_baseUrl/verifyResetCode',
        data: {
          'identifier': identifier,
          'resetCode': code,
          'isEmail': isEmail,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logger.d('Verification response: ${response.statusCode}');
      _logger.d('Response data: ${response.data}');

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Verification completed',
      };
    } catch (e) {
      _logger.e('Verification error: $e');
      return {
        'success': false,
        'message': 'Verification failed',
      };
    }
  }

  // RESET PASSWORD
  Future<bool> resetPassword(String identifier, String newPassword) async {
    try {
      _logger.d('Resetting password for: $identifier');

      final response = await _dio.post(
        '$_baseUrl/resetPassword',
        data: {
          'identifier': identifier,
          'newPassword': newPassword,
          'isEmail': identifier.contains('@'),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _logger.d('Reset password response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Reset password error: $e');
      return false;
    }
  }

  // TOKEN MANAGEMENT
  Future<void> storeResetToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reset_token', token);
      _logger.d('Reset token stored successfully');
    } catch (e) {
      _logger.e('Error storing reset token: $e');
    }
  }

  Future<String?> getResetToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('reset_token');
    } catch (e) {
      _logger.e('Error getting reset token: $e');
      return null;
    }
  }

  Future<void> clearResetToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('reset_token');
      _logger.d('Reset token cleared successfully');
    } catch (e) {
      _logger.e('Error clearing reset token: $e');
    }
  }
}