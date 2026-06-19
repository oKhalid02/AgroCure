class Prediction {
  final String plant;
  final String disease;
  final String label;
  final double confidence;
  final String confidencePct;
  final String confidenceLevel;
  final DateTime timestamp;
  final String imagePath;

  Prediction({
    required this.plant,
    required this.disease,
    required this.label,
    required this.confidence,
    required this.confidencePct,
    required this.confidenceLevel,
    required this.timestamp,
    required this.imagePath,
  });

  factory Prediction.fromJson(Map<String, dynamic> json, String imagePath) {
    return Prediction(
      plant:           json['plant'],
      disease:         json['disease'],
      label:           json['label'],
      confidence:      (json['confidence'] as num).toDouble(),
      confidencePct:   json['confidence_pct'],
      confidenceLevel: json['confidence_level'],
      timestamp:       DateTime.now(),
      imagePath:       imagePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'plant':            plant,
    'disease':          disease,
    'label':            label,
    'confidence':       confidence,
    'confidence_pct':   confidencePct,
    'confidence_level': confidenceLevel,
    'timestamp':        timestamp.toIso8601String(),
    'image_path':       imagePath,
  };
}
