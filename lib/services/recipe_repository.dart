import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kitcha_recipe.dart';
import 'firebase_service.dart';
import 'translation_cache_service.dart';
import 'logger_service.dart';

/// Repository for the custom Kitcha recipe database.
class RecipeRepository {
  static final RecipeRepository _instance = RecipeRepository._internal();
  factory RecipeRepository() => _instance;
  RecipeRepository._internal();

  final TranslationCacheService _translationCache = TranslationCacheService();
  
  /// Collection name in Firestore.
  static const String _collection = 'kitcha_recipes';

  /// Get all recipes.
  Future<List<KitchaRecipe>> getAllRecipes({int limit = 50}) async {
    if (!FirebaseService.isAvailable) {
      return _getSampleRecipes();
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => KitchaRecipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get recipes', e);
      return _getSampleRecipes();
    }
  }

  /// Get recipe by ID.
  Future<KitchaRecipe?> getRecipeById(String id) async {
    if (!FirebaseService.isAvailable) {
      return _getSampleRecipes().firstWhere(
        (r) => r.id == id,
        orElse: () => _getSampleRecipes().first,
      );
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .get();

      if (!doc.exists) return null;

      return KitchaRecipe.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      LoggerService.error('Failed to get recipe: $id', e);
      return null;
    }
  }

  /// Get recipes by category.
  Future<List<KitchaRecipe>> getByCategory(String category, {int limit = 20}) async {
    if (!FirebaseService.isAvailable) {
      return _getSampleRecipes().where((r) => r.category == category).toList();
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('category', isEqualTo: category)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => KitchaRecipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get recipes by category', e);
      return [];
    }
  }

  /// Search recipes.
  Future<List<KitchaRecipe>> searchRecipes(String query, {String lang = 'tr'}) async {
    final normalizedQuery = query.toLowerCase().trim();

    if (!FirebaseService.isAvailable) {
      return _getSampleRecipes().where((r) {
        final title = r.getTitle(lang).toLowerCase();
        final tags = r.tags.join(' ').toLowerCase();
        return title.contains(normalizedQuery) || tags.contains(normalizedQuery);
      }).toList();
    }

    try {
      // Search in both TR and EN titles
      final field = lang == 'en' ? 'titleEN' : 'titleTR';
      
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy(field)
          .startAt([normalizedQuery])
          .endAt(['$normalizedQuery\uf8ff'])
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => KitchaRecipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      LoggerService.error('Search failed', e);
      return [];
    }
  }

  /// Get translated recipe.
  Future<KitchaRecipe> getTranslatedRecipe(KitchaRecipe recipe, String targetLang) async {
    // If already has translation, use it
    if (targetLang == 'en' && recipe.titleEN != null) {
      return recipe;
    }
    if (targetLang == 'tr') {
      return recipe; // Turkish is always available
    }

    // Check cache
    final cached = await _translationCache.getRecipeTranslation(recipe.id, targetLang);
    if (cached != null) {
      return recipe.copyWith(
        titleEN: cached.title,
        descriptionEN: cached.description,
        instructionsEN: cached.instructions,
      );
    }

    // No translation available - would need API call
    // Return original recipe for now
    LoggerService.debug('No cached translation for: ${recipe.id}');
    return recipe;
  }

  /// Save a new recipe.
  Future<String?> saveRecipe(KitchaRecipe recipe) async {
    if (!FirebaseService.isAvailable) {
      LoggerService.warning('Cannot save recipe - Firebase unavailable');
      return null;
    }

    try {
      final docRef = await FirebaseFirestore.instance
          .collection(_collection)
          .add(recipe.toJson());

      LoggerService.info('Recipe saved: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Failed to save recipe', e);
      return null;
    }
  }

  /// Update recipe.
  Future<bool> updateRecipe(KitchaRecipe recipe) async {
    if (!FirebaseService.isAvailable) return false;

    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(recipe.id)
          .update({...recipe.toJson(), 'updatedAt': FieldValue.serverTimestamp()});

      LoggerService.info('Recipe updated: ${recipe.id}');
      return true;
    } catch (e) {
      LoggerService.error('Failed to update recipe', e);
      return false;
    }
  }

  /// Delete recipe.
  Future<bool> deleteRecipe(String id) async {
    if (!FirebaseService.isAvailable) return false;

    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id)
          .delete();

      LoggerService.info('Recipe deleted: $id');
      return true;
    } catch (e) {
      LoggerService.error('Failed to delete recipe', e);
      return false;
    }
  }

  /// Get premium recipes.
  Future<List<KitchaRecipe>> getPremiumRecipes({int limit = 20}) async {
    if (!FirebaseService.isAvailable) {
      return _getSampleRecipes().where((r) => r.isPremium).toList();
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .where('isPremium', isEqualTo: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => KitchaRecipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get premium recipes', e);
      return [];
    }
  }

  /// Get popular recipes.
  Future<List<KitchaRecipe>> getPopularRecipes({int limit = 10}) async {
    if (!FirebaseService.isAvailable) {
      final recipes = _getSampleRecipes();
      recipes.sort((a, b) => b.totalRatings.compareTo(a.totalRatings));
      return recipes.take(limit).toList();
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .orderBy('totalRatings', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => KitchaRecipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get popular recipes', e);
      return [];
    }
  }

  /// Seed sample recipes (for initial setup).
  Future<void> seedSampleRecipes() async {
    if (!FirebaseService.isAvailable) return;

    final recipes = _getSampleRecipes();
    final batch = FirebaseFirestore.instance.batch();

    for (final recipe in recipes) {
      final docRef = FirebaseFirestore.instance
          .collection(_collection)
          .doc(recipe.id);
      batch.set(docRef, recipe.toJson());
    }

    await batch.commit();
    LoggerService.info('Seeded ${recipes.length} sample recipes');
  }

  /// Sample Turkish recipes.
  List<KitchaRecipe> _getSampleRecipes() {
    final now = DateTime.now();
    return [
      KitchaRecipe(
        id: 'kitcha_001',
        titleTR: 'İskender Kebap',
        titleEN: 'Iskender Kebab',
        descriptionTR: 'Bursa\'nın meşhur lezzeti, tereyağlı domates soslu döner.',
        category: 'Ana Yemek',
        difficulty: 'Orta',
        prepTime: 30,
        cookTime: 45,
        servings: 4,
        calories: 650,
        ingredients: [
          const RecipeIngredient(name: 'kuzu eti', quantity: '500', unit: 'g'),
          const RecipeIngredient(name: 'pide', quantity: '2', unit: 'adet'),
          const RecipeIngredient(name: 'tereyağı', quantity: '50', unit: 'g'),
          const RecipeIngredient(name: 'domates', quantity: '3', unit: 'adet'),
          const RecipeIngredient(name: 'yoğurt', quantity: '200', unit: 'g'),
        ],
        instructionsTR: [
          'Kuzu etini ince şeritler halinde doğrayın',
          'Pideyi küp şeklinde kesin ve tepsiye dizin',
          'Yoğurdu sarımsaklı hale getirin',
          'Domatesleri rendeleyin ve sosunu hazırlayın',
          'Eti pişirip pidenin üzerine yerleştirin',
          'Domates sosu ve eritilmiş tereyağı dökün',
          'Yanında yoğurtla servis edin',
        ],
        instructionsEN: [
          'Cut the lamb into thin strips',
          'Cut pita bread into cubes and arrange on a tray',
          'Mix yogurt with garlic',
          'Grate tomatoes and prepare the sauce',
          'Cook the meat and place on the bread',
          'Pour tomato sauce and melted butter',
          'Serve with yogurt on the side',
        ],
        tags: ['kebap', 'et', 'türk mutfağı', 'bursa'],
        averageRating: 4.8,
        totalRatings: 245,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      KitchaRecipe(
        id: 'kitcha_002',
        titleTR: 'Menemen',
        titleEN: 'Turkish Scrambled Eggs',
        descriptionTR: 'Klasik Türk kahvaltısının vazgeçilmezi.',
        category: 'Kahvaltı',
        difficulty: 'Kolay',
        prepTime: 10,
        cookTime: 15,
        servings: 2,
        calories: 280,
        ingredients: [
          const RecipeIngredient(name: 'yumurta', quantity: '4', unit: 'adet'),
          const RecipeIngredient(name: 'domates', quantity: '2', unit: 'adet'),
          const RecipeIngredient(name: 'yeşil biber', quantity: '2', unit: 'adet'),
          const RecipeIngredient(name: 'soğan', quantity: '1', unit: 'adet'),
          const RecipeIngredient(name: 'zeytinyağı', quantity: '2', unit: 'yemek kaşığı'),
        ],
        instructionsTR: [
          'Sebzeleri küçük küpler halinde doğrayın',
          'Tavada zeytinyağını ısıtın',
          'Önce soğanı, sonra biberi kavurun',
          'Domatesleri ekleyip suyunu çekmesini bekleyin',
          'Yumurtaları kırıp karıştırarak pişirin',
          'Tuz ve karabiber ekleyip servis edin',
        ],
        tags: ['kahvaltı', 'yumurta', 'kolay', 'vejetaryen'],
        averageRating: 4.6,
        totalRatings: 189,
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      KitchaRecipe(
        id: 'kitcha_003',
        titleTR: 'Mercimek Çorbası',
        titleEN: 'Red Lentil Soup',
        descriptionTR: 'Besleyici ve doyurucu geleneksel Türk çorbası.',
        category: 'Çorba',
        difficulty: 'Kolay',
        prepTime: 15,
        cookTime: 30,
        servings: 6,
        calories: 180,
        ingredients: [
          const RecipeIngredient(name: 'kırmızı mercimek', quantity: '1.5', unit: 'su bardağı'),
          const RecipeIngredient(name: 'soğan', quantity: '1', unit: 'adet'),
          const RecipeIngredient(name: 'havuç', quantity: '1', unit: 'adet'),
          const RecipeIngredient(name: 'patates', quantity: '1', unit: 'adet'),
          const RecipeIngredient(name: 'su', quantity: '1.5', unit: 'litre'),
        ],
        instructionsTR: [
          'Mercimekleri yıkayıp süzün',
          'Sebzeleri doğrayın',
          'Tüm malzemeleri tencereye alın',
          'Yumuşayana kadar pişirin',
          'Blenderdan geçirin',
          'Tereyağlı kırmızı biberle servis edin',
        ],
        tags: ['çorba', 'vegan', 'sağlıklı', 'kolay'],
        averageRating: 4.7,
        totalRatings: 312,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      KitchaRecipe(
        id: 'kitcha_004',
        titleTR: 'Karnıyarık',
        titleEN: 'Stuffed Eggplant',
        descriptionTR: 'Patlıcan severlerin favorisi, kıymalı karnıyarık.',
        category: 'Ana Yemek',
        difficulty: 'Orta',
        prepTime: 25,
        cookTime: 40,
        servings: 4,
        calories: 420,
        ingredients: [
          const RecipeIngredient(name: 'patlıcan', quantity: '4', unit: 'adet'),
          const RecipeIngredient(name: 'kıyma', quantity: '300', unit: 'g'),
          const RecipeIngredient(name: 'soğan', quantity: '2', unit: 'adet'),
          const RecipeIngredient(name: 'domates', quantity: '2', unit: 'adet'),
          const RecipeIngredient(name: 'yeşil biber', quantity: '2', unit: 'adet'),
        ],
        instructionsTR: [
          'Patlıcanları alacalı soyup kızartın',
          'Kıymayı soğanla kavurun',
          'Domates ve biberi ekleyin',
          'Patlıcanları yarıp iç harcı doldurun',
          'Fırında veya tencerede pişirin',
          'Pilav yanında servis edin',
        ],
        tags: ['patlıcan', 'kıyma', 'türk mutfağı', 'fırın'],
        averageRating: 4.5,
        totalRatings: 156,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      KitchaRecipe(
        id: 'kitcha_005',
        titleTR: 'Baklava',
        titleEN: 'Baklava',
        descriptionTR: 'Bayramların vazgeçilmezi, cevizli baklava.',
        category: 'Tatlı',
        difficulty: 'Zor',
        prepTime: 60,
        cookTime: 45,
        servings: 24,
        calories: 350,
        isPremium: true,
        ingredients: [
          const RecipeIngredient(name: 'yufka', quantity: '40', unit: 'yaprak'),
          const RecipeIngredient(name: 'ceviz', quantity: '500', unit: 'g'),
          const RecipeIngredient(name: 'tereyağı', quantity: '250', unit: 'g'),
          const RecipeIngredient(name: 'şeker', quantity: '3', unit: 'su bardağı'),
          const RecipeIngredient(name: 'su', quantity: '2', unit: 'su bardağı'),
        ],
        instructionsTR: [
          'Cevizleri iri iri çekin',
          'Yufkaları teker teker yağlayarak dizin',
          'Her 4 yufkadan sonra ceviz serpin',
          'Baklava şeklinde kesin',
          'Fırında altın rengi olana kadar pişirin',
          'Ilık şerbeti dökün ve dinlendirin',
        ],
        tags: ['tatlı', 'bayram', 'geleneksel', 'özel'],
        averageRating: 4.9,
        totalRatings: 428,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      // Additional recipes
      KitchaRecipe(
        id: 'kitcha_006',
        titleTR: 'Lahmacun',
        titleEN: 'Turkish Pizza',
        descriptionTR: 'İnce hamur üzerine kıymalı, baharatlı lezzet.',
        category: 'Ana Yemek',
        difficulty: 'Orta',
        prepTime: 30,
        cookTime: 10,
        servings: 6,
        calories: 320,
        ingredients: [
          const RecipeIngredient(name: 'un', quantity: '500', unit: 'g'),
          const RecipeIngredient(name: 'kıyma', quantity: '400', unit: 'g'),
          const RecipeIngredient(name: 'domates', quantity: '3', unit: 'adet'),
          const RecipeIngredient(name: 'soğan', quantity: '2', unit: 'adet'),
          const RecipeIngredient(name: 'maydanoz', quantity: '1', unit: 'demet'),
        ],
        instructionsTR: [
          'Hamuru yoğurun ve dinlendirin',
          'Kıymayı sebze ve baharatlarla karıştırın',
          'Hamuru ince açın',
          'Harçı yayın',
          'Yüksek ateşte pişirin',
          'Limon ve maydanozla servis edin',
        ],
        tags: ['lahmacun', 'kıyma', 'türk mutfağı'],
        averageRating: 4.7,
        totalRatings: 287,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      KitchaRecipe(
        id: 'kitcha_007',
        titleTR: 'Mantı',
        titleEN: 'Turkish Dumplings',
        descriptionTR: 'Yoğurt ve salçalı sos ile servis edilen geleneksel mantı.',
        category: 'Ana Yemek',
        difficulty: 'Zor',
        prepTime: 90,
        cookTime: 20,
        servings: 6,
        calories: 480,
        isPremium: true,
        ingredients: [
          const RecipeIngredient(name: 'un', quantity: '3', unit: 'su bardağı'),
          const RecipeIngredient(name: 'kıyma', quantity: '300', unit: 'g'),
          const RecipeIngredient(name: 'yumurta', quantity: '1', unit: 'adet'),
          const RecipeIngredient(name: 'yoğurt', quantity: '500', unit: 'g'),
          const RecipeIngredient(name: 'sarımsak', quantity: '4', unit: 'diş'),
        ],
        instructionsTR: [
          'Hamuru yoğurun ve ince açın',
          'Küçük kareler kesin',
          'Her kareye kıyma koyup kapatın',
          'Kaynar suda haşlayın',
          'Sarımsaklı yoğurt hazırlayın',
          'Salçalı tereyağı ile servis edin',
        ],
        tags: ['mantı', 'geleneksel', 'kayseri', 'özel'],
        averageRating: 4.8,
        totalRatings: 195,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      KitchaRecipe(
        id: 'kitcha_008',
        titleTR: 'İmam Bayıldı',
        titleEN: 'Stuffed Eggplant in Olive Oil',
        descriptionTR: 'Zeytinyağlı, soğan ve domatesli patlıcan dolması.',
        category: 'Sebze Yemekleri',
        difficulty: 'Orta',
        prepTime: 30,
        cookTime: 45,
        servings: 4,
        calories: 220,
        ingredients: [
          const RecipeIngredient(name: 'patlıcan', quantity: '4', unit: 'adet'),
          const RecipeIngredient(name: 'soğan', quantity: '4', unit: 'adet'),
          const RecipeIngredient(name: 'domates', quantity: '4', unit: 'adet'),
          const RecipeIngredient(name: 'zeytinyağı', quantity: '1', unit: 'su bardağı'),
          const RecipeIngredient(name: 'sarımsak', quantity: '6', unit: 'diş'),
        ],
        instructionsTR: [
          'Patlıcanları alacalı soyun',
          'Ortalarını yarın',
          'Soğanları ince doğrayıp kavurun',
          'Domates ve sarımsak ekleyin',
          'Patlıcanları doldurup fırına verin',
          'Soğuk servis edin',
        ],
        tags: ['zeytinyağlı', 'vejetaryen', 'soğuk'],
        averageRating: 4.6,
        totalRatings: 167,
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      KitchaRecipe(
        id: 'kitcha_009',
        titleTR: 'Adana Kebap',
        titleEN: 'Adana Kebab',
        descriptionTR: 'Acılı, el yapımı kıyma kebabı.',
        category: 'Et Yemekleri',
        difficulty: 'Orta',
        prepTime: 25,
        cookTime: 15,
        servings: 4,
        calories: 520,
        ingredients: [
          const RecipeIngredient(name: 'kuzu kıyma', quantity: '500', unit: 'g'),
          const RecipeIngredient(name: 'kuyruk yağı', quantity: '50', unit: 'g'),
          const RecipeIngredient(name: 'pul biber', quantity: '2', unit: 'yemek kaşığı'),
          const RecipeIngredient(name: 'tuz', quantity: '1', unit: 'çay kaşığı'),
          const RecipeIngredient(name: 'lavaş', quantity: '4', unit: 'adet'),
        ],
        instructionsTR: [
          'Kıymayı yağ ve baharatlarla yoğurun',
          'Şişlere sarın',
          'Mangalda veya ızgarada pişirin',
          'Lavaş ekmekle servis edin',
          'Yanında soğan ve sumak sunun',
        ],
        tags: ['kebap', 'et', 'adana', 'acılı'],
        averageRating: 4.9,
        totalRatings: 342,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      KitchaRecipe(
        id: 'kitcha_010',
        titleTR: 'Sütlaç',
        titleEN: 'Turkish Rice Pudding',
        descriptionTR: 'Fırında pişmiş, üstü kızarmış sütlaç.',
        category: 'Tatlı',
        difficulty: 'Kolay',
        prepTime: 15,
        cookTime: 40,
        servings: 6,
        calories: 240,
        ingredients: [
          const RecipeIngredient(name: 'pirinç', quantity: '1', unit: 'su bardağı'),
          const RecipeIngredient(name: 'süt', quantity: '1', unit: 'litre'),
          const RecipeIngredient(name: 'şeker', quantity: '1', unit: 'su bardağı'),
          const RecipeIngredient(name: 'pirinç unu', quantity: '2', unit: 'yemek kaşığı'),
          const RecipeIngredient(name: 'vanilya', quantity: '1', unit: 'paket'),
        ],
        instructionsTR: [
          'Pirinci haşlayın',
          'Sütü kaynatın',
          'Pirinç unu ile kıvam verin',
          'Şeker ve vanilyayı ekleyin',
          'Kaselere dökün',
          'Fırında üstünü kızartın',
        ],
        tags: ['tatlı', 'sütlü', 'geleneksel'],
        averageRating: 4.5,
        totalRatings: 198,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      KitchaRecipe(
        id: 'kitcha_011',
        titleTR: 'Çılbır',
        titleEN: 'Turkish Poached Eggs',
        descriptionTR: 'Yoğurtlu, tereyağlı poşe yumurta.',
        category: 'Kahvaltı',
        difficulty: 'Kolay',
        prepTime: 10,
        cookTime: 10,
        servings: 2,
        calories: 320,
        ingredients: [
          const RecipeIngredient(name: 'yumurta', quantity: '4', unit: 'adet'),
          const RecipeIngredient(name: 'yoğurt', quantity: '300', unit: 'g'),
          const RecipeIngredient(name: 'sarımsak', quantity: '2', unit: 'diş'),
          const RecipeIngredient(name: 'tereyağı', quantity: '50', unit: 'g'),
          const RecipeIngredient(name: 'pul biber', quantity: '1', unit: 'çay kaşığı'),
        ],
        instructionsTR: [
          'Yoğurdu sarımsakla karıştırın',
          'Yumurtaları poşe yapın',
          'Yoğurdun üzerine yerleştirin',
          'Pul biberli tereyağı dökün',
          'Sıcak servis edin',
        ],
        tags: ['kahvaltı', 'yumurta', 'yoğurtlu'],
        averageRating: 4.4,
        totalRatings: 134,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      KitchaRecipe(
        id: 'kitcha_012',
        titleTR: 'Pide',
        titleEN: 'Turkish Flatbread',
        descriptionTR: 'Kıymalı, kaşarlı fırın pidesi.',
        category: 'Hamur İşi',
        difficulty: 'Orta',
        prepTime: 40,
        cookTime: 15,
        servings: 4,
        calories: 450,
        ingredients: [
          const RecipeIngredient(name: 'un', quantity: '500', unit: 'g'),
          const RecipeIngredient(name: 'maya', quantity: '1', unit: 'paket'),
          const RecipeIngredient(name: 'kıyma', quantity: '300', unit: 'g'),
          const RecipeIngredient(name: 'kaşar peyniri', quantity: '200', unit: 'g'),
          const RecipeIngredient(name: 'yumurta', quantity: '2', unit: 'adet'),
        ],
        instructionsTR: [
          'Hamuru yoğurup mayalandırın',
          'Kayık şeklinde açın',
          'İç harcı yerleştirin',
          'Kenarları kıvırın',
          'Fırında pişirin',
          'Üzerine yumurta kırın',
        ],
        tags: ['pide', 'hamur işi', 'fırın'],
        averageRating: 4.7,
        totalRatings: 256,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      KitchaRecipe(
        id: 'kitcha_013',
        titleTR: 'Künefe',
        titleEN: 'Shredded Pastry Dessert',
        descriptionTR: 'Tel kadayıf ve peynirle yapılan sıcak tatlı.',
        category: 'Tatlı',
        difficulty: 'Orta',
        prepTime: 20,
        cookTime: 25,
        servings: 8,
        calories: 380,
        isPremium: true,
        ingredients: [
          const RecipeIngredient(name: 'tel kadayıf', quantity: '500', unit: 'g'),
          const RecipeIngredient(name: 'künefe peyniri', quantity: '300', unit: 'g'),
          const RecipeIngredient(name: 'tereyağı', quantity: '200', unit: 'g'),
          const RecipeIngredient(name: 'şeker', quantity: '2', unit: 'su bardağı'),
          const RecipeIngredient(name: 'antep fıstığı', quantity: '50', unit: 'g'),
        ],
        instructionsTR: [
          'Tel kadayıfı tereyağıyla karıştırın',
          'Yarısını tepsiye yayın',
          'Peyniri ekleyin',
          'Kalan kadayıfı üstüne koyun',
          'Altın rengi olana kadar pişirin',
          'Şerbet dökün ve fıstık serpin',
        ],
        tags: ['tatlı', 'künefe', 'hatay', 'özel'],
        averageRating: 4.9,
        totalRatings: 389,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      KitchaRecipe(
        id: 'kitcha_014',
        titleTR: 'Ezogelin Çorbası',
        titleEN: 'Red Lentil Soup with Bulgur',
        descriptionTR: 'Bulgur ve kırmızı mercimekli geleneksel çorba.',
        category: 'Çorba',
        difficulty: 'Kolay',
        prepTime: 10,
        cookTime: 25,
        servings: 6,
        calories: 160,
        ingredients: [
          const RecipeIngredient(name: 'kırmızı mercimek', quantity: '1', unit: 'su bardağı'),
          const RecipeIngredient(name: 'bulgur', quantity: '0.5', unit: 'su bardağı'),
          const RecipeIngredient(name: 'pirinç', quantity: '2', unit: 'yemek kaşığı'),
          const RecipeIngredient(name: 'domates salçası', quantity: '1', unit: 'yemek kaşığı'),
          const RecipeIngredient(name: 'nane', quantity: '1', unit: 'çay kaşığı'),
        ],
        instructionsTR: [
          'Tüm malzemeleri tencereye alın',
          'Su ekleyip kaynatın',
          'Yumuşayana kadar pişirin',
          'Naneli tereyağı ile servis edin',
        ],
        tags: ['çorba', 'mercimek', 'vegan'],
        averageRating: 4.6,
        totalRatings: 178,
        createdAt: now,
      ),
      KitchaRecipe(
        id: 'kitcha_015',
        titleTR: 'Kadayıf Dolması',
        titleEN: 'Walnut Stuffed Kadaif',
        descriptionTR: 'Cevizli, şerbetli kadayıf dolması.',
        category: 'Tatlı',
        difficulty: 'Orta',
        prepTime: 30,
        cookTime: 35,
        servings: 12,
        calories: 310,
        isPremium: true,
        ingredients: [
          const RecipeIngredient(name: 'tel kadayıf', quantity: '400', unit: 'g'),
          const RecipeIngredient(name: 'ceviz', quantity: '250', unit: 'g'),
          const RecipeIngredient(name: 'tereyağı', quantity: '150', unit: 'g'),
          const RecipeIngredient(name: 'şeker', quantity: '400', unit: 'g'),
          const RecipeIngredient(name: 'limon', quantity: '0.5', unit: 'adet'),
        ],
        instructionsTR: [
          'Kadayıfı şeritler halinde açın',
          'Cevizi ortaya koyup sarın',
          'Tereyağlı tepside dizin',
          'Kızarana kadar pişirin',
          'Ilık şerbet dökün',
        ],
        tags: ['tatlı', 'kadayıf', 'ceviz', 'özel'],
        averageRating: 4.7,
        totalRatings: 145,
        createdAt: now,
      ),
    ];
  }
}
