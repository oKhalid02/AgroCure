import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction.dart';

class HistoryService {
  static const _key = 'prediction_history';

  static Future<List<Prediction>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return Prediction(
        plant:           map['plant'],
        disease:         map['disease'],
        label:           map['label'],
        confidence:      (map['confidence'] as num).toDouble(),
        confidencePct:   map['confidence_pct'],
        confidenceLevel: map['confidence_level'],
        timestamp:       DateTime.parse(map['timestamp']),
        imagePath:       map['image_path'],
      );
    }).toList().reversed.toList();
  }

  static Future<void> save(Prediction p) async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(p.toJson()));
    if (raw.length > 20) raw.removeAt(0);
    await prefs.setStringList(_key, raw);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
