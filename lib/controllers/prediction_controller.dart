import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/sign_prediction_services.dart';
import '../models/sign_prediction_model.dart';
import '../providers/auth_service.dart';

class PredictionController extends GetxController {
  final SignPredictionService _predictionService = SignPredictionService();
  late final AuthService _authService;

  // Observable variables
  var isLoading = false.obs;
  var predictions = <SignPredictionResponse>[].obs;
  var currentPrediction = Rxn<SignPredictionResponse>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _authService = Get.find<AuthService>();
      // Load local history first for immediate display
      loadLocalHistory();
      // Then try to sync with server
      loadPredictionHistory();
    } catch (e) {
      print('Error initializing prediction controller: $e');
    }
  }

  // Add a new prediction (called after successful API prediction)
  Future<void> addPrediction(SignPredictionResponse prediction) async {
    try {
      // Add to local list immediately
      predictions.insert(0, prediction);

      // Save to local storage
      await _savePredictionLocally(prediction);

      // Update prediction count
      await _updatePredictionCount();

      print('Prediction added successfully: ${prediction.predictedLabel}');
    } catch (e) {
      print('Error adding prediction: $e');
    }
  }

  // Load prediction history from API and local storage
  Future<void> loadPredictionHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get user email
      final userProfile = await _authService.getUserProfile();
      final email = userProfile['email'] ?? '';

      if (email.isEmpty) {
        print('No email found, using local history only');
        await loadLocalHistory();
        return;
      }

      // Fetch from API
      final historyResponse = await _predictionService.getUserPredictions(email);

      // Merge with local predictions to avoid duplicates
      final mergedPredictions = _mergePredictions(historyResponse.predictions);
      predictions.value = mergedPredictions;

      // Save merged results locally
      await _saveAllPredictionsLocally(mergedPredictions);

      print('History loaded successfully: ${predictions.length} predictions');

    } catch (e) {
      errorMessage.value = e.toString();
      print('Error loading history: $e');
      // Fallback to local history
      await loadLocalHistory();
    } finally {
      isLoading.value = false;
    }
  }

  // Merge API predictions with local predictions, removing duplicates
  List<SignPredictionResponse> _mergePredictions(List<SignPredictionResponse> apiPredictions) {
    final localPredictions = predictions.toList();
    final merged = <SignPredictionResponse>[];
    final seenIds = <String>{};

    // Add API predictions first (they're authoritative)
    for (final prediction in apiPredictions) {
      if (!seenIds.contains(prediction.id)) {
        merged.add(prediction);
        seenIds.add(prediction.id);
      }
    }

    // Add local predictions that aren't in API response
    for (final prediction in localPredictions) {
      if (!seenIds.contains(prediction.id)) {
        merged.add(prediction);
        seenIds.add(prediction.id);
      }
    }

    // Sort by timestamp (newest first)
    merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return merged;
  }

  // Load local history
  Future<void> loadLocalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> localPredictions = prefs.getStringList('local_predictions') ?? [];

      List<SignPredictionResponse> loadedPredictions = [];

      for (String predictionJson in localPredictions) {
        try {
          Map<String, dynamic> jsonData = jsonDecode(predictionJson);
          loadedPredictions.add(SignPredictionResponse.fromJson(jsonData));
        } catch (e) {
          print('Error parsing prediction: $e');
        }
      }

      // Sort by timestamp (newest first)
      loadedPredictions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      predictions.value = loadedPredictions;
      print('Local history loaded: ${loadedPredictions.length} predictions');
    } catch (e) {
      print('Error loading local history: $e');
      predictions.value = [];
    }
  }

  // Save single prediction locally
  Future<void> _savePredictionLocally(SignPredictionResponse prediction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> localPredictions = prefs.getStringList('local_predictions') ?? [];

      // Add new prediction to the beginning
      localPredictions.insert(0, jsonEncode(prediction.toJson()));

      // Keep only last 100 predictions to avoid storage issues
      if (localPredictions.length > 100) {
        localPredictions = localPredictions.take(100).toList();
      }

      await prefs.setStringList('local_predictions', localPredictions);
      print('Prediction saved locally');
    } catch (e) {
      print('Error saving prediction locally: $e');
    }
  }

  // Save all predictions locally
  Future<void> _saveAllPredictionsLocally(List<SignPredictionResponse> predictions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> localPredictions = predictions
          .take(100) // Keep only last 100
          .map((prediction) => jsonEncode(prediction.toJson()))
          .toList();

      await prefs.setStringList('local_predictions', localPredictions);
      print('All predictions saved locally: ${localPredictions.length}');
    } catch (e) {
      print('Error saving all predictions locally: $e');
    }
  }

  // Update prediction count
  Future<void> _updatePredictionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('prediction_count', predictions.length);
    } catch (e) {
      print('Error updating prediction count: $e');
    }
  }

  // Get prediction count
  Future<int> getPredictionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('prediction_count') ?? predictions.length;
    } catch (e) {
      return predictions.length;
    }
  }

  // Clear all predictions
  Future<void> clearAllPredictions() async {
    try {
      await _predictionService.clearLocalHistory();
      predictions.clear();
      currentPrediction.value = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('prediction_count');
      await prefs.remove('local_predictions');

      Get.snackbar(
        'Success',
        'All predictions cleared',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear predictions: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Search predictions
  List<SignPredictionResponse> searchPredictions(String query) {
    if (query.isEmpty) return predictions.toList();

    return predictions.where((prediction) =>
        prediction.predictedLabel.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Refresh predictions
  Future<void> refreshPredictions() async {
    await loadPredictionHistory();
  }

  // Get today's predictions count
  int getTodayCount() {
    final today = DateTime.now();
    return predictions.where((prediction) {
      return prediction.timestamp.year == today.year &&
          prediction.timestamp.month == today.month &&
          prediction.timestamp.day == today.day;
    }).length;
  }

  // Get predictions by date range
  List<SignPredictionResponse> getPredictionsByDateRange(DateTime start, DateTime end) {
    return predictions.where((prediction) {
      return prediction.timestamp.isAfter(start) && prediction.timestamp.isBefore(end);
    }).toList();
  }
}