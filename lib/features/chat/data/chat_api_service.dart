import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ChatApiService {
  static const baseUrl = 'https://foly884-bonefracture.hf.space';

  /// [history] is a list of {'role': 'user'|'assistant', 'content': '...'}
  Future<String> sendMessage({
    required String userMessage,
    required List<String> fractureTypes,
    required List<Map<String, String>> history,
  }) async {
    final uri = Uri.parse('$baseUrl/chat');
    final requestBody = jsonEncode({
      'user_message': userMessage,
      'fracture_types': fractureTypes,
      'history': history,
    });

    log('╔══ CHAT REQUEST ══════════════════════════════');
    log('║  URL  : $uri');
    log('║  Body : $requestBody');
    log('╚══════════════════════════════════════════════');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    log('╔══ CHAT RESPONSE ═════════════════════════════');
    log('║  Status : ${response.statusCode}');
    log('║  Body   : ${response.body}');
    log('╚══════════════════════════════════════════════');

    if (response.statusCode != 200) {
      throw Exception(
        'Chat API error (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] == 'error') {
      throw Exception(data['message'] ?? 'Unknown chat API error');
    }

    final reply =
        data['bot_response'] ??
        data['message'] ??
        data['response'] ??
        data['reply'];
    if (reply == null) {
      throw Exception('Chat API returned no message: ${response.body}');
    }
    return reply.toString();
  }
}
