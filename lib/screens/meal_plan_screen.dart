import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import '../services/meal_plan_service.dart';

/// Screen for weekly meal planning.
class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final MealPlanService _service = MealPlanService();
  MealPlan? _plan;
  bool _isLoading = true;
  String _selectedDay = DaysOfWeek.all[DateTime.now().weekday - 1];

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    setState(() => _isLoading = true);
    _plan = await _service.getCurrentWeekPlan();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haftalık Menü'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDaySelector(isDark),
                Expanded(child: _buildDayMeals(isDark)),
              ],
            ),
    );
  }

  Widget _buildDaySelector(bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: DaysOfWeek.all.length,
        itemBuilder: (context, index) {
          final day = DaysOfWeek.all[index];
          final isSelected = _selectedDay == day;
          final dayMeals = _plan?.dailyMeals[day];
          final mealCount = _getMealCount(dayMeals);

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6347)
                    : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DaysOfWeek.getTitle(day).substring(0, 3),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$mealCount/3',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayMeals(bool isDark) {
    final dayMeals = _plan?.dailyMeals[_selectedDay] ?? const DayMeals();
    final totalCalories = _service.getDayCalories(dayMeals);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(DaysOfWeek.getEmoji(_selectedDay), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(DaysOfWeek.getTitle(_selectedDay),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (totalCalories > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6347).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$totalCalories kcal',
                    style: const TextStyle(color: Color(0xFFFF6347), fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMealSlot(title: '🌅 Kahvaltı', meal: dayMeals.breakfast, type: MealType.breakfast, isDark: isDark),
        const SizedBox(height: 16),
        _buildMealSlot(title: '☀️ Öğle', meal: dayMeals.lunch, type: MealType.lunch, isDark: isDark),
        const SizedBox(height: 16),
        _buildMealSlot(title: '🌙 Akşam', meal: dayMeals.dinner, type: MealType.dinner, isDark: isDark),
      ],
    );
  }

  Widget _buildMealSlot({required String title, PlannedMeal? meal, required MealType type, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: meal != null
          ? Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(child: meal.isCooked ? const Icon(Icons.check, color: Colors.green) : Text(title.split(' ')[0], style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(meal.recipeName, style: const TextStyle(fontWeight: FontWeight.bold))),
              IconButton(onPressed: () => _removeMeal(type), icon: const Icon(Icons.close), color: Colors.red),
            ])
          : InkWell(
              onTap: () => _addMeal(type),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFFF6347).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add, color: Color(0xFFFF6347)),
                ),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ),
    );
  }

  int _getMealCount(DayMeals? meals) {
    if (meals == null) return 0;
    return [meals.breakfast, meals.lunch, meals.dinner].where((m) => m != null).length;
  }

  void _addMeal(MealType type) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarif seçimi yakında!')));
  }

  Future<void> _removeMeal(MealType type) async {
    await _service.removeMeal(day: _selectedDay, type: type);
    _loadPlan();
  }
}
