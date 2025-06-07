import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/register_model.dart';
import '../models/login_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  // Enhanced login check with multiple verification layers
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we recently logged out
      int? logoutTimestamp = prefs.getInt('logout_timestamp');
      if (logoutTimestamp != null) {
        int timeSinceLogout = DateTime.now().millisecondsSinceEpoch - logoutTimestamp;
        // If logged out within last 5 seconds, definitely not logged in
        if (timeSinceLogout < 5000) {
          _logger.d('Recent logout detected, user not logged in');
          return false;
        }
      }

      // Check app state
      String? appState = prefs.getString('app_state');
      if (appState == 'logged_out') {
        _logger.d('App state indicates logged out');
        return false;
      }

      // Check force recheck flag
      bool? forceRecheck = prefs.getBool('force_recheck_login');
      if (forceRecheck == true) {
        await prefs.remove('force_recheck_login');
        _logger.d('Force recheck triggered, user not logged in');
        return false;
      }

      // Standard checks
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      String? authToken = prefs.getString('auth_token');
      String? loginEmail = prefs.getString('login_email');

      // User must have login flag AND either token or email to be considered logged in
      bool hasValidSession = isLoggedIn && (authToken != null || loginEmail != null);

      _logger.d('Login check - isLoggedIn: $isLoggedIn, hasToken: ${authToken != null}, hasEmail: ${loginEmail != null}, result: $hasValidSession');

      // If not logged in, ensure app state reflects this
      if (!hasValidSession) {
        await prefs.setString('app_state', 'logged_out');
      }

      return hasValidSession;
    } catch (e) {
      _logger.e('Error checking login state: $e');
      // On error, assume not logged in for security
      return false;
    }
  }

  //USER_PROFILE - ENHANCED TO PROPERLY HANDLE PHONE NUMBERS
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      String? authToken = prefs.getString('auth_token');
      String? email = prefs.getString('login_email');

      _logger.d('Getting user profile - userId: $userId, hasToken: ${authToken != null}, email: $email');

      // Try to fetch from API first if we have token and userId
      if (userId != null && authToken != null) {
        try {
          final response = await http.get(
            Uri.parse('$_baseUrl/user/profile/$userId'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final userData = data['user'];

            _logger.d('API response userData: $userData');

            // Save the fetched data locally for future use
            if (userData['name'] != null) {
              await prefs.setString('user_name', userData['name']);
            }
            if (userData['phoneNumber'] != null && userData['phoneNumber'].toString().isNotEmpty) {
              await prefs.setString('user_phone', userData['phoneNumber']);
              _logger.d('Saved phone from API: ${userData['phoneNumber']}');
            }
            if (userData['email'] != null) {
              await prefs.setString('login_email', userData['email']);
            }

            return userData;
          }
        } catch (e) {
          _logger.e('Error fetching profile from API: $e');
          // Continue to fallback
        }
      }

      // Fallback to stored data
      return _getStoredUserData();
    } catch (e) {
      _logger.e('Error in getUserProfile: $e');
      // Fallback to stored data on error
      return _getStoredUserData();
    }
  }

  Future<Map<String, dynamic>> _getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('login_email') ?? 'user@example.com';
    String? storedName = prefs.getString('user_name');
    String? storedPhone = prefs.getString('user_phone');

    // Also check registration data
    String? registeredName = prefs.getString('registered_name');
    String? registeredPhone = prefs.getString('registered_phone');

    String name = storedName ?? registeredName ?? _generateNameFromEmail(email);

    // Enhanced phone number handling with multiple sources
    String phoneNumber = 'Not provided';

    // Try stored phone first
    if (storedPhone != null && storedPhone.isNotEmpty) {
      String cleanPhone = storedPhone.trim();
      if (_isValidPhoneNumber(cleanPhone)) {
        phoneNumber = cleanPhone;
        _logger.d('Using stored phone: $phoneNumber');
      }
    }

    // If no valid stored phone, try registered phone
    if (phoneNumber == 'Not provided' && registeredPhone != null && registeredPhone.isNotEmpty) {
      String cleanPhone = registeredPhone.trim();
      if (_isValidPhoneNumber(cleanPhone)) {
        phoneNumber = cleanPhone;
        _logger.d('Using registered phone: $phoneNumber');
        // Save it as stored phone for future use
        await prefs.setString('user_phone', phoneNumber);
      }
    }

    _logger.d('Final user data - name: $name, phone: $phoneNumber, email: $email');

    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  // Helper method to validate phone numbers
  bool _isValidPhoneNumber(String phone) {
    if (phone.isEmpty ||
        phone == 'Not provided' ||
        phone == 'null' ||
        phone.length < 10) {
      return false;
    }

    // Check for placeholder values
    List<String> placeholders = [
      '+201234567890',
      '01234567890',
      '1234567890',
      '+20123456789',
      '0123456789'
    ];

    if (placeholders.contains(phone)) {
      return false;
    }

    // Check if it's a valid Egyptian phone number format
    if (phone.startsWith('+20') && phone.length == 13) {
      return RegExp(r'^\+20\d{10}$').hasMatch(phone);
    }

    if (phone.startsWith('0') && phone.length == 11) {
      return RegExp(r'^0\d{10}$').hasMatch(phone);
    }

    if (phone.length == 10) {
      return RegExp(r'^\d{10}$').hasMatch(phone);
    }

    return false;
  }

  String _generateNameFromEmail(String email) {
    if (!email.contains('@')) return 'User';

    String name = email.split('@')[0];
    name = name.split('.').join(' ');
    name = name.split('_').join(' ');
    return name.split(' ').map((word) =>
    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
    ).join(' ');
  }

  // REGISTER - ENHANCED VERSION WITH IMMEDIATE PHONE STORAGE
  Future<RegisterResponseModel> register(RegisterRequestModel requestModel) async {
    final String url = "$_baseUrl/register";
    _logger.d("Register request to $url with payload: ${requestModel.toJson()}");

    try {
      // IMMEDIATELY save registration data before API call
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registered_name', requestModel.displayName);
      await prefs.setString('registered_phone', requestModel.phoneNumber);
      await prefs.setString('registered_email', requestModel.email);

      // Also save as current user data
      await prefs.setString('user_name', requestModel.displayName);
      await prefs.setString('user_phone', requestModel.phoneNumber);
      await prefs.setString('login_email', requestModel.email);

      _logger.d('Registration data saved immediately - name: ${requestModel.displayName}, phone: ${requestModel.phoneNumber}');

      // Create proper headers
      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status! < 500; // Accept all status codes less than 500
        },
      );

      // Make the API call
      final response = await _dio.post(
        url,
        data: json.encode(requestModel.toJson()), // Ensure proper JSON encoding
        options: options,
      );

      _logger.d("Register response status: ${response.statusCode}");
      _logger.d("Register response body: ${response.data}");

      // Handle successful response (200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.d('Registration successful');
        return RegisterResponseModel(success: true, message: 'Registration successful');
      }
      // Handle other responses
      else {
        String errorMessage = 'Registration failed';

        if (response.data != null) {
          if (response.data is Map && response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        }

        // Check if error message indicates success
        if (errorMessage.toLowerCase().contains('success') ||
            errorMessage.toLowerCase().contains('created') ||
            errorMessage.toLowerCase().contains('registered')) {
          return RegisterResponseModel(success: true, message: errorMessage);
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      _logger.e("Registration error: ${e.response?.data ?? e.message}");

      // Handle connection errors specifically
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timed out. Please check your internet connection and try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to the server. Please check your internet connection and try again.');
      }

      // Extract error message from API response if available
      String errorMessage = 'We couldn\'t create your account right now. Please try again later.';
      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      // Handle any other errors
      _logger.e("Unexpected registration error: $e");
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }

  // LOGIN - ENHANCED TO PRESERVE REGISTRATION DATA
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
        final prefs = await SharedPreferences.getInstance();

        // Preserve registration data before clearing
        String? registeredName = prefs.getString('registered_name');
        String? registeredPhone = prefs.getString('registered_phone');
        String? registeredEmail = prefs.getString('registered_email');

        // Clear auth data but preserve registration data
        await _clearAuthDataOnly();

        // Set new login data
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('login_email', requestModel.email);
        await prefs.setString('app_state', 'logged_in');

        // Save additional data if available in response
        if (response.data['token'] != null) {
          await prefs.setString('auth_token', response.data['token']);
        }
        if (response.data['userId'] != null) {
          await prefs.setString('user_id', response.data['userId'].toString());
        }
        if (response.data['displayName'] != null) {
          await prefs.setString('user_name', response.data['displayName']);
        }

        // Restore registration data if it matches the login email
        if (registeredEmail == requestModel.email) {
          if (registeredName != null) {
            await prefs.setString('user_name', registeredName);
            await prefs.setString('registered_name', registeredName);
          }
          if (registeredPhone != null) {
            await prefs.setString('user_phone', registeredPhone);
            await prefs.setString('registered_phone', registeredPhone);
            _logger.d('Restored phone number from registration: $registeredPhone');
          }
        }

        _logger.d('Login successful - data saved to SharedPreferences');
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Invalid email or password. Please try again.');
      }
    } on DioException catch (e) {
      _logger.e("Login error: ${e.response?.data ?? e.message}");

      // Handle connection errors specifically
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timed out. Please check your internet connection and try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to the server. Please check your internet connection and try again.');
      }

      // Extract error message from API response if available
      String errorMessage = 'We couldn\'t sign you in right now. Please check your credentials and try again.';
      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }
      throw Exception(errorMessage);
    }
  }

  // Clear only auth data, preserve registration data
  Future<void> _clearAuthDataOnly() async {
    final prefs = await SharedPreferences.getInstance();

    final authOnlyKeys = [
      'isLoggedIn',
      'user_id',
      'auth_token',
      'reset_token',
      'user_session',
      'remember_me',
      'auto_login',
    ];

    for (String key in authOnlyKeys) {
      await prefs.remove(key);
    }
  }

  // LOGOUT - COMPREHENSIVE LOGOUT WITH APP STATE RESET
  Future<void> logout() async {
    try {
      _logger.d('Starting comprehensive logout process...');

      // Clear all authentication data
      await _clearAllAuthData();

      // Force clear any cached data
      await _forceClearAllData();

      // Reset app state
      await _resetAppState();

      _logger.d('Logout completed successfully - all data cleared and app state reset');
    } catch (e) {
      _logger.e('Error during logout: $e');
      // Even if there's an error, force clear everything
      await _forceClearAllData();
      throw Exception('Unable to sign out completely. Please try again.');
    }
  }

  // Enhanced method to clear all authentication data
  Future<void> _clearAllAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    // Comprehensive list of all possible authentication-related keys
    final authKeys = [
      'isLoggedIn',
      'user_id',
      'auth_token',
      'login_email',
      'user_name',
      'user_phone',
      'reset_token',
      'profile_image_path',
      'prediction_count',
      'local_predictions',
      'user_session',
      'remember_me',
      'auto_login',
      'registered_name',
      'registered_phone',
      'registered_email',
    ];

    // Clear each key individually
    for (String key in authKeys) {
      await prefs.remove(key);
      _logger.d('Cleared key: $key');
    }

    // Explicitly set logged out state
    await prefs.setBool('isLoggedIn', false);
    await prefs.setString('app_state', 'logged_out');

    // Verify the data is cleared
    bool stillLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? email = prefs.getString('login_email');
    String? token = prefs.getString('auth_token');

    _logger.d('After logout verification - isLoggedIn: $stillLoggedIn, hasEmail: ${email != null}, hasToken: ${token != null}');
  }

  // Force clear all data - nuclear option
  Future<void> _forceClearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all keys and remove any that might be auth-related or user-related
      Set<String> keys = prefs.getKeys();
      List<String> keysToRemove = [];

      for (String key in keys) {
        if (key.contains('login') ||
            key.contains('auth') ||
            key.contains('user') ||
            key.contains('token') ||
            key.contains('reset') ||
            key.contains('session') ||
            key.contains('remember') ||
            key.contains('profile') ||
            key.contains('prediction') ||
            key.contains('registered')) {
          keysToRemove.add(key);
        }
      }

      // Remove all identified keys
      for (String key in keysToRemove) {
        await prefs.remove(key);
        _logger.d('Force removed key: $key');
      }

      // Set explicit logout state
      await prefs.setBool('isLoggedIn', false);
      await prefs.setString('app_state', 'logged_out');
      await prefs.setInt('logout_timestamp', DateTime.now().millisecondsSinceEpoch);

      _logger.d('Force clear completed - removed ${keysToRemove.length} keys');
    } catch (e) {
      _logger.e('Error during force clear: $e');
    }
  }

// Reset app state
  Future<void> _resetAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Set app to logged out state
      await prefs.setString('app_state', 'logged_out');
      await prefs.setInt('logout_timestamp', DateTime.now().millisecondsSinceEpoch);
      await prefs.setBool('force_recheck_login', true);

      _logger.d('App state reset completed');
    } catch (e) {
      _logger.e('Error resetting app state: $e');
    }
  }

  // Force logout - use this if regular logout doesn't work
  Future<void> forceLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all keys and remove any that might be auth-related
      Set<String> keys = prefs.getKeys();
      for (String key in keys) {
        if (key.contains('login') ||
            key.contains('auth') ||
            key.contains('user') ||
            key.contains('token') ||
            key.contains('reset')) {
          await prefs.remove(key);
          _logger.d('Force removed key: $key');
        }
      }

      // Explicitly set logged out state
      await prefs.setBool('isLoggedIn', false);

      _logger.d('Force logout completed');
    } catch (e) {
      _logger.e('Error during force logout: $e');
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
        throw Exception(response.data['message'] ?? 'We couldn\'t send the password reset email. Please try again.');
      }
    } on DioException catch (e) {
      _logger.e("Error sending reset email: $e");

      // Handle connection errors specifically
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timed out. Please check your internet connection and try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to the server. Please check your internet connection and try again.');
      }

      // Extract error message
      String errorMessage = 'We couldn\'t send the password reset email. Please check your email address and try again.';
      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      throw Exception(errorMessage);
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
        throw Exception(response.data['message'] ?? 'We couldn\'t send the password reset via Telegram. Please try again.');
      }
    } on DioException catch (e) {
      _logger.e("Error sending Telegram reset: $e");

      // Handle connection errors specifically
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timed out. Please check your internet connection and try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to the server. Please check your internet connection and try again.');
      }

      // Extract error message
      String errorMessage = 'We couldn\'t send the password reset via Telegram. Please check your phone number and try again.';
      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      throw Exception(errorMessage);
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
        'message': response.data['message'] ?? 'Code verified successfully!',
      };
    } on DioException catch (e) {
      _logger.e('Verification error: $e');

      String errorMessage = 'The verification code is incorrect or has expired. Please try again.';
      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;
        }
      }

      return {
        'success': false,
        'message': errorMessage,
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
    } on DioException catch (e) {
      _logger.e('Reset password error: $e');

      String errorMessage = 'We couldn\'t reset your password right now. Please try again later.';
      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        }
      }

      _logger.e(errorMessage);
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
