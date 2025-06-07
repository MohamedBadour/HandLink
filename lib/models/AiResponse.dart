class AiResponse {
  final String predictedLabel;
  final String confidence;

  AiResponse({required this.predictedLabel, required this.confidence});

  // fromJson factory constructor - updated to match API response
  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      predictedLabel: json['predicted_label'] as String? ?? '',
      confidence: json['confidence'] as String? ?? '0%',
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'predicted_label': predictedLabel,
      'confidence': confidence,
    };
  }

  // copyWith method
  AiResponse copyWith({
    String? predictedLabel,
    String? confidence,
  }) {
    return AiResponse(
      predictedLabel: predictedLabel ?? this.predictedLabel,
      confidence: confidence ?? this.confidence,
    );
  }
}
