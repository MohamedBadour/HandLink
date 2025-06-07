import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/sign_prediction_model.dart';
import 'dart:convert';
import 'dart:io';

class SignPredictionService {
  final Dio _dio;
  final Logger _logger;
  final String _baseUrl;

  SignPredictionService()
      : _dio = Dio(),
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
        _baseUrl = "http://sign-language.runasp.net/api/SignPrediction";

  // Get user's prediction history
  Future<PredictionHistoryResponse> getUserPredictions(String email) async {
    try {
      _logger.d('Fetching predictions for email: $email');

      final response = await _dio.get(
        '$_baseUrl/userPredictions',
        queryParameters: {'email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );



      _logger.d('History response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final historyResponse = PredictionHistoryResponse.fromJson(response.data);

        // Update local storage
        await _saveHistoryLocally(historyResponse.predictions);

        return historyResponse;
      } else {
        // Fallback to local data
        return await _getLocalHistory();
      }
    } on DioException catch (e) {
      _logger.e('History fetch error: ${e.response?.data ?? e.message}');

      // Return local data on network error
      return await _getLocalHistory();
    } catch (e) {
      _logger.e('Unexpected history error: $e');
      return await _getLocalHistory();
    }
  }

  // Save prediction to local storage
  Future<void> _savePredictionLocally(SignPredictionResponse prediction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> localPredictions = prefs.getStringList('local_predictions') ?? [];

      // Add new prediction to the beginning
      localPredictions.insert(0, jsonEncode(prediction.toJson()));

      // Keep only last 50 predictions
      if (localPredictions.length > 50) {
        localPredictions = localPredictions.take(50).toList();
      }

      await prefs.setStringList('local_predictions', localPredictions);
      _logger.d('Prediction saved locally');
    } catch (e) {
      _logger.e('Error saving prediction locally: $e');
    }
  }

  // Save history to local storage
  Future<void> _saveHistoryLocally(List<SignPredictionResponse> predictions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> localPredictions = predictions
          .map((prediction) => jsonEncode(prediction.toJson()))
          .toList();

      await prefs.setStringList('local_predictions', localPredictions);
      _logger.d('History saved locally');
    } catch (e) {
      _logger.e('Error saving history locally: $e');
    }
  }

  // Get local history
  Future<PredictionHistoryResponse> _getLocalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> localPredictions = prefs.getStringList('local_predictions') ?? [];

      List<SignPredictionResponse> predictions = [];

      for (String predictionJson in localPredictions) {
        try {
          Map<String, dynamic> jsonData = jsonDecode(predictionJson);
          predictions.add(SignPredictionResponse.fromJson(jsonData));
        } catch (e) {
          _logger.e('Error parsing local prediction: $e');
        }
      }

      return PredictionHistoryResponse(
        predictions: predictions,
        totalCount: predictions.length,
      );
    } catch (e) {
      _logger.e('Error getting local history: $e');
      return PredictionHistoryResponse(predictions: [], totalCount: 0);
    }
  }

  // Clear local history
  Future<void> clearLocalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_predictions');
      _logger.d('Local history cleared');
    } catch (e) {
      _logger.e('Error clearing local history: $e');
    }
  }
}
