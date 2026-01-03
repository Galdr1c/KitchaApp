/// Weekly challenge model.
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetCount;
  final int currentCount;
  final int xpReward;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetCount,
    this.currentCount = 0,
    required this.xpReward,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });

  double get progress => (currentCount / targetCount).clamp(0.0, 1.0);

  bool get isExpired => DateTime.now().isAfter(endDate);
  
  int get daysRemaining {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    int? targetCount,
    int? currentCount,
    int? xpReward,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      xpReward: xpReward ?? this.xpReward,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'xpReward': xpReward,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.viewRecipes,
      ),
      targetCount: json['targetCount'] ?? 0,
      currentCount: json['currentCount'] ?? 0,
      xpReward: json['xpReward'] ?? 0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

/// Types of challenges.
enum ChallengeType {
  viewRecipes,      // View X recipes
  analyzeCalories,  // Analyze X meals
  addFavorites,     // Add X favorites
  useAICamera,      // Use AI camera X times
  dailyStreak,      // Maintain X day streak
  cookRecipes,      // Mark X recipes as cooked
  shareRecipes,     // Share X recipes
}

/// Predefined weekly challenges.
class WeeklyChallenges {
  static List<Challenge> getForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));

    return [
      Challenge(
        id: 'weekly_view_10',
        title: 'Tarif Kaşifi',
        description: '10 farklı tarif keşfet',
        type: ChallengeType.viewRecipes,
        targetCount: 10,
        xpReward: 50,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      Challenge(
        id: 'weekly_analyze_5',
        title: 'Kalori Takipçisi',
        description: '5 öğün analiz et',
        type: ChallengeType.analyzeCalories,
        targetCount: 5,
        xpReward: 40,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      Challenge(
        id: 'weekly_favorite_3',
        title: 'Koleksiyoncu',
        description: '3 tarifi favorilere ekle',
        type: ChallengeType.addFavorites,
        targetCount: 3,
        xpReward: 30,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      Challenge(
        id: 'weekly_cook_2',
        title: 'Mutfak Ustası',
        description: '2 tarifi pişir ve işaretle',
        type: ChallengeType.cookRecipes,
        targetCount: 2,
        xpReward: 60,
        startDate: weekStart,
        endDate: weekEnd,
      ),
    ];
  }

  /// Get the start of current week (Monday).
  static DateTime getCurrentWeekStart() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1 = Monday
    return DateTime(now.year, now.month, now.day - dayOfWeek + 1);
  }
}
