import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/analysis_result_model.dart';

class AnalysisRemoteDataSource {
  final String baseUrl = 'https://foly884-bonefracture.hf.space';

  Future<AnalysisResult> analyzeImage(XFile imageFile) async {
    final uri = Uri.parse('$baseUrl/predict');
    final imageBytes = await imageFile.readAsBytes();

    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: imageFile.name,
      ));

    log('╔══ ANALYSIS REQUEST ════════════════════════');
    log('║  URL  : $uri');
    log('║  File : ${imageFile.name}');
    log('║  Size : ${imageBytes.lengthInBytes} bytes');
    log('╚════════════════════════════════════════════');

    try {
      final sw = Stopwatch()..start();
      final response = await http.Response.fromStream(await request.send());
      sw.stop();

      log('╔══ ANALYSIS RESPONSE ═══════════════════════');
      log('║  Status : ${response.statusCode}');
      log('║  Time   : ${sw.elapsedMilliseconds}ms');
      log('║  Body   : ${response.body}');
      log('╚════════════════════════════════════════════');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = AnalysisResult.fromJson(json);
        log('╔══ IMAGE RESULT ══════════════════════════════');
        log('║  imageBytes : ${result.imageBytes != null ? '${result.imageBytes!.length} bytes ✓' : 'null'}');
        log('╚════════════════════════════════════════════');
        return result;
      } else {
        throw Exception('${response.statusCode} – ${response.body}');
      }
    } catch (e) {
      log('╔══ ANALYSIS ERROR ═══════════════════════════');
      log('║  $e');
      log('╚════════════════════════════════════════════');
      throw Exception('Network error during analysis: $e');
    }
  }
}
