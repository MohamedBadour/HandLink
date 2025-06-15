import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/register_model.dart';
import '../models/login_model.dart';
import '../models/profile_model.dart';
import '../models/password_reset_model.dart';

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
        _baseUrl = "https://sign-language.runasp.net/api" {

    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => _logger.d(obj),
    ));
  }

  // ==================== LOGIN STATE MANAGEMENT ====================

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we recently logged out
      int? logoutTimestamp = prefs.getInt('logout_timestamp');
      if (logoutTimestamp != null) {
        int timeSinceLogout = DateTime.now().millisecondsSinceEpoch - logoutTimestamp;
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

      // Standard checks
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      String? authToken = prefs.getString('auth_token');
      String? loginEmail = prefs.getString('login_email');

      bool hasValidSession = isLoggedIn && (authToken != null || loginEmail != null);

      _logger.d('Login check - isLoggedIn: $isLoggedIn, hasToken: ${authToken != null}, hasEmail: ${loginEmail != null}, result: $hasValidSession');

      if (!hasValidSession) {
        await prefs.setString('app_state', 'logged_out');
      }

      return hasValidSession;
    } catch (e) {
      _logger.e('Error checking login state: $e');
      return false;
    }
  }

  // ==================== AUTHENTICATION METHODS ====================

  // POST /api/Account/login
  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    try {
      _logger.d("Login request for email: ${requestModel.email}");

      final response = await _dio.post(
        '/Account/login',
        data: requestModel.toJson(),
      );

      _logger.d("Login response status: ${response.statusCode}");
      _logger.d("Login response data: ${response.data}");

      if (response.statusCode == 200) {
        final loginResponse = LoginResponseModel.fromJson(response.data);

        // Save login data to SharedPreferences
        await _saveLoginData(loginResponse, requestModel.email);

        _logger.d('Login successful - data saved to SharedPreferences');
        return loginResponse;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e("Login error: ${e.response?.data ?? e.message}");
      throw _handleDioException(e, 'Login failed');
    } catch (e) {
      _logger.e("Unexpected login error: $e");
      throw Exception('An unexpected error occurred during login');
    }
  }
  // POST /api/Account/register
  Future<RegisterResponseModel> register(RegisterRequestModel requestModel) async {
    try {
      _logger.d("Register request for email: ${requestModel.email}");

      // Validate passwords match
      if (requestModel.password != requestModel.rePassword) {
        throw Exception('Passwords do not match');
      }

      final response = await _dio.post(
        '/Account/register',
        data: requestModel.toJson(),
      );

      _logger.d("Register response status: ${response.statusCode}");
      _logger.d("Register response data: ${response.data}");

      if (response.statusCode == 200) {
        final registerResponse = RegisterResponseModel.fromJson(response.data);

        // Save registration data immediately
        await _saveRegistrationData(registerResponse, requestModel);

        _logger.d('Registration successful');
        return registerResponse;
      } else {
        throw Exception('Registration failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e("Registration error: ${e.response?.data ?? e.message}");
      throw _handleDioException(e, 'Registration failed');
    } catch (e) {
      _logger.e("Unexpected registration error: $e");
      throw Exception('An unexpected error occurred during registration');
    }
  }

  // ==================== PASSWORD RESET METHODS ====================

  /// POST /api/Account/forgotPasswordByEmail
  Future<ForgotPasswordResponse> forgotPasswordByEmail(String email) async {
    try {
      _logger.d('Sending password reset email to: $email');

      final request = ForgotPasswordEmailRequest(email: email);
      final response = await _dio.post(
        '/Account/forgotPasswordByEmail',
        data: request.toJson(),
      );

      _logger.d("Forgot password email response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return ForgotPasswordResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send reset email');
      }
    } on DioException catch (e) {
      _logger.e("Forgot password email error: $e");
      throw _handleDioException(e, 'Failed to send reset email');
    }
  }

  /// POST /api/Account/forgotPasswordByTelegram
  Future<ForgotPasswordResponse> forgotPasswordByTelegram(String phoneNumber) async {
    try {
      _logger.d('Sending password reset via Telegram to: $phoneNumber');

      final request = ForgotPasswordTelegramRequest(phoneNumber: phoneNumber);
      final response = await _dio.post(
        '/Account/forgotPasswordByTelegram',
        data: request.toJson(),
      );

      _logger.d("Forgot password Telegram response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return ForgotPasswordResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send reset via Telegram');
      }
    } on DioException catch (e) {
      _logger.e("Forgot password Telegram error: $e");
      throw _handleDioException(e, 'Failed to send reset via Telegram');
    }
  }

  /// POST /api/Account/verifyResetCode
  Future<VerifyResetCodeResponse> verifyResetCode(String identifier, String resetCode) async {
    try {
      final bool isEmail = identifier.contains('@');
      _logger.d('Verifying reset code for: $identifier (${isEmail ? 'email' : 'phone'})');

      final request = VerifyResetCodeRequest(
        identifier: identifier,
        resetCode: resetCode,
        isEmail: isEmail,
      );

      final response = await _dio.post(
        '/Account/verifyResetCode',
        data: request.toJson(),
      );

      _logger.d('Verify reset code response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return VerifyResetCodeResponse.fromJson(response.data);
      } else {
        throw Exception('Invalid or expired reset code');
      }
    } on DioException catch (e) {
      _logger.e('Verify reset code error: $e');
      throw _handleDioException(e, 'Invalid or expired reset code');
    }
  }

  /// POST /api/Account/resetPassword
  Future<ResetPasswordResponse> resetPassword(String identifier, String newPassword) async {
    try {
      final bool isEmail = identifier.contains('@');
      _logger.d('Resetting password for: $identifier');

      final request = ResetPasswordRequest(
        identifier: identifier,
        newPassword: newPassword,
        isEmail: isEmail,
      );

      final response = await _dio.post(
        '/Account/resetPassword',
        data: request.toJson(),
      );

      _logger.d('Reset password response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ResetPasswordResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to reset password');
      }
    } on DioException catch (e) {
      _logger.e('Reset password error: $e');
      throw _handleDioException(e, 'Failed to reset password');
    }
  }

  // ==================== PROFILE METHODS ====================

  // GET /api/Profile/getUserProfile?email=string
  Future<UserProfileModel> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('login_email');

      if (email == null || email.isEmpty) {
        throw Exception('No user email found. Please login again.');
      }
      _logger.d('Fetching user profile for email: $email');
      final response = await _dio.get(
        '/Profile/getUserProfile',
        queryParameters: {'email': email},
      );
      _logger.d('Get user profile response: ${response.statusCode}');
      _logger.d('Profile data: ${response.data}');
      if (response.statusCode == 200) {
        UserProfileModel profile;
        if (response.data is Map<String, dynamic>) {
          profile = UserProfileModel.fromJson(response.data);
        } else if (response.data is String) {
          final Map<String, dynamic> jsonData = json.decode(response.data);
          profile = UserProfileModel.fromJson(jsonData);
        } else {
          throw Exception('Invalid response format');
        }
        await _cacheProfileData(profile);

        return profile;
      } else {
        return await _getCachedProfile();
      }
    } on DioException catch (e) {
      _logger.e('Get user profile error: $e');
      try {
        return await _getCachedProfile();
      } catch (cacheError) {
        throw _handleDioException(e, 'Failed to load profile');
      }
    } catch (e) {
      _logger.e('Unexpected profile error: $e');
      // Try to get cached data
      try {
        return await _getCachedProfile();
      } catch (cacheError) {
        throw Exception('Failed to load profile data');
      }
    }
  }

  // PUT /api/Profile/updateUserProfile?email=string
  Future<bool> updateUserProfile(UserProfileModel profileModel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('login_email');
      if (email == null || email.isEmpty) {
        throw Exception('No user email found. Please login again.');
      }
      _logger.d('Updating user profile for email: $email');
      final updateRequest = UpdateProfileRequestModel(
        displayName: profileModel.displayName,
        userName: profileModel.userName,
        email: profileModel.email,
        phoneNumber: profileModel.phoneNumber,
      );
      final response = await _dio.put(
        '/Profile/updateUserProfile',
        queryParameters: {'email': email},
        data: updateRequest.toJson(),
      );
      _logger.d('Update profile response: ${response.statusCode}');
      if (response.statusCode == 200) {
        await _cacheProfileData(profileModel);
        await prefs.setString('user_name', profileModel.displayName);
        await prefs.setString('login_email', profileModel.email);

        _logger.d('Profile updated successfully');
        return true;
      } else {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      _logger.e('Update profile error: $e');
      throw _handleDioException(e, 'Failed to update profile');
    } catch (e) {
      _logger.e('Unexpected update profile error: $e');
      throw Exception('Failed to update profile');
    }
  }
  // ==================== LOGOUT ====================

  Future<void> logout() async {
    try {
      _logger.d('Starting logout process...');

      final prefs = await SharedPreferences.getInstance();

      // Clear all authentication and user data
      final keysToRemove = [
        'isLoggedIn',
        'auth_token',
        'login_email',
        'user_name',
        'user_id',
        'cached_profile',
        'profile_display_name',
        'profile_user_name',
        'profile_email',
        'profile_phone_number',
        'registered_name',
        'registered_phone',
        'registered_email',
      ];

      for (String key in keysToRemove) {
        await prefs.remove(key);
      }

      // Set logout state
      await prefs.setBool('isLoggedIn', false);
      await prefs.setString('app_state', 'logged_out');
      await prefs.setInt('logout_timestamp', DateTime.now().millisecondsSinceEpoch);

      _logger.d('Logout completed successfully');
    } catch (e) {
      _logger.e('Error during logout: $e');
      throw Exception('Failed to logout properly');
    }
  }

  // ==================== HELPER METHODS ====================

  Future<void> _saveLoginData(LoginResponseModel loginResponse, String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('auth_token', loginResponse.token);
    await prefs.setString('login_email', email);
    await prefs.setString('user_name', loginResponse.displayName);
    await prefs.setString('app_state', 'logged_in');
    await prefs.remove('logout_timestamp');
  }

  Future<void> _saveRegistrationData(RegisterResponseModel registerResponse, RegisterRequestModel requestModel) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('registered_name', requestModel.displayName);
    await prefs.setString('registered_phone', requestModel.phoneNumber);
    await prefs.setString('registered_email', requestModel.email);
    await prefs.setString('user_name', requestModel.displayName);
  }

  Future<void> _cacheProfileData(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('cached_profile', json.encode(profile.toJson()));
    await prefs.setString('profile_display_name', profile.displayName);
    await prefs.setString('profile_user_name', profile.userName);
    await prefs.setString('profile_email', profile.email);
    await prefs.setString('profile_phone_number', profile.phoneNumber);
  }

  Future<UserProfileModel> _getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get full cached profile first
    String? cachedProfile = prefs.getString('cached_profile');
    if (cachedProfile != null) {
      try {
        final Map<String, dynamic> profileData = json.decode(cachedProfile);
        return UserProfileModel.fromJson(profileData);
      } catch (e) {
        _logger.e('Error parsing cached profile: $e');
      }
    }

    // Fallback to individual fields
    String email = prefs.getString('login_email') ??
        prefs.getString('profile_email') ??
        prefs.getString('registered_email') ??
        'user@example.com';

    String displayName = prefs.getString('profile_display_name') ??
        prefs.getString('user_name') ??
        prefs.getString('registered_name') ??
        _generateNameFromEmail(email);

    String userName = prefs.getString('profile_user_name') ??
        displayName.toLowerCase().replaceAll(' ', '_');

    String phoneNumber = prefs.getString('profile_phone_number') ??
        prefs.getString('registered_phone') ??
        '';

    return UserProfileModel(
      displayName: displayName,
      userName: userName,
      email: email,
      phoneNumber: phoneNumber,
    );
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

  Exception _handleDioException(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Connection timed out. Please check your internet connection.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('Unable to connect to the server. Please check your internet connection.');
    }

    // Extract error message from response
    String errorMessage = defaultMessage;
    if (e.response?.data != null) {
      if (e.response!.data is Map && e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      } else if (e.response!.data is String) {
        errorMessage = e.response!.data;
      }
    }

    return Exception(errorMessage);
  }

  // ==================== LEGACY METHODS FOR COMPATIBILITY ====================

  // These methods maintain compatibility with existing code
  Future<Map<String, dynamic>> getUserProfileLegacy() async {
    try {
      final profile = await getUserProfile();
      return profile.toJson();
    } catch (e) {
      // Return cached data in legacy format
      final prefs = await SharedPreferences.getInstance();
      return {
        'displayName': prefs.getString('user_name') ?? 'User',
        'userName': prefs.getString('profile_user_name') ?? '',
        'email': prefs.getString('login_email') ?? '',
        'phoneNumber': prefs.getString('profile_phone_number') ?? '',
        'name': prefs.getString('user_name') ?? 'User', // Legacy field
      };
    }
  }

  Future<bool> updateUserProfileLegacy({
    required String email,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final profile = UserProfileModel(
        displayName: profileData['displayName'] ?? '',
        userName: profileData['userName'] ?? '',
        email: profileData['email'] ?? email,
        phoneNumber: profileData['phoneNumber'] ?? '',
      );

      return await updateUserProfile(profile);
    } catch (e) {
      _logger.e('Legacy update profile error: $e');
      return false;
    }
  }

  // Legacy password reset methods
  Future<void> requestPasswordResetByEmail(String email) async {
    await forgotPasswordByEmail(email);
  }

  Future<void> requestPasswordResetByTelegram(String phoneNumber) async {
    await forgotPasswordByTelegram(phoneNumber);
  }

  Future<Map<String, dynamic>> verifyResetCodeLegacy(String identifier, String code) async {
    try {
      final response = await verifyResetCode(identifier, code);
      return {
        'success': response.success,
        'message': response.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<bool> resetPasswordLegacy(String identifier, String newPassword) async {
    try {
      final response = await resetPassword(identifier, newPassword);
      return response.success;
    } catch (e) {
      return false;
    }
  }
}
