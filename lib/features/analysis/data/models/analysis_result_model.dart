import 'dart:convert';
import 'dart:typed_data';

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
  final Uint8List? imageBytes;

  AnalysisResult({
    required this.detections,
    required this.imageResult,
    this.imageBytes,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final b64 = json['image_base64'] as String?;
    return AnalysisResult(
      detections: (json['detections'] as List)
          .map((e) => Detection.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageResult: b64 ?? '',
      imageBytes: b64 != null ? base64Decode(b64) : null,
    );
  }
}
