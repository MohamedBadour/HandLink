import 'package:dio/dio.dart';
import '../models/register_model.dart';
import '../models/login_model.dart';

class AuthService {
  final Dio _dio = Dio();
  final String _baseUrl = "http://sign-language.runasp.net/api/Account";

  // LOGIN
  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    final String url = "$_baseUrl/login";
    print("Login request to $url with payload: ${requestModel.toJson()}");

    try {
      final response = await _dio.post(
        url,
        data: requestModel.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print("Login response status: ${response.statusCode}");
      print("Login response body: ${response.data}");

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception('Login failed: ${response.statusCode} ${response.data}');
      }
    } on DioError catch (e) {
      print("Login error: ${e.response?.data ?? e.message}");
      throw Exception('An error occurred during login: ${e.response?.data ?? e.message}');
    }
  }

  // REGISTER
  Future<RegisterResponseModel> register(RegisterRequestModel requestModel) async {
    final String url = "$_baseUrl/register";
    print("Register request to $url with payload: ${requestModel.toJson()}");

    try {
      final response = await _dio.post(
        url,
        data: requestModel.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print("Register response status: ${response.statusCode}");
      print("Register response body: ${response.data}");

      if (response.statusCode == 200) {
        return RegisterResponseModel.fromJson(response.data);
      } else {
        throw Exception('Registration failed: ${response.statusCode} ${response.data}');
      }
    } on DioError catch (e) {
      print("Registration error: ${e.response?.data ?? e.message}");
      throw Exception('An error occurred during registration: ${e.response?.data ?? e.message}');
    }
  }
}