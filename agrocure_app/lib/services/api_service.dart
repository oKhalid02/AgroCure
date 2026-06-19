import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/prediction.dart';
import '../models/chat_message.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Prediction> predict(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/predict'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Prediction.fromJson(json, imageFile.path);
    } else {
      throw Exception('Prediction failed: ${response.body}');
    }
  }

  /// Sage — the AI companion. Sends the conversation (and the optional
  /// diagnosis context) to the backend, which calls OpenAI.
  static Future<String> chat({
    required List<ChatMessage> messages,
    String? plant,
    String? disease,
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'plant': plant,
            'disease': disease,
            'messages': messages.map((m) => m.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['reply'] as String;
    } else {
      throw Exception('Chat failed: ${res.body}');
    }
  }
}
