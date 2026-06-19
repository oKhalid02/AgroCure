import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config.dart';
import '../models/prediction.dart';
import '../models/chat_message.dart';

class ApiService {
  /// Resolved from --dart-define=API_URL (defaults to localhost in dev).
  static const String baseUrl = ApiConfig.baseUrl;

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

  /// Sends raw image bytes to the model. Works on web, iOS and Android.
  static Future<Prediction> predict(Uint8List bytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/predict'),
    );
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'leaf.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Prediction.fromJson(json, '');
    } else {
      throw Exception('Prediction failed: ${response.body}');
    }
  }

  /// Sage — the AI companion.
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
