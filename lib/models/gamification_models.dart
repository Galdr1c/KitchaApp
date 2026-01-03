/// Gamification models for XP, badges, and achievements.

/// User's gamification statistics.
class UserStats {
  final int totalXP;
  final int level;
  final int recipesViewed;
  final int recipesCooked;
  final int caloriesAnalyzed;
  final int daysStreak;
  final int longestStreak;
  final List<String> unlockedBadgeIds;
  final DateTime? lastActivityDate;

  const UserStats({
    this.totalXP = 0,
    this.level = 1,
    this.recipesViewed = 0,
    this.recipesCooked = 0,
    this.caloriesAnalyzed = 0,
    this.daysStreak = 0,
    this.longestStreak = 0,
    this.unlockedBadgeIds = const [],
    this.lastActivityDate,
  });

  /// Calculate level from XP.
  static int calculateLevel(int xp) {
    // Level formula: level = sqrt(xp / 100) + 1
    return (xp / 100).floor() ~/ 10 + 1;
  }

  /// Calculate XP needed for next level.
  int get xpForNextLevel {
    return (level * level) * 100;
  }

  /// Progress percentage to next level.
  double get levelProgress {
    final prevLevelXP = ((level - 1) * (level - 1)) * 100;
    final currentLevelXP = totalXP - prevLevelXP;
    final neededXP = xpForNextLevel - prevLevelXP;
    return (currentLevelXP / neededXP).clamp(0.0, 1.0);
  }

  UserStats copyWith({
    int? totalXP,
    int? level,
    int? recipesViewed,
    int? recipesCooked,
    int? caloriesAnalyzed,
    int? daysStreak,
    int? longestStreak,
    List<String>? unlockedBadgeIds,
    DateTime? lastActivityDate,
  }) {
    return UserStats(
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      recipesViewed: recipesViewed ?? this.recipesViewed,
      recipesCooked: recipesCooked ?? this.recipesCooked,
      caloriesAnalyzed: caloriesAnalyzed ?? this.caloriesAnalyzed,
      daysStreak: daysStreak ?? this.daysStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXP': totalXP,
      'level': level,
      'recipesViewed': recipesViewed,
      'recipesCooked': recipesCooked,
      'caloriesAnalyzed': caloriesAnalyzed,
      'daysStreak': daysStreak,
      'longestStreak': longestStreak,
      'unlockedBadgeIds': unlockedBadgeIds,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXP: json['totalXP'] ?? 0,
      level: json['level'] ?? 1,
      recipesViewed: json['recipesViewed'] ?? 0,
      recipesCooked: json['recipesCooked'] ?? 0,
      caloriesAnalyzed: json['caloriesAnalyzed'] ?? 0,
      daysStreak: json['daysStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      unlockedBadgeIds: List<String>.from(json['unlockedBadgeIds'] ?? []),
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'])
          : null,
    );
  }
}

/// Badge/Achievement definition.
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final int requiredValue;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final int xpReward;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.requiredValue,
    required this.category,
    this.rarity = BadgeRarity.common,
    this.xpReward = 50,
  });
}

/// Badge categories.
enum BadgeCategory {
  recipes,      // Recipe viewing/cooking
  analysis,     // Calorie analysis
  streak,       // Daily streak
  social,       // Social features
  special,      // Special events
}

/// Badge rarity levels.
enum BadgeRarity {
  common,       // Bronze - 50 XP
  rare,         // Silver - 100 XP
  epic,         // Gold - 200 XP
  legendary,    // Platinum - 500 XP
}

/// XP action types and their values.
enum XPAction {
  viewRecipe(5),
  addFavorite(10),
  analyzeCalories(15),
  shareRecipe(10),
  completeProfile(50),
  dailyLogin(20),
  weeklyStreak(100),
  unlockBadge(0),  // XP comes from badge itself
  cookRecipe(25);

  final int xpValue;
  const XPAction(this.xpValue);
}

/// Predefined badges.
class Badges {
  static const List<Badge> all = [
    // Premium badge - special for premium users
    Badge(
      id: 'premium_member',
      name: 'Premium Üye',
      description: 'Premium üyelik satın alındı',
      iconAsset: '💎',
      requiredValue: 1,
      category: BadgeCategory.special,
      rarity: BadgeRarity.legendary,
      xpReward: 100,
    ),
    Badge(
      id: 'lifetime_member',
      name: 'Lifetime Üye',
      description: 'Ömür boyu Premium satın alındı',
      iconAsset: '👑',
      requiredValue: 1,
      category: BadgeCategory.special,
      rarity: BadgeRarity.legendary,
      xpReward: 250,
    ),

    // Recipe badges
    Badge(
      id: 'first_recipe',
      name: 'İlk Tarif',
      description: 'İlk tarifini görüntüle',
      iconAsset: '🍳',
      requiredValue: 1,
      category: BadgeCategory.recipes,
      rarity: BadgeRarity.common,
      xpReward: 25,
    ),
    Badge(
      id: 'recipe_explorer',
      name: 'Tarif Kaşifi',
      description: '10 tarif görüntüle',
      iconAsset: '🔍',
      requiredValue: 10,
      category: BadgeCategory.recipes,
      rarity: BadgeRarity.common,
      xpReward: 50,
    ),
    Badge(
      id: 'recipe_master',
      name: 'Tarif Ustası',
      description: '50 tarif görüntüle',
      iconAsset: '👨‍🍳',
      requiredValue: 50,
      category: BadgeCategory.recipes,
      rarity: BadgeRarity.rare,
      xpReward: 100,
    ),
    Badge(
      id: 'recipe_legend',
      name: 'Tarif Efsanesi',
      description: '100 tarif görüntüle',
      iconAsset: '🏆',
      requiredValue: 100,
      category: BadgeCategory.recipes,
      rarity: BadgeRarity.epic,
      xpReward: 200,
    ),

    // Analysis badges
    Badge(
      id: 'first_analysis',
      name: 'İlk Analiz',
      description: 'İlk kalori analizini yap',
      iconAsset: '📊',
      requiredValue: 1,
      category: BadgeCategory.analysis,
      rarity: BadgeRarity.common,
      xpReward: 25,
    ),
    Badge(
      id: 'calorie_counter',
      name: 'Kalori Sayıcı',
      description: '10 kalori analizi yap',
      iconAsset: '🔢',
      requiredValue: 10,
      category: BadgeCategory.analysis,
      rarity: BadgeRarity.common,
      xpReward: 50,
    ),
    Badge(
      id: 'nutrition_expert',
      name: 'Beslenme Uzmanı',
      description: '50 kalori analizi yap',
      iconAsset: '🥗',
      requiredValue: 50,
      category: BadgeCategory.analysis,
      rarity: BadgeRarity.rare,
      xpReward: 100,
    ),

    // Streak badges
    Badge(
      id: 'first_streak',
      name: 'İlk Seri',
      description: '3 gün üst üste giriş yap',
      iconAsset: '🔥',
      requiredValue: 3,
      category: BadgeCategory.streak,
      rarity: BadgeRarity.common,
      xpReward: 50,
    ),
    Badge(
      id: 'week_warrior',
      name: 'Haftalık Savaşçı',
      description: '7 gün üst üste giriş yap',
      iconAsset: '⚡',
      requiredValue: 7,
      category: BadgeCategory.streak,
      rarity: BadgeRarity.rare,
      xpReward: 100,
    ),
    Badge(
      id: 'month_master',
      name: 'Aylık Usta',
      description: '30 gün üst üste giriş yap',
      iconAsset: '💪',
      requiredValue: 30,
      category: BadgeCategory.streak,
      rarity: BadgeRarity.epic,
      xpReward: 300,
    ),
    Badge(
      id: 'centurion',
      name: 'Centurion',
      description: '100 gün üst üste giriş yap',
      iconAsset: '🎖️',
      requiredValue: 100,
      category: BadgeCategory.streak,
      rarity: BadgeRarity.legendary,
      xpReward: 500,
    ),
  ];

  static Badge? getById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
