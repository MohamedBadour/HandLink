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
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  // Initialize controller with proper error handling
  Future<void> _initializeController() async {
    try {
      _authService = Get.find<AuthService>();

      // Load local history first for immediate display
      await loadLocalHistory();

      // Mark as initialized so UI can show data immediately
      isInitialized.value = true;

      // Then try to sync with server in background
      await loadPredictionHistory();

      print('Prediction controller initialized successfully');
    } catch (e) {
      print('Error initializing prediction controller: $e');
      // Even if there's an error, try to load local history
      await loadLocalHistory();
      isInitialized.value = true;
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
      // Show error to user
      Get.snackbar(
        'Error',
        'Failed to save prediction: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Load prediction history from API and local storage with better error handling
  Future<void> loadPredictionHistory() async {
    try {
      if (isLoading.value) return; // Prevent multiple simultaneous loads

      isLoading.value = true;
      errorMessage.value = '';

      // Get user profile using the new method
      final userProfile = await _authService.getUserProfile();
      final email = userProfile.email;

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
      // Don't reload local history if we already have data
      if (predictions.isEmpty) {
        await loadLocalHistory();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Merge API predictions with local predictions, removing duplicates
  List<SignPredictionResponse> _mergePredictions(List<SignPredictionResponse> apiPredictions) {
    try {
      final localPredictions = predictions.toList();
      final merged = <SignPredictionResponse>[];
      final seenIds = <String>{};

      // Add API predictions first (they're authoritative)
      for (final prediction in apiPredictions) {
        final id = prediction.id.isNotEmpty ? prediction.id : prediction.timestamp.millisecondsSinceEpoch.toString();
        if (!seenIds.contains(id)) {
          merged.add(prediction);
          seenIds.add(id);
        }
      }

      // Add local predictions that aren't in API response
      for (final prediction in localPredictions) {
        final id = prediction.id.isNotEmpty ? prediction.id : prediction.timestamp.millisecondsSinceEpoch.toString();
        if (!seenIds.contains(id)) {
          merged.add(prediction);
          seenIds.add(id);
        }
      }

      // Sort by timestamp (newest first)
      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return merged;
    } catch (e) {
      print('Error merging predictions: $e');
      return predictions.toList();
    }
  }

  // Load local history with better error handling
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
          // Continue with other predictions instead of failing completely
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

  // Save single prediction locally with better error handling
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
      throw e; // Re-throw to handle in calling method
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

  // Search predictions with better error handling
  List<SignPredictionResponse> searchPredictions(String query) {
    try {
      if (query.isEmpty) return predictions.toList();

      final lowercaseQuery = query.toLowerCase().trim();

      return predictions.where((prediction) {
        try {
          final label = prediction.predictedLabel?.toLowerCase() ?? '';
          return label.contains(lowercaseQuery);
        } catch (e) {
          print('Error filtering prediction: $e');
          return false;
        }
      }).toList();
    } catch (e) {
      print('Error in searchPredictions: $e');
      return predictions.toList(); // Return all predictions if search fails
    }
  }

  // Refresh predictions
  Future<void> refreshPredictions() async {
    await loadPredictionHistory();
  }

  // Get today's predictions count
  int getTodayCount() {
    try {
      final today = DateTime.now();
      return predictions.where((prediction) {
        try {
          return prediction.timestamp.year == today.year &&
              prediction.timestamp.month == today.month &&
              prediction.timestamp.day == today.day;
        } catch (e) {
          return false;
        }
      }).length;
    } catch (e) {
      print('Error getting today count: $e');
      return 0;
    }
  }

  // Get predictions by date range
  List<SignPredictionResponse> getPredictionsByDateRange(DateTime start, DateTime end) {
    try {
      return predictions.where((prediction) {
        try {
          return prediction.timestamp.isAfter(start) && prediction.timestamp.isBefore(end);
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      print('Error getting predictions by date range: $e');
      return [];
    }
  }

  // Force reload all data
  Future<void> forceReload() async {
    predictions.clear();
    await _initializeController();
  }
}
