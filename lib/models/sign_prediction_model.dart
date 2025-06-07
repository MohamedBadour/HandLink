class SignPredictionRequest {
  final String email;
  final String filePath;

  SignPredictionRequest({
    required this.email,
    required this.filePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class SignPredictionResponse {
  final String id;
  final String predictedLabel;
  final double confidence;
  final String imagePath;
  final DateTime timestamp;
  final String userEmail;

  SignPredictionResponse({
    required this.id,
    required this.predictedLabel,
    required this.confidence,
    required this.imagePath,
    required this.timestamp,
    required this.userEmail,
  });

  factory SignPredictionResponse.fromJson(Map<String, dynamic> json) {
    return SignPredictionResponse(
      id: json['id']?.toString() ?? '',
      predictedLabel: json['predictedLabel'] ?? json['predicted_label'] ?? '',
      confidence: (json['confidence'] ?? json['confidence_score'] ?? 0.0).toDouble(),
      imagePath: json['imagePath'] ?? json['image_path'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      userEmail: json['userEmail'] ?? json['user_email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'predictedLabel': predictedLabel,
      'confidence': confidence,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'userEmail': userEmail,
    };
  }
}

class PredictionHistoryResponse {
  final List<SignPredictionResponse> predictions;
  final int totalCount;

  PredictionHistoryResponse({
    required this.predictions,
    required this.totalCount,
  });

  factory PredictionHistoryResponse.fromJson(Map<String, dynamic> json) {
    var predictionsJson = json['predictions'] ?? json['data'] ?? [];
    List<SignPredictionResponse> predictions = [];

    if (predictionsJson is List) {
      predictions = predictionsJson
          .map((item) => SignPredictionResponse.fromJson(item))
          .toList();
    }

    return PredictionHistoryResponse(
      predictions: predictions,
      totalCount: json['totalCount'] ?? json['total'] ?? predictions.length,
    );
  }
}
