import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/analysis_result_model.dart';
import 'dart:typed_data';

class AnalysisRemoteDataSource {
  final String baseUrl = 'https://foly884-bonefracture.hf.space';

  Future<AnalysisResult> analyzeImage(XFile imageFile) async {
    final uri = Uri.parse('$baseUrl/predict');

    // Read bytes (works uniformly across Web, iOS, Android)
    final Uint8List imageBytes = await imageFile.readAsBytes();

    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: imageFile.name,
    );

    request.files.add(multipartFile);

    log('── Analysis Request ──────────────────────────');
    log('POST ${uri.toString()}');
    log('File: ${imageFile.name} (${imageBytes.lengthInBytes} bytes)');
    log('─────────────────────────────────────────────');

    try {
      final stopwatch = Stopwatch()..start();
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      log('── Analysis Response ─────────────────────────');
      log('Status : ${response.statusCode}');
      log('Time   : ${stopwatch.elapsedMilliseconds}ms');
      log('Body   : ${response.body}');
      log('─────────────────────────────────────────────');

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        return AnalysisResult.fromJson(decodedJson);
      } else {
        throw Exception(
          'Failed to analyze image: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      log('── Analysis Error ────────────────────────────');
      log('$e');
      log('─────────────────────────────────────────────');
      throw Exception('Network error during analysis: $e');
    }
  }
}
