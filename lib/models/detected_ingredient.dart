/// Model for detected ingredient from AI scan.
class DetectedIngredient {
  final String name;
  final String? nameTR;
  final double confidence;
  bool isSelected;

  DetectedIngredient({
    required this.name,
    this.nameTR,
    required this.confidence,
    this.isSelected = true,
  });

  /// Display name (Turkish if available).
  String get displayName => nameTR ?? name;

  /// Confidence percentage.
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';

  /// Is high confidence (> 70%).
  bool get isHighConfidence => confidence > 0.7;

  /// Create from ML Kit label.
  factory DetectedIngredient.fromLabel(String label, double confidence) {
    final mapping = IngredientMapping.get(label.toLowerCase());
    return DetectedIngredient(
      name: label,
      nameTR: mapping,
      confidence: confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameTR': nameTR,
      'confidence': confidence,
      'isSelected': isSelected,
    };
  }

  factory DetectedIngredient.fromJson(Map<String, dynamic> json) {
    return DetectedIngredient(
      name: json['name'] ?? '',
      nameTR: json['nameTR'],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      isSelected: json['isSelected'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetectedIngredient &&
        other.name.toLowerCase() == name.toLowerCase();
  }

  @override
  int get hashCode => name.toLowerCase().hashCode;
}

/// English to Turkish ingredient mapping.
class IngredientMapping {
  static const Map<String, String> _map = {
    // Vegetables
    'tomato': 'domates',
    'potato': 'patates',
    'onion': 'soğan',
    'garlic': 'sarımsak',
    'carrot': 'havuç',
    'pepper': 'biber',
    'cucumber': 'salatalık',
    'eggplant': 'patlıcan',
    'zucchini': 'kabak',
    'spinach': 'ıspanak',
    'lettuce': 'marul',
    'cabbage': 'lahana',
    'broccoli': 'brokoli',
    'mushroom': 'mantar',
    'pea': 'bezelye',
    'corn': 'mısır',
    'bean': 'fasulye',
    'lentil': 'mercimek',

    // Fruits
    'apple': 'elma',
    'banana': 'muz',
    'orange': 'portakal',
    'lemon': 'limon',
    'grape': 'üzüm',
    'strawberry': 'çilek',
    'watermelon': 'karpuz',
    'melon': 'kavun',

    // Proteins
    'chicken': 'tavuk',
    'beef': 'sığır eti',
    'lamb': 'kuzu eti',
    'fish': 'balık',
    'egg': 'yumurta',
    'shrimp': 'karides',
    'meat': 'et',

    // Dairy
    'milk': 'süt',
    'cheese': 'peynir',
    'yogurt': 'yoğurt',
    'butter': 'tereyağı',
    'cream': 'krema',

    // Grains
    'bread': 'ekmek',
    'rice': 'pirinç',
    'pasta': 'makarna',
    'flour': 'un',
    'bulgur': 'bulgur',

    // Others
    'oil': 'yağ',
    'olive': 'zeytin',
    'parsley': 'maydanoz',
    'mint': 'nane',
    'salt': 'tuz',
    'sugar': 'şeker',
    'honey': 'bal',
  };

  static String? get(String englishName) {
    final lower = englishName.toLowerCase();
    
    // Direct match
    if (_map.containsKey(lower)) {
      return _map[lower];
    }
    
    // Partial match
    for (final entry in _map.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }
    
    return null;
  }

  static List<String> get allTurkish => _map.values.toList();
  static List<String> get allEnglish => _map.keys.toList();
}
