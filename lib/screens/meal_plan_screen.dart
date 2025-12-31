import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/meal_planner_service.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final _service = MealPlannerService();
  bool _isLoading = false;

  Future<void> _createPlan() async {
    setState(() => _isLoading = true);
    try {
      // Hardcoded defaults for Phase 3 concise implementation
      await _service.generateAndSaveMealPlan(targetCalories: 2000);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Haftalık Yemek Planı')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _service.getMyMealPlan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('AI Plan Oluştur (2000 kcal)'),
                    onPressed: _createPlan,
                  ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final week = data['week'] as Map<String, dynamic>;
          final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

          return ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final dayData = week[day];
              if (dayData == null) return const SizedBox.shrink();
              
              final meals = (dayData['meals'] as List).cast<Map<String, dynamic>>();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(day.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${dayData['nutrients']['calories'].round()} kcal'),
                  children: meals.map((meal) {
                    return ListTile(
                      title: Text(meal['title']),
                      subtitle: Text('Hazırlama: ${meal['readyInMinutes']} dk'),
                      leading: SizedBox(
                        width: 50,
                        child: CachedNetworkImage(
                          imageUrl: 'https://spoonacular.com/recipeImages/${meal['id']}-90x90.jpg', 
                          placeholder: (_,__) => const Icon(Icons.fastfood),
                          errorWidget: (_,__,___)=> const Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
