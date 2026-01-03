/// Meal plan model for weekly planning.
class MealPlan {
  final String id;
  final DateTime weekStart;
  final Map<String, DayMeals> dailyMeals; // 'monday', 'tuesday', etc.
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MealPlan({
    required this.id,
    required this.weekStart,
    required this.dailyMeals,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get meals for a specific day.
  DayMeals? getMealsForDay(String day) => dailyMeals[day.toLowerCase()];

  /// Get total planned meals count.
  int get totalMeals {
    int count = 0;
    for (final day in dailyMeals.values) {
      if (day.breakfast != null) count++;
      if (day.lunch != null) count++;
      if (day.dinner != null) count++;
    }
    return count;
  }

  MealPlan copyWith({
    String? id,
    DateTime? weekStart,
    Map<String, DayMeals>? dailyMeals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      dailyMeals: dailyMeals ?? this.dailyMeals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekStart': weekStart.toIso8601String(),
      'dailyMeals': dailyMeals.map((k, v) => MapEntry(k, v.toJson())),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] ?? '',
      weekStart: DateTime.parse(json['weekStart']),
      dailyMeals: (json['dailyMeals'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, DayMeals.fromJson(v)),
          ) ??
          {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// Create empty meal plan for the week.
  factory MealPlan.empty(DateTime weekStart) {
    return MealPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weekStart: weekStart,
      dailyMeals: {
        'pazartesi': const DayMeals(),
        'salı': const DayMeals(),
        'çarşamba': const DayMeals(),
        'perşembe': const DayMeals(),
        'cuma': const DayMeals(),
        'cumartesi': const DayMeals(),
        'pazar': const DayMeals(),
      },
      createdAt: DateTime.now(),
    );
  }
}

/// Meals for a single day.
class DayMeals {
  final PlannedMeal? breakfast;
  final PlannedMeal? lunch;
  final PlannedMeal? dinner;
  final List<PlannedMeal> snacks;

  const DayMeals({
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snacks = const [],
  });

  DayMeals copyWith({
    PlannedMeal? breakfast,
    PlannedMeal? lunch,
    PlannedMeal? dinner,
    List<PlannedMeal>? snacks,
  }) {
    return DayMeals(
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast?.toJson(),
      'lunch': lunch?.toJson(),
      'dinner': dinner?.toJson(),
      'snacks': snacks.map((s) => s.toJson()).toList(),
    };
  }

  factory DayMeals.fromJson(Map<String, dynamic> json) {
    return DayMeals(
      breakfast:
          json['breakfast'] != null ? PlannedMeal.fromJson(json['breakfast']) : null,
      lunch: json['lunch'] != null ? PlannedMeal.fromJson(json['lunch']) : null,
      dinner: json['dinner'] != null ? PlannedMeal.fromJson(json['dinner']) : null,
      snacks: (json['snacks'] as List?)
              ?.map((s) => PlannedMeal.fromJson(s))
              .toList() ??
          [],
    );
  }
}

/// A planned meal with recipe reference.
class PlannedMeal {
  final String recipeId;
  final String recipeName;
  final String? imageUrl;
  final int? calories;
  final MealType type;
  final bool isCooked;

  const PlannedMeal({
    required this.recipeId,
    required this.recipeName,
    this.imageUrl,
    this.calories,
    required this.type,
    this.isCooked = false,
  });

  PlannedMeal copyWith({
    String? recipeId,
    String? recipeName,
    String? imageUrl,
    int? calories,
    MealType? type,
    bool? isCooked,
  }) {
    return PlannedMeal(
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      type: type ?? this.type,
      isCooked: isCooked ?? this.isCooked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'recipeName': recipeName,
      'imageUrl': imageUrl,
      'calories': calories,
      'type': type.name,
      'isCooked': isCooked,
    };
  }

  factory PlannedMeal.fromJson(Map<String, dynamic> json) {
    return PlannedMeal(
      recipeId: json['recipeId'] ?? '',
      recipeName: json['recipeName'] ?? '',
      imageUrl: json['imageUrl'],
      calories: json['calories'],
      type: MealType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MealType.lunch,
      ),
      isCooked: json['isCooked'] ?? false,
    );
  }
}

/// Meal types.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

/// Days of week in Turkish.
class DaysOfWeek {
  static const List<String> all = [
    'pazartesi',
    'salı',
    'çarşamba',
    'perşembe',
    'cuma',
    'cumartesi',
    'pazar',
  ];

  static String getEmoji(String day) {
    switch (day) {
      case 'pazartesi':
        return '📅';
      case 'salı':
        return '📅';
      case 'çarşamba':
        return '📅';
      case 'perşembe':
        return '📅';
      case 'cuma':
        return '🎉';
      case 'cumartesi':
        return '☀️';
      case 'pazar':
        return '🌙';
      default:
        return '📅';
    }
  }

  static String getTitle(String day) {
    return day[0].toUpperCase() + day.substring(1);
  }
}
