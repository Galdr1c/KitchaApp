/// Complete recipe model for the custom Kitcha recipe database.
class KitchaRecipe {
  final String id;
  final String titleTR;
  final String? titleEN;
  final String? descriptionTR;
  final String? descriptionEN;
  final String category;
  final String difficulty;
  final int prepTime;
  final int cookTime;
  final int servings;
  final int calories;
  final List<RecipeIngredient> ingredients;
  final List<String> instructionsTR;
  final List<String>? instructionsEN;
  final String? imageUrl;
  final List<String> tags;
  final bool isPremium;
  final double averageRating;
  final int totalRatings;
  final String? authorId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const KitchaRecipe({
    required this.id,
    required this.titleTR,
    this.titleEN,
    this.descriptionTR,
    this.descriptionEN,
    required this.category,
    required this.difficulty,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.calories,
    required this.ingredients,
    required this.instructionsTR,
    this.instructionsEN,
    this.imageUrl,
    required this.tags,
    this.isPremium = false,
    this.averageRating = 0,
    this.totalRatings = 0,
    this.authorId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get title in specified language.
  String getTitle(String lang) {
    if (lang == 'en' && titleEN != null) return titleEN!;
    return titleTR;
  }

  /// Get description in specified language.
  String? getDescription(String lang) {
    if (lang == 'en' && descriptionEN != null) return descriptionEN;
    return descriptionTR;
  }

  /// Get instructions in specified language.
  List<String> getInstructions(String lang) {
    if (lang == 'en' && instructionsEN != null) return instructionsEN!;
    return instructionsTR;
  }

  /// Total time.
  int get totalTime => prepTime + cookTime;

  /// Difficulty level.
  String get difficultyDisplay {
    switch (difficulty.toLowerCase()) {
      case 'kolay':
      case 'easy':
        return '⭐';
      case 'orta':
      case 'medium':
        return '⭐⭐';
      case 'zor':
      case 'hard':
        return '⭐⭐⭐';
      default:
        return '⭐';
    }
  }

  KitchaRecipe copyWith({
    String? id,
    String? titleTR,
    String? titleEN,
    String? descriptionTR,
    String? descriptionEN,
    String? category,
    String? difficulty,
    int? prepTime,
    int? cookTime,
    int? servings,
    int? calories,
    List<RecipeIngredient>? ingredients,
    List<String>? instructionsTR,
    List<String>? instructionsEN,
    String? imageUrl,
    List<String>? tags,
    bool? isPremium,
    double? averageRating,
    int? totalRatings,
    String? authorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KitchaRecipe(
      id: id ?? this.id,
      titleTR: titleTR ?? this.titleTR,
      titleEN: titleEN ?? this.titleEN,
      descriptionTR: descriptionTR ?? this.descriptionTR,
      descriptionEN: descriptionEN ?? this.descriptionEN,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      instructionsTR: instructionsTR ?? this.instructionsTR,
      instructionsEN: instructionsEN ?? this.instructionsEN,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      isPremium: isPremium ?? this.isPremium,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleTR': titleTR,
      'titleEN': titleEN,
      'descriptionTR': descriptionTR,
      'descriptionEN': descriptionEN,
      'category': category,
      'difficulty': difficulty,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'calories': calories,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructionsTR': instructionsTR,
      'instructionsEN': instructionsEN,
      'imageUrl': imageUrl,
      'tags': tags,
      'isPremium': isPremium,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory KitchaRecipe.fromJson(Map<String, dynamic> json) {
    return KitchaRecipe(
      id: json['id'] ?? '',
      titleTR: json['titleTR'] ?? json['title'] ?? '',
      titleEN: json['titleEN'],
      descriptionTR: json['descriptionTR'] ?? json['description'],
      descriptionEN: json['descriptionEN'],
      category: json['category'] ?? 'Ana Yemek',
      difficulty: json['difficulty'] ?? 'Kolay',
      prepTime: json['prepTime'] ?? 0,
      cookTime: json['cookTime'] ?? 0,
      servings: json['servings'] ?? 4,
      calories: json['calories'] ?? 0,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((i) => RecipeIngredient.fromJson(i is Map<String, dynamic> ? i : {'name': i}))
              .toList() ??
          [],
      instructionsTR: List<String>.from(json['instructionsTR'] ?? json['instructions'] ?? []),
      instructionsEN: json['instructionsEN'] != null
          ? List<String>.from(json['instructionsEN'])
          : null,
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      isPremium: json['isPremium'] ?? false,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      authorId: json['authorId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

/// Recipe ingredient with quantity and unit.
class RecipeIngredient {
  final String name;
  final String? quantity;
  final String? unit;
  final bool isOptional;

  const RecipeIngredient({
    required this.name,
    this.quantity,
    this.unit,
    this.isOptional = false,
  });

  String get displayText {
    final parts = <String>[];
    if (quantity != null) parts.add(quantity!);
    if (unit != null) parts.add(unit!);
    parts.add(name);
    if (isOptional) parts.add('(isteğe bağlı)');
    return parts.join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isOptional': isOptional,
    };
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] ?? '',
      quantity: json['quantity'],
      unit: json['unit'],
      isOptional: json['isOptional'] ?? false,
    );
  }
}

/// Recipe category enum.
class RecipeCategories {
  static const List<String> all = [
    'Ana Yemek',
    'Çorba',
    'Salata',
    'Tatlı',
    'Kahvaltı',
    'Aperatif',
    'İçecek',
    'Hamur İşi',
    'Sebze Yemekleri',
    'Et Yemekleri',
    'Tavuk Yemekleri',
    'Deniz Ürünleri',
    'Pilav',
    'Makarna',
    'Vegan',
    'Diyet',
  ];

  static const Map<String, String> icons = {
    'Ana Yemek': '🍽️',
    'Çorba': '🥣',
    'Salata': '🥗',
    'Tatlı': '🍰',
    'Kahvaltı': '🥐',
    'Aperatif': '🧆',
    'İçecek': '🥤',
    'Hamur İşi': '🥧',
    'Sebze Yemekleri': '🥦',
    'Et Yemekleri': '🥩',
    'Tavuk Yemekleri': '🍗',
    'Deniz Ürünleri': '🦐',
    'Pilav': '🍚',
    'Makarna': '🍝',
    'Vegan': '🌱',
    'Diyet': '💚',
  };

  static String getIcon(String category) {
    return icons[category] ?? '🍽️';
  }
}
