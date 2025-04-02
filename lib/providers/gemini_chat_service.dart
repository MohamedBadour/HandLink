import 'package:dio/dio.dart';

class GeminiChatService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://api.google.com/gemini"; // Replace with the actual base URL
  final String _apiKey = "AIzaSyCSzdEg7NTP4u_aLt4TlZW5WyHxi2Hq8r0"; // Replace with your actual API key

  GeminiChatService() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
  }

  Future<String> sendMessage(String message) async {
    final String url = "$_baseUrl/chat"; // Replace with the actual endpoint

    try {
      final response = await _dio.post(
        url,
        data: {'message': message},
      );

      if (response.statusCode == 200) {
        return response.data['response'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode} ${response.data}');
      }
    } on DioError catch (e) {
      print("Error sending message: ${e.response?.data ?? e.message}");
      throw Exception('An error occurred: ${e.response?.data ?? e.message}');
    }
  }
}