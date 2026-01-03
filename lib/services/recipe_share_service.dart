import 'deep_link_service.dart';
import 'analytics_service.dart';

/// Service for sharing recipes with rich formatting.
class RecipeShareService {
  static final RecipeShareService _instance = RecipeShareService._internal();
  factory RecipeShareService() => _instance;
  RecipeShareService._internal();

  final AnalyticsService _analytics = AnalyticsService();

  /// Generate share message for a recipe.
  String generateShareMessage({
    required String recipeId,
    required String title,
    String? prepTime,
    String? calories,
    String? description,
  }) {
    final deepLink = DeepLinkService.createRecipeLink(recipeId);

    final buffer = StringBuffer();
    buffer.writeln('🍅 Kitcha\'dan bir tarif: $title');
    buffer.writeln();

    if (prepTime != null || calories != null) {
      final parts = <String>[];
      if (prepTime != null) parts.add('⏱️ $prepTime dakika');
      if (calories != null) parts.add('🔥 $calories kcal');
      buffer.writeln(parts.join(' | '));
      buffer.writeln();
    }

    if (description != null && description.isNotEmpty) {
      final shortDesc = description.length > 100
          ? '${description.substring(0, 100)}...'
          : description;
      buffer.writeln(shortDesc);
      buffer.writeln();
    }

    buffer.writeln('Tarifi görmek için tıkla:');
    buffer.writeln(deepLink);
    buffer.writeln();
    buffer.writeln('Kitcha - Your Smart Kitchen Companion 🍳');

    return buffer.toString();
  }

  /// Share a recipe (call platform share).
  Future<void> shareRecipe({
    required String recipeId,
    required String title,
    String? prepTime,
    String? calories,
    String? description,
  }) async {
    final message = generateShareMessage(
      recipeId: recipeId,
      title: title,
      prepTime: prepTime,
      calories: calories,
      description: description,
    );

    // In production, use share_plus package:
    // await Share.share(message);

    await _analytics.logRecipeShared(recipeId);
    print('[RecipeShareService] Sharing: $message');
  }

  /// Generate Instagram-friendly story content.
  Map<String, String> generateInstagramContent({
    required String title,
    required String imageUrl,
    String? prepTime,
    String? calories,
  }) {
    return {
      'title': '🍅 $title',
      'subtitle': [
        if (prepTime != null) '⏱️ $prepTime dk',
        if (calories != null) '🔥 $calories kcal',
      ].join(' • '),
      'imageUrl': imageUrl,
      'appName': 'Kitcha',
    };
  }

  /// Generate WhatsApp-optimized message.
  String generateWhatsAppMessage({
    required String recipeId,
    required String title,
    List<String>? ingredients,
  }) {
    final deepLink = DeepLinkService.createRecipeLink(recipeId);

    final buffer = StringBuffer();
    buffer.writeln('🍽️ *$title*');
    buffer.writeln();

    if (ingredients != null && ingredients.isNotEmpty) {
      buffer.writeln('📝 Malzemeler:');
      for (final ingredient in ingredients.take(5)) {
        buffer.writeln('• $ingredient');
      }
      if (ingredients.length > 5) {
        buffer.writeln('... ve ${ingredients.length - 5} malzeme daha');
      }
      buffer.writeln();
    }

    buffer.writeln('👇 Tarifi görmek için:');
    buffer.writeln(deepLink);

    return buffer.toString();
  }

  /// Share meal plan for the week.
  String generateMealPlanShare(Map<String, List<String>> weekPlan) {
    final buffer = StringBuffer();
    buffer.writeln('🗓️ Bu Haftanın Menüsü');
    buffer.writeln('━━━━━━━━━━━━━━━━');
    buffer.writeln();

    final days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final emojis = ['📅', '📅', '📅', '📅', '🎉', '☀️', '🌙'];

    for (var i = 0; i < days.length; i++) {
      final dayKey = days[i].toLowerCase();
      final meals = weekPlan[dayKey];

      if (meals != null && meals.isNotEmpty) {
        buffer.writeln('${emojis[i]} *${days[i]}*');
        for (final meal in meals) {
          buffer.writeln('  • $meal');
        }
        buffer.writeln();
      }
    }

    buffer.writeln('━━━━━━━━━━━━━━━━');
    buffer.writeln('Kitcha ile planlandı 🍅');

    return buffer.toString();
  }

  /// Share shopping list.
  String generateShoppingListShare(List<Map<String, String>> items) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 Alışveriş Listem');
    buffer.writeln();

    // Group by category
    final grouped = <String, List<String>>{};
    for (final item in items) {
      final category = item['category'] ?? 'Diğer';
      final name = item['name'] ?? '';
      final quantity = item['quantity'] ?? '';

      grouped.putIfAbsent(category, () => []).add('$quantity $name'.trim());
    }

    for (final entry in grouped.entries) {
      buffer.writeln('${_getCategoryEmoji(entry.key)} *${entry.key}*');
      for (final item in entry.value) {
        buffer.writeln('☐ $item');
      }
      buffer.writeln();
    }

    buffer.writeln('Kitcha ile oluşturuldu 🍅');

    return buffer.toString();
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'sebze':
      case 'meyve':
        return '🥬';
      case 'süt ürünleri':
        return '🥛';
      case 'et':
        return '🥩';
      case 'deniz ürünleri':
        return '🐟';
      case 'tahıl':
        return '🌾';
      case 'donmuş':
        return '❄️';
      default:
        return '📦';
    }
  }
}
