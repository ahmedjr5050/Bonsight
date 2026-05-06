class Detection {
  final String fractureType;
  final double confidence;
  final String description;
  final String severity;
  final String treatment;

  Detection({
    required this.fractureType,
    required this.confidence,
    required this.description,
    required this.severity,
    required this.treatment,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      fractureType: json['fracture_type'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String,
      severity: json['severity'] as String,
      treatment: json['treatment'] as String,
    );
  }
}

class AnalysisResult {
  final List<Detection> detections;
  final String imageResult;

  AnalysisResult({
    required this.detections,
    required this.imageResult,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      detections: (json['detections'] as List)
          .map((e) => Detection.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageResult: json['image_result'] as String,
    );
  }
}
