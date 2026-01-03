/// Year in Review data model (Spotify Wrapped style).
class YearInReviewData {
  final int year;
  final int totalRecipesViewed;
  final int totalFavorites;
  final int totalAnalyses;
  final int totalCalories;
  final String mostViewedCategory;
  final String favoriteRecipe;
  final String topIngredient;
  final int consecutiveDays;
  final int badgesEarned;
  final int xpGained;
  final Map<int, int> monthlyBreakdown;

  const YearInReviewData({
    required this.year,
    required this.totalRecipesViewed,
    required this.totalFavorites,
    required this.totalAnalyses,
    required this.totalCalories,
    required this.mostViewedCategory,
    required this.favoriteRecipe,
    required this.topIngredient,
    required this.consecutiveDays,
    required this.badgesEarned,
    required this.xpGained,
    required this.monthlyBreakdown,
  });

  /// Convert calories to fun equivalents.
  String get calorieEquivalent {
    final pizzas = (totalCalories / 285).round();
    if (pizzas > 0) return '$pizzas pizza 🍕';
    return '$totalCalories kcal';
  }

  /// Determine cooking personality.
  String get personalityType {
    switch (mostViewedCategory.toLowerCase()) {
      case 'tatlı':
      case 'dessert':
        return 'Sweet Tooth 🍰';
      case 'kahvaltı':
      case 'breakfast':
        return 'Early Bird 🌅';
      case 'ana yemek':
      case 'main course':
        return 'Home Chef 👨‍🍳';
      case 'çorba':
      case 'soup':
        return 'Comfort Seeker 🍲';
      case 'salata':
      case 'salad':
        return 'Health Enthusiast 🥗';
      default:
        return 'Foodie Explorer 🌍';
    }
  }

  /// Get most active month.
  String get mostActiveMonth {
    if (monthlyBreakdown.isEmpty) return 'Ocak';
    
    int maxMonth = 1;
    int maxCount = 0;
    
    monthlyBreakdown.forEach((month, count) {
      if (count > maxCount) {
        maxCount = count;
        maxMonth = month;
      }
    });
    
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    return months[maxMonth];
  }

  /// Calculate percentile among users.
  int get percentile {
    // Would be calculated server-side based on other users
    if (totalRecipesViewed > 500) return 1;
    if (totalRecipesViewed > 200) return 5;
    if (totalRecipesViewed > 100) return 10;
    if (totalRecipesViewed > 50) return 25;
    return 50;
  }

  /// Create mock data for demo.
  factory YearInReviewData.mock(int year) {
    return YearInReviewData(
      year: year,
      totalRecipesViewed: 247,
      totalFavorites: 58,
      totalAnalyses: 42,
      totalCalories: 145000,
      mostViewedCategory: 'Ana Yemek',
      favoriteRecipe: 'İskender Kebap',
      topIngredient: 'Domates',
      consecutiveDays: 14,
      badgesEarned: 12,
      xpGained: 4850,
      monthlyBreakdown: {
        1: 15, 2: 18, 3: 22, 4: 25, 5: 20, 6: 18,
        7: 15, 8: 20, 9: 28, 10: 25, 11: 22, 12: 19,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'totalRecipesViewed': totalRecipesViewed,
      'totalFavorites': totalFavorites,
      'totalAnalyses': totalAnalyses,
      'totalCalories': totalCalories,
      'mostViewedCategory': mostViewedCategory,
      'favoriteRecipe': favoriteRecipe,
      'topIngredient': topIngredient,
      'consecutiveDays': consecutiveDays,
      'badgesEarned': badgesEarned,
      'xpGained': xpGained,
      'monthlyBreakdown': monthlyBreakdown,
    };
  }

  factory YearInReviewData.fromJson(Map<String, dynamic> json) {
    return YearInReviewData(
      year: json['year'] ?? DateTime.now().year,
      totalRecipesViewed: json['totalRecipesViewed'] ?? 0,
      totalFavorites: json['totalFavorites'] ?? 0,
      totalAnalyses: json['totalAnalyses'] ?? 0,
      totalCalories: json['totalCalories'] ?? 0,
      mostViewedCategory: json['mostViewedCategory'] ?? '',
      favoriteRecipe: json['favoriteRecipe'] ?? '',
      topIngredient: json['topIngredient'] ?? '',
      consecutiveDays: json['consecutiveDays'] ?? 0,
      badgesEarned: json['badgesEarned'] ?? 0,
      xpGained: json['xpGained'] ?? 0,
      monthlyBreakdown: Map<int, int>.from(json['monthlyBreakdown'] ?? {}),
    );
  }
}
