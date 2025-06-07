import 'package:dio/dio.dart';

// Define ChatMessage class
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.imageUrl,
  }) : timestamp = timestamp ?? DateTime.now();
}

// Define ApiService class (handles API calls)
class ApiService {
  final Dio _dio = Dio();

  final String _groqApiKey = "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";
  final String _geminiApiKey = "AIzaSyCSzdEg7NTP4u_aLt4TlZW5WyHxi2Hq8r0";

  final String _groqBaseUrl = "https://api.groq.com/openai/v1/chat/completions";
  final String _geminiBaseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  // Send a message to the selected API (Groq or Gemini)
  Future<String> sendMessage(String message, {bool useGroq = true}) async {
    if (useGroq) {
      return await sendGroqMessage(message);
    } else {
      return await sendGeminiMessage(message);
    }
  }

  // Send message to Groq API
  Future<String> sendGroqMessage(String message) async {
    try {
      final response = await _dio.post(
        _groqBaseUrl,
        data: {
          'model': 'llama-3.3-70b-versatile',
          'messages': [{'role': 'user', 'content': message}],
        },
        options: Options(
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_groqApiKey'},
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

  // Send message to Gemini API
  Future<String> sendGeminiMessage(String message) async {
    try {
      final response = await _dio.post(
        "$_geminiBaseUrl?key=$_geminiApiKey",
        data: {
          'contents': [
            {'role': 'user', 'parts': [{'text': message}]}
          ],
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
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

  // Example method for processing sign language images
  Future<Response> processSignLanguageImage(FormData data) async {
    try {
      final response = await _dio.post(
        'http://sign-language.runasp.net/api/UploadPhoto/predict',
        data: data,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );
      return response;
    } catch (e) {
      print("Error processing sign language image: $e");
      rethrow;
    }
  }
}

class SignLanguageChatbotController {
  final ApiService _chatService = ApiService();
  final List<ChatMessage> _chatHistory = [];

  List<ChatMessage> get chatHistory => List.from(_chatHistory);

  // Add message to history
  void _addMessage(String text, bool isUser, {String? imageUrl}) {
    _chatHistory.add(ChatMessage(
      text: text,
      isUser: isUser,
      imageUrl: imageUrl,
    ));
  }

  // Method to chat with the bot
  Future<String> chat(String message) async {
    _addMessage(message, true);

    try {
      final response = await _chatService.sendMessage(message);
      _addMessage(response, false);
      return response;
    } catch (e) {
      final errorMessage = "Sorry, I couldn't respond to that message. Please try again.";
      _addMessage(errorMessage, false);
      return errorMessage;
    }
  }

  // Method to process sign language image
  Future<String> processSignLanguageImage(String imagePath) async {
    _addMessage("Processing your sign language image...", false);

    try {
      final data = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath, filename: 'file'),
      });

      final response = await _chatService.processSignLanguageImage(data);

      if (response.statusCode == 200) {
        final predictedLabel = response.data['predictedLabel'] ?? "Unknown sign";
        _addMessage("Predicted sign: $predictedLabel", false);
        return await chat(predictedLabel); // Send predicted label to chat
      } else {
        final errorMessage = "Sorry, I couldn't recognize the sign in this image. Please try again with a clearer image.";
        _addMessage(errorMessage, false);
        return errorMessage;
      }
    } catch (e) {
      final errorMessage = "Sorry, there was an error processing your image. Please try again.";
      _addMessage(errorMessage, false);
      return errorMessage;
    }
  }

  // Method to get practice exercises for a given level
  Future<String> getPracticeExercises(String level) async {
    try {
      final response = await _chatService.sendMessage("Practice exercises for $level level sign language.");
      _addMessage(response, false);
      return response;
    } catch (e) {
      final errorMessage = "Sorry, I couldn't provide practice exercises right now. Please try again later.";
      _addMessage(errorMessage, false);
      return errorMessage;
    }
  }

  // Clear the conversation history
  void clearConversation() {
    _chatHistory.clear();
  }

  // Get raw conversation history for debugging
  List<Map<String, dynamic>> getRawConversationHistory() {
    return _chatHistory.map((e) => {
      'text': e.text,
      'isUser': e.isUser,
      'timestamp': e.timestamp.toString(),
      'imageUrl': e.imageUrl,
    }).toList();
  }
}
