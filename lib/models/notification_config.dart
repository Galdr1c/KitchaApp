enum NotificationType {
  mealSuggestion,
  goalTracking,
  recipeRecommendation,
  achievement
}

class UserNotificationPreferences {
  bool mealSuggestionsEnabled;
  bool goalTrackingEnabled;
  bool recipeRecommendationsEnabled;
  bool achievementsEnabled;
  String quietHoursStart; // "HH:mm"
  String quietHoursEnd;   // "HH:mm"
  bool smartSchedulingEnabled;

  UserNotificationPreferences({
    this.mealSuggestionsEnabled = true,
    this.goalTrackingEnabled = true,
    this.recipeRecommendationsEnabled = true,
    this.achievementsEnabled = true,
    this.quietHoursStart = "22:00",
    this.quietHoursEnd = "08:00",
    this.smartSchedulingEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'mealSuggestionsEnabled': mealSuggestionsEnabled,
    'goalTrackingEnabled': goalTrackingEnabled,
    'recipeRecommendationsEnabled': recipeRecommendationsEnabled,
    'achievementsEnabled': achievementsEnabled,
    'quietHoursStart': quietHoursStart,
    'quietHoursEnd': quietHoursEnd,
    'smartSchedulingEnabled': smartSchedulingEnabled,
  };

  factory UserNotificationPreferences.fromJson(Map<String, dynamic> json) => UserNotificationPreferences(
    mealSuggestionsEnabled: json['mealSuggestionsEnabled'] ?? true,
    goalTrackingEnabled: json['goalTrackingEnabled'] ?? true,
    recipeRecommendationsEnabled: json['recipeRecommendationsEnabled'] ?? true,
    achievementsEnabled: json['achievementsEnabled'] ?? true,
    quietHoursStart: json['quietHoursStart'] ?? "22:00",
    quietHoursEnd: json['quietHoursEnd'] ?? "08:00",
    smartSchedulingEnabled: json['smartSchedulingEnabled'] ?? true,
  );
}
