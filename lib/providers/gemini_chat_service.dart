import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  // API keys for Groq and Gemini
  final String _groqApiKey = "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";
  final String _geminiApiKey = "AIzaSyCSzdEg7NTP4u_aLt4TlZW5WyHxi2Hq8r0";

  // API URLs for Groq and Gemini
  final String _groqBaseUrl = "https://api.groq.com/openai/v1/chat/completions";
  final String _geminiBaseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  // Method for sending messages to the Groq API
  Future<String> sendGroqMessage(String message) async {
    try {
      final response = await _dio.post(
        _groqBaseUrl,
        data: {
          'model': 'llama-3.3-70b-versatile', // Example model; replace if needed
          'messages': [
            {
              'role': 'user',
              'content': message
            }
          ],
        },
        options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_groqApiKey',
            }
        ),
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'] ?? "No response from Groq API.";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      print("Error sending message to Groq: $e");
      return "An error occurred while sending your message to Groq.";
    }
  }

  // Method for sending messages to the Gemini API
  Future<String> sendGeminiMessage(String message) async {
    try {
      final response = await _dio.post(
        "$_geminiBaseUrl?key=$_geminiApiKey",
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': message}
              ]
            }
          ],
        },
        options: Options(
            headers: {
              'Content-Type': 'application/json',
            }
        ),
      );

      if (response.statusCode == 200) {
        return response.data['candidates'][0]['content']['parts'][0]['text'] ?? "No response from Gemini API.";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      print("Error sending message to Gemini: $e");
      return "An error occurred while sending your message to Gemini.";
    }
  }

  // Method to send a message (can choose which API to use based on context)
  Future<String> sendMessage(String message, {bool useGroq = true}) async {
    if (useGroq) {
      return await sendGroqMessage(message);
    } else {
      return await sendGeminiMessage(message);
    }
  }
}

void main() async {
  final apiService = ApiService();

  // Example usage of sending a message to the Groq API
  String groqResponse = await apiService.sendMessage("Explain the importance of fast language models", useGroq: true);
  print("Groq Response: $groqResponse");

  // Example usage of sending a message to the Gemini API
  String geminiResponse = await apiService.sendMessage("Explain the importance of fast language models", useGroq: false);
  print("Gemini Response: $geminiResponse");
}
