import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../utils/calorie_calculator.dart';
import '../services/share_service.dart';
import '../widgets/share_consent_dialog.dart';
import '../widgets/recipe_comments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../repository/app_repository.dart';
import '../utils/feedback_handler.dart';
import '../theme/app_theme.dart';
import '../services/memory_mcp_service.dart';

/// Screen displaying detailed recipe information
/// 
/// Can receive recipe via:
/// - Provider (selectedRecipe)
/// - Constructor parameter
/// - Route arguments
class RecipeDetailScreen extends StatefulWidget {
  final Recipe? recipe;

  const RecipeDetailScreen({
    super.key,
    this.recipe,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _contextLogged = false;

  @override
  void initState() {
    super.initState();
    _logRecipeView();
  }

  void _logRecipeView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_contextLogged) {
        final provider = context.read<RecipeProvider>();
        final displayRecipe = widget.recipe ?? 
            (ModalRoute.of(context)?.settings.arguments as Recipe?) ??
            provider.selectedRecipe;
        
        if (displayRecipe != null) {
          final recipeModel = RecipeModel(
            id: displayRecipe.id,
            name: displayRecipe.title,
            ingredients: displayRecipe.ingredients,
            steps: displayRecipe.instructions,
            imageUrl: displayRecipe.imageUrl,
            calories: displayRecipe.calories,
            prepTime: displayRecipe.prepTimeMinutes,
            cookTime: displayRecipe.cookTimeMinutes,
            servings: displayRecipe.servings,
            category: displayRecipe.category,
            isFavorite: provider.isFavorite(displayRecipe),
          );
          MemoryMcpService().updateMemoryFromRecipeView(recipeModel);
          _contextLogged = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, provider, child) {
        // Get recipe from constructor, arguments, or provider
        final displayRecipe = widget.recipe ?? 
            (ModalRoute.of(context)?.settings.arguments as Recipe?) ??
            provider.selectedRecipe;

        if (displayRecipe == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tarif'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('Tarif bulunamadı'),
            ),
          );
        }

        final isFavorite = provider.isFavorite(displayRecipe);
        
        // Calculate calories from ingredients if not available or to verify
        final calculatedNutrition = CalorieCalculator.calculateFromIngredients(
          displayRecipe.ingredients,
        );
        final calculatedCalories = calculatedNutrition['calories']!.round();
        final displayCalories = displayRecipe.calories > 0 
            ? displayRecipe.calories 
            : calculatedCalories;
        final isCalculated = displayRecipe.calories == 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              displayRecipe.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            actions: [
              // Share button
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Paylaş',
                onPressed: () => _shareRecipe(context, displayRecipe, displayCalories),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe image (200 height)
                Hero(
                  tag: 'recipe_${displayRecipe.id}',
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: displayRecipe.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: displayRecipe.imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(color: Colors.grey[200], child: const Icon(Icons.restaurant, size: 60)),
                      ),
                      const Positioned(
                        top: 16,
                        right: 16,
                        child: _SpecialBadge(),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.people, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${(displayRecipe.id % 50) + 124} kişi bunu sevdi',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Calorie estimate with calculation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              _InfoItem(
                                icon: Icons.local_fire_department,
                                value: '$displayCalories',
                                label: 'Kalori',
                                color: Colors.orange,
                              ),
                              if (isCalculated)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.calculate, size: 10, color: Colors.blue[700]),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Hesaplanan',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          _InfoItem(
                            icon: Icons.timer,
                            value: '${displayRecipe.totalTimeMinutes}',
                            label: 'Dakika',
                            color: Colors.blue,
                          ),
                          _InfoItem(
                            icon: Icons.people,
                            value: '${displayRecipe.servings}',
                            label: 'Porsiyon',
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      if (displayRecipe.calories > 0 && calculatedCalories > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'API: ${displayRecipe.calories} kcal | Hesaplanan: $calculatedCalories kcal',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Malzemeler (Ingredients) section
                _SectionHeader(
                  title: 'Malzemeler',
                  icon: Icons.shopping_basket,
                  count: displayRecipe.ingredients.length,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayRecipe.ingredients.length,
                  itemBuilder: (context, index) {
                    return _IngredientItem(
                      index: index + 1,
                      ingredient: displayRecipe.ingredients[index],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Adımlar (Steps/Instructions) section
                _SectionHeader(
                  title: 'Adımlar',
                  icon: Icons.format_list_numbered,
                  count: displayRecipe.instructions.length,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayRecipe.instructions.length,
                  itemBuilder: (context, index) {
                    return _StepItem(
                      stepNumber: index + 1,
                      instruction: displayRecipe.instructions[index],
                    );
                  },
                ),

                // Nutrition details
                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'Besin Değerleri',
                  icon: Icons.pie_chart,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _NutritionCard(
                    recipe: displayRecipe,
                    calculatedNutrition: calculatedNutrition,
                  ),
                ),
                
                // Comments
                RecipeComments(recipeId: displayRecipe.id.toString()),

                // Bottom padding for FAB
                const SizedBox(height: 80),
              ],
            ),
          ),
          // FAB for favorite with enhanced toggle
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final wasFavorite = isFavorite;
              
              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(wasFavorite ? 'Kaldırılıyor...' : 'Ekleniyor...'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1),
                ),
              );
              
              // Toggle favorite
              await provider.toggleFavorite(displayRecipe);
              
              // Feed memory for favorite action
              if (!wasFavorite) {
                final recipeModel = RecipeModel(
                  name: displayRecipe.title,
                  ingredients: displayRecipe.ingredients,
                  steps: displayRecipe.instructions,
                  imageUrl: displayRecipe.imageUrl,
                  calories: displayRecipe.calories,
                  category: displayRecipe.category,
                  isFavorite: true,
                );
                MemoryMcpService().updateMemoryFromRecipeView(recipeModel);
                FeedbackHandler.lightImpact();
              }
              
              // Refresh favorites list
              await provider.loadFavorites();
              
              // Show success message with undo
              if (context.mounted) {
                final newFavoriteState = provider.isFavorite(displayRecipe);
                if (newFavoriteState) {
                  FeedbackHandler.success();
                  FeedbackHandler.showSuccessDialog(context, message: 'Favorilere Eklendi!');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          newFavoriteState ? Icons.star : Icons.star_border,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            newFavoriteState 
                                ? '"${displayRecipe.title}" favorilere eklendi' 
                                : '"${displayRecipe.title}" favorilerden kaldırıldı',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'Geri Al',
                      textColor: Colors.white,
                      onPressed: () async {
                        // Undo toggle
                        await provider.toggleFavorite(displayRecipe);
                        await provider.loadFavorites();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.undo, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    wasFavorite 
                                        ? 'Favorilere geri eklendi' 
                                        : 'Favorilerden kaldırıldı',
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.blue,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              }
            },
            backgroundColor: Colors.green,
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : Colors.white,
            ),
            label: Text(
              isFavorite ? 'Favorilerden Kaldır' : 'Favorilere Ekle',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Share recipe with privacy consent
  static Future<void> _shareRecipe(
    BuildContext context,
    Recipe recipe,
    int calories,
  ) async {
    // Show privacy consent dialog
    final confirmed = await ShareConsentDialog.show(
      context,
      title: 'Tarifi Paylaş',
      message: 'Bu tarifi paylaşmak istediğinizden emin misiniz?',
    );
    
    final shareService = ShareService();

    if (!confirmed) {
      return;
    }

    try {
      await shareService.shareRecipe(
        name: recipe.title,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        calories: calories,
        prepTime: recipe.prepTimeMinutes,
        cookTime: recipe.cookTimeMinutes,
        imageUrl: recipe.imageUrl.isNotEmpty ? recipe.imageUrl : null,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Tarif paylaşıldı'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Paylaşım hatası: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SpecialBadge extends StatelessWidget {
  const _SpecialBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentAI,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'SANA ÖZEL',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? count;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ingredient list item
class _IngredientItem extends StatelessWidget {
  final int index;
  final String ingredient;

  const _IngredientItem({
    required this.index,
    required this.ingredient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Instruction step item
class _StepItem extends StatelessWidget {
  final int stepNumber;
  final String instruction;

  const _StepItem({
    required this.stepNumber,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                instruction,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info item for calorie/time/servings
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Nutrition info card
class _NutritionCard extends StatelessWidget {
  final Recipe recipe;
  final Map<String, double>? calculatedNutrition;

  const _NutritionCard({
    required this.recipe,
    this.calculatedNutrition,
  });

  double get protein {
    if (recipe.protein > 0) return recipe.protein;
    return calculatedNutrition?['protein']?.roundToDouble() ?? 0.0;
  }

  double get carbs {
    if (recipe.carbs > 0) return recipe.carbs;
    return calculatedNutrition?['carbs']?.roundToDouble() ?? 0.0;
  }

  double get fat {
    if (recipe.fat > 0) return recipe.fat;
    return calculatedNutrition?['fat']?.roundToDouble() ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutritionItem(
                  label: 'Protein',
                  value: '${protein.toStringAsFixed(0)}g',
                  color: Colors.blue,
                ),
                _NutritionItem(
                  label: 'Karbonhidrat',
                  value: '${carbs.toStringAsFixed(0)}g',
                  color: Colors.amber,
                ),
                _NutritionItem(
                  label: 'Yağ',
                  value: '${fat.toStringAsFixed(0)}g',
                  color: Colors.purple,
                ),
              ],
            ),
            if (calculatedNutrition != null && (recipe.protein == 0 || recipe.carbs == 0 || recipe.fat == 0))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '* Malzemelerden hesaplanan değerler',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutritionItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
