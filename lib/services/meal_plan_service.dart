import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/meal_plan.dart';
import 'analytics_service.dart';

/// Service for managing meal plans.
class MealPlanService {
  static final MealPlanService _instance = MealPlanService._internal();
  factory MealPlanService() => _instance;
  MealPlanService._internal();

  static const String _mealPlanKey = 'meal_plans';
  final AnalyticsService _analytics = AnalyticsService();

  /// Get current week's meal plan.
  Future<MealPlan> getCurrentWeekPlan() async {
    final weekStart = _getWeekStart(DateTime.now());
    final plans = await _getAllPlans();
    
    try {
      return plans.firstWhere(
        (p) => _isSameWeek(p.weekStart, weekStart),
      );
    } catch (_) {
      // Create new plan for this week
      final newPlan = MealPlan.empty(weekStart);
      await savePlan(newPlan);
      return newPlan;
    }
  }

  /// Get meal plan for a specific week.
  Future<MealPlan?> getPlanForWeek(DateTime weekStart) async {
    final normalizedStart = _getWeekStart(weekStart);
    final plans = await _getAllPlans();
    
    try {
      return plans.firstWhere(
        (p) => _isSameWeek(p.weekStart, normalizedStart),
      );
    } catch (_) {
      return null;
    }
  }

  /// Save a meal plan.
  Future<void> savePlan(MealPlan plan) async {
    final plans = await _getAllPlans();
    
    final index = plans.indexWhere((p) => p.id == plan.id);
    if (index >= 0) {
      plans[index] = plan.copyWith(updatedAt: DateTime.now());
    } else {
      plans.add(plan);
    }

    await _savePlans(plans);
  }

  /// Add a meal to a specific day.
  Future<MealPlan?> addMeal({
    required String day,
    required MealType type,
    required String recipeId,
    required String recipeName,
    String? imageUrl,
    int? calories,
  }) async {
    final plan = await getCurrentWeekPlan();
    final dayMeals = plan.dailyMeals[day] ?? const DayMeals();

    final meal = PlannedMeal(
      recipeId: recipeId,
      recipeName: recipeName,
      imageUrl: imageUrl,
      calories: calories,
      type: type,
    );

    DayMeals updatedDayMeals;
    switch (type) {
      case MealType.breakfast:
        updatedDayMeals = dayMeals.copyWith(breakfast: meal);
        break;
      case MealType.lunch:
        updatedDayMeals = dayMeals.copyWith(lunch: meal);
        break;
      case MealType.dinner:
        updatedDayMeals = dayMeals.copyWith(dinner: meal);
        break;
      case MealType.snack:
        updatedDayMeals = dayMeals.copyWith(snacks: [...dayMeals.snacks, meal]);
        break;
    }

    final updatedPlan = plan.copyWith(
      dailyMeals: {...plan.dailyMeals, day: updatedDayMeals},
      updatedAt: DateTime.now(),
    );

    await savePlan(updatedPlan);
    await _analytics.logMealPlanned(type.name);

    return updatedPlan;
  }

  /// Remove a meal from a specific day.
  Future<MealPlan?> removeMeal({
    required String day,
    required MealType type,
    int? snackIndex,
  }) async {
    final plan = await getCurrentWeekPlan();
    final dayMeals = plan.dailyMeals[day];
    
    if (dayMeals == null) return null;

    DayMeals updatedDayMeals;
    switch (type) {
      case MealType.breakfast:
        updatedDayMeals = DayMeals(
          lunch: dayMeals.lunch,
          dinner: dayMeals.dinner,
          snacks: dayMeals.snacks,
        );
        break;
      case MealType.lunch:
        updatedDayMeals = DayMeals(
          breakfast: dayMeals.breakfast,
          dinner: dayMeals.dinner,
          snacks: dayMeals.snacks,
        );
        break;
      case MealType.dinner:
        updatedDayMeals = DayMeals(
          breakfast: dayMeals.breakfast,
          lunch: dayMeals.lunch,
          snacks: dayMeals.snacks,
        );
        break;
      case MealType.snack:
        final snacks = List<PlannedMeal>.from(dayMeals.snacks);
        if (snackIndex != null && snackIndex < snacks.length) {
          snacks.removeAt(snackIndex);
        }
        updatedDayMeals = DayMeals(
          breakfast: dayMeals.breakfast,
          lunch: dayMeals.lunch,
          dinner: dayMeals.dinner,
          snacks: snacks,
        );
        break;
    }

    final updatedPlan = plan.copyWith(
      dailyMeals: {...plan.dailyMeals, day: updatedDayMeals},
      updatedAt: DateTime.now(),
    );

    await savePlan(updatedPlan);
    return updatedPlan;
  }

  /// Mark a meal as cooked.
  Future<void> markAsCooked(String day, MealType type) async {
    final plan = await getCurrentWeekPlan();
    final dayMeals = plan.dailyMeals[day];
    
    if (dayMeals == null) return;

    DayMeals updatedDayMeals;
    switch (type) {
      case MealType.breakfast:
        if (dayMeals.breakfast != null) {
          updatedDayMeals = dayMeals.copyWith(
            breakfast: dayMeals.breakfast!.copyWith(isCooked: true),
          );
        } else {
          return;
        }
        break;
      case MealType.lunch:
        if (dayMeals.lunch != null) {
          updatedDayMeals = dayMeals.copyWith(
            lunch: dayMeals.lunch!.copyWith(isCooked: true),
          );
        } else {
          return;
        }
        break;
      case MealType.dinner:
        if (dayMeals.dinner != null) {
          updatedDayMeals = dayMeals.copyWith(
            dinner: dayMeals.dinner!.copyWith(isCooked: true),
          );
        } else {
          return;
        }
        break;
      default:
        return;
    }

    final updatedPlan = plan.copyWith(
      dailyMeals: {...plan.dailyMeals, day: updatedDayMeals},
    );

    await savePlan(updatedPlan);
  }

  /// Get total calories for a day.
  int getDayCalories(DayMeals? dayMeals) {
    if (dayMeals == null) return 0;
    int total = 0;
    if (dayMeals.breakfast?.calories != null) total += dayMeals.breakfast!.calories!;
    if (dayMeals.lunch?.calories != null) total += dayMeals.lunch!.calories!;
    if (dayMeals.dinner?.calories != null) total += dayMeals.dinner!.calories!;
    for (final snack in dayMeals.snacks) {
      if (snack.calories != null) total += snack.calories!;
    }
    return total;
  }

  // Private helpers
  Future<List<MealPlan>> _getAllPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_mealPlanKey);
    
    if (json == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((p) => MealPlan.fromJson(p)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _savePlans(List<MealPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(plans.map((p) => p.toJson()).toList());
    await prefs.setString(_mealPlanKey, json);
  }

  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday; // 1 = Monday
    return DateTime(date.year, date.month, date.day - dayOfWeek + 1);
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    final aStart = _getWeekStart(a);
    final bStart = _getWeekStart(b);
    return aStart.year == bStart.year && 
           aStart.month == bStart.month && 
           aStart.day == bStart.day;
  }
}
