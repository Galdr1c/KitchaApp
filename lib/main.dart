import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/recipe_provider.dart';
import 'providers/analysis_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/sync_provider.dart';
import 'services/permission_service.dart';
import 'services/app_service.dart';
import 'services/firebase_service.dart';
import 'repository/app_repository.dart';
import 'screens/main_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/constants.dart';
import 'theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/mcp_client_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/firebase_mcp_service.dart';
import 'services/memory_mcp_service.dart';
import 'services/notification_mcp_service.dart';
import 'services/mcp_manager_service.dart';
import 'screens/developer_screen.dart';

import 'config/env.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Env.isProduction) {
    await SentryFlutter.init(
      (options) {
        options.dsn = Env.sentryDsn;
        options.tracesSampleRate = 1.0;
      },
      appRunner: () => _startApp(),
    );
  } else {
    await _startApp();
  }
}

Future<void> _startApp() async {
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('tr_TR', null);
  
  final mcpService = McpClientService();
  await mcpService.initialize();

  // Initialize Firebase with high resilience
  try {
    await FirebaseService.initialize();
    // Print service availability
    print('[Kitcha] Firebase available: ${FirebaseService.isAvailable}');
    if (FirebaseService.isAvailable) {
      await FirebaseService.syncFromFirestore();
      print('✅ [Kitcha] Firebase initialized successfully');
      
      // Initialize Firebase MCP Service (Remote Config, etc.)
      final firebaseMcp = FirebaseMcpService();
      await firebaseMcp.initRemoteConfig();
      
      // Initialize Memory Service
      await MemoryMcpService().initialize();
      
      // Initialize Notification Service
      await NotificationMcpService().initialize();

      // Initialize MCP Manager
      McpManagerService().initialize();
    } else {
      print('⚠️ [Kitcha] Firebase initialized but not available (likely missing config)');
    }
  } catch (e) {
    print('❌ [Kitcha] Firebase initialization critical error: $e');
  }
  
  // Initialize services
  final appService = AppService();
  await appService.initApiKeys();
  await appService.initML();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const KitchaApp());
}

/// Main application widget with theme configuration
class KitchaApp extends StatelessWidget {
  const KitchaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemePreference()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..loadProfile()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => McpManagerService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: FutureBuilder<bool>(
              future: SharedPreferences.getInstance().then((prefs) => prefs.getBool('onboarding_completed') ?? false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.data == true) {
                  return const PermissionWrapper(child: MainScreen());
                }
                return const OnboardingScreen();
              },
            ),
            routes: {
              AppRoutes.recipeDetail: (context) => const RecipeDetailScreen(),
              AppRoutes.settings: (context) => const SettingsScreen(),
              '/developer': (context) => const DeveloperScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/home': (context) => const PermissionWrapper(child: MainScreen()),
            },
            onGenerateRoute: (settings) {
              return null;
            },
            builder: (context, child) {
              return Stack(
                children: [
                   if (child != null) child,
                   Consumer<ConnectivityProvider>(
                     builder: (context, provider, _) {
                       if (provider.isOnline) return const SizedBox.shrink();
                       return const  Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Material(
                             color: Colors.red,
                             child: SafeArea(
                               top: false,
                               child: Padding(padding: EdgeInsets.all(4), child: Text("İnternet bağlantısı yok", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))
                             )
                          )
                       );
                     }
                   )
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Wrapper widget that handles permission requests and database initialization on app launch
class PermissionWrapper extends StatefulWidget {
  final Widget child;

  const PermissionWrapper({super.key, required this.child});

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  final PermissionService _permissionService = PermissionService();
  final AppRepository _repository = AppRepository();
  final AppService _appService = AppService();
  
  bool _isInitialized = false;
  bool _showOnboarding = false;
  String _statusMessage = 'Hazırlanıyor...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Request permissions
      _updateStatus('İzinler isteniyor...');
      await _permissionService.requestAllPermissions();
      
      // Step 2: Initialize database
      _updateStatus('Veritabanı başlatılıyor...');
      await _repository.database;
      print('[Main] Database initialized successfully');
      
      // Step 3: Insert sample data on first launch
      _updateStatus('Örnek veriler yükleniyor...');
      await _insertSampleDataOnFirstLaunch();
      
      // Step 4: Initialize ML services
      _updateStatus('ML servisleri başlatılıyor...');
      await _appService.initML();
      print('[Main] ML services initialized');
      
      // Step 5: Load initial data into providers
      _updateStatus('Veriler yükleniyor...');
      await _loadInitialData();
      
      // Step 6: Check Onboarding
      final prefs = await SharedPreferences.getInstance();
      final isFirstRun = prefs.getBool('isFirstRun') ?? true;
      if (isFirstRun) {
        if (mounted) setState(() => _showOnboarding = true);
      }
      
      // Done
      if (mounted) {
        setState(() => _isInitialized = true);
      }
      print('[Main] App initialization complete');
    } catch (e) {
      print('[Main] Initialization error: $e');
      // Continue anyway to show the app
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }
  
  void _updateStatus(String message) {
    if (mounted) {
      setState(() => _statusMessage = message);
    }
  }

  Future<void> _insertSampleDataOnFirstLaunch() async {
    try {
      final recipeCount = await _repository.getRecipeCount();
      
      if (recipeCount == 0) {
        print('[Main] First launch detected, inserting sample data...');
        
        // Insert sample recipes
        final sampleRecipes = _getSampleRecipes();
        for (final recipe in sampleRecipes) {
          final id = await _repository.insertRecipe(recipe);
          print('[Main] Inserted recipe: ${recipe.name} (ID: $id)');
        }
        
        // Insert sample analyses
        final sampleAnalyses = _getSampleAnalyses();
        for (final analysis in sampleAnalyses) {
          final id = await _repository.insertAnalysis(analysis);
          print('[Main] Inserted analysis ID: $id with ${analysis.foods.length} foods');
        }
        
        print('[Main] Sample data insertion complete');
        print('[Main] Total recipes: ${sampleRecipes.length}');
        print('[Main] Total analyses: ${sampleAnalyses.length}');
      } else {
        print('[Main] Database already has $recipeCount recipes, skipping sample data');
      }
    } catch (e) {
      print('[Main] Error inserting sample data: $e');
    }
  }

  List<RecipeModel> _getSampleRecipes() {
    return [
      // 1. Omlet
      RecipeModel(
        name: 'Omlet',
        ingredients: ['2 yumurta', '1 yemek kaşığı süt', 'Tuz', 'Karabiber', '1 yemek kaşığı tereyağı'],
        steps: [
          'Yumurtaları bir kaseye kırın ve çatalla çırpın',
          'Süt, tuz ve karabiberi ekleyip karıştırın',
          'Tavada tereyağını eritin',
          'Yumurta karışımını tavaya dökün',
          'Kısık ateşte 2-3 dakika pişirin',
          'Kenarları katlayarak servis edin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/ryspuw1511786711.jpg',
        isFavorite: true,
        calories: 200,
        protein: 14.0,
        carbs: 2.0,
        fat: 15.0,
        prepTime: 5,
        cookTime: 5,
        servings: 1,
        category: 'Kahvaltı',
      ),
      // 2. Menemen
      RecipeModel(
        name: 'Menemen',
        ingredients: ['3 yumurta', '2 domates', '2 yeşil biber', '1 soğan', '2 yemek kaşığı zeytinyağı', 'Tuz', 'Pul biber'],
        steps: [
          'Sebzeleri küçük küpler halinde doğrayın',
          'Tavada zeytinyağını kızdırın',
          'Soğanları pembeleşene kadar kavurun',
          'Biberleri ekleyip 2 dakika kavurun',
          'Domatesleri ekleyip sularını salana kadar pişirin',
          'Yumurtaları kırıp karıştırarak pişirin',
          'Tuz ve pul biber ekleyip servis edin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
        isFavorite: true,
        calories: 280,
        protein: 16.0,
        carbs: 12.0,
        fat: 18.0,
        prepTime: 10,
        cookTime: 15,
        servings: 2,
        category: 'Kahvaltı',
      ),
      // 3. Mercimek Çorbası
      RecipeModel(
        name: 'Mercimek Çorbası',
        ingredients: ['1 su bardağı kırmızı mercimek', '1 soğan', '1 havuç', '1 patates', '6 su bardağı su', '2 yemek kaşığı tereyağı', 'Tuz', 'Karabiber', 'Kimyon'],
        steps: [
          'Mercimekleri yıkayıp süzün',
          'Soğan, havuç ve patatesi küp doğrayın',
          'Tencereye yağı koyup sebzeleri kavurun',
          'Mercimek ve suyu ekleyin',
          'Kaynayınca kısık ateşte 25-30 dakika pişirin',
          'Blenderdan geçirin',
          'Baharatları ekleyip sıcak servis edin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/tnwy8m1628770384.jpg',
        isFavorite: false,
        calories: 180,
        protein: 12.0,
        carbs: 30.0,
        fat: 2.0,
        prepTime: 10,
        cookTime: 30,
        servings: 4,
        category: 'Çorba',
      ),
      // 4. Tavuk Sote
      RecipeModel(
        name: 'Tavuk Sote',
        ingredients: ['500g tavuk göğsü', '2 yeşil biber', '2 kırmızı biber', '2 domates', '1 soğan', '3 yemek kaşığı zeytinyağı', 'Tuz', 'Karabiber', 'Kekik'],
        steps: [
          'Tavukları kuşbaşı doğrayın',
          'Biberleri ve soğanı iri doğrayın',
          'Domatesleri küp doğrayın',
          'Yağda tavukları soteleyin',
          'Soğan ve biberleri ekleyip kavurun',
          'Domatesleri ekleyin',
          'Baharatları ekleyip 20 dakika pişirin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/wyxwsp1486979827.jpg',
        isFavorite: true,
        calories: 350,
        protein: 40.0,
        carbs: 10.0,
        fat: 16.0,
        prepTime: 15,
        cookTime: 25,
        servings: 3,
        category: 'Ana Yemek',
      ),
      // 5. Pilav
      RecipeModel(
        name: 'Tereyağlı Pilav',
        ingredients: ['2 su bardağı pirinç', '3.5 su bardağı tavuk suyu', '3 yemek kaşığı tereyağı', '1 çay kaşığı tuz', 'Şehriye (isteğe bağlı)'],
        steps: [
          'Pirinci yıkayıp 30 dakika ılık suda bekletin',
          'Tereyağının yarısını eritip şehriyeyi kavurun',
          'Süzülmüş pirinci ekleyip kavurun',
          'Kaynar suyu ekleyin',
          'Kaynayınca kısık ateşe alın',
          'Su çekilene kadar (15-20 dk) pişirin',
          'Kalan tereyağını ekleyip demlendirin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/xxpqsy1511452222.jpg',
        isFavorite: false,
        calories: 250,
        protein: 5.0,
        carbs: 50.0,
        fat: 5.0,
        prepTime: 35,
        cookTime: 25,
        servings: 4,
        category: 'Yan Yemek',
      ),
      // 6. Karnıyarık
      RecipeModel(
        name: 'Karnıyarık',
        ingredients: ['4 adet patlıcan', '300g kıyma', '2 domates', '1 soğan', '3 diş sarımsak', 'Zeytinyağı', 'Tuz', 'Karabiber', 'Pul biber'],
        steps: [
          'Patlıcanları alacalı soyup kızartın',
          'Kıymayı soğanla kavurun',
          'Domates ve baharatları ekleyin',
          'Patlıcanların ortasını açın',
          'İç harcı doldurun',
          'Üzerine domates dilimi koyun',
          '180°C fırında 30 dakika pişirin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/uyqrrv1511553350.jpg',
        isFavorite: true,
        calories: 420,
        protein: 22.0,
        carbs: 18.0,
        fat: 28.0,
        prepTime: 20,
        cookTime: 40,
        servings: 4,
        category: 'Ana Yemek',
      ),
      // 7. Sezar Salata
      RecipeModel(
        name: 'Sezar Salata',
        ingredients: ['1 adet marul', '100g parmesan', '1 su bardağı kruton', '200g tavuk göğsü', 'Sezar sos', 'Zeytinyağı'],
        steps: [
          'Tavuğu ızgara yapın ve dilimleyin',
          'Marulu yıkayıp parçalayın',
          'Krutonları hazırlayın',
          'Parmesan peynirini rendeleyin',
          'Tüm malzemeleri geniş tabağa dizin',
          'Sezar sosu gezdirin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg',
        isFavorite: false,
        calories: 320,
        protein: 25.0,
        carbs: 15.0,
        fat: 18.0,
        prepTime: 15,
        cookTime: 10,
        servings: 2,
        category: 'Salata',
      ),
      // 8. Makarna
      RecipeModel(
        name: 'Domates Soslu Makarna',
        ingredients: ['250g spagetti', '400g konserve domates', '3 diş sarımsak', '3 yemek kaşığı tereyağı', 'Taze fesleğen', 'Parmesan', 'Tuz', 'Karabiber'],
        steps: [
          'Makarnayı tuzlu suda haşlayın',
          'Sarımsakları ince kıyın',
          'Zeytinyağında sarımsakları kavurun',
          'Domatesleri ekleyip 10 dakika pişirin',
          'Baharatları ekleyin',
          'Makarnayı sosla karıştırın',
          'Parmesan ve fesleğenle servis edin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg',
        isFavorite: false,
        calories: 380,
        protein: 12.0,
        carbs: 65.0,
        fat: 8.0,
        prepTime: 5,
        cookTime: 15,
        servings: 2,
        category: 'Ana Yemek',
      ),
      // 9. Izgara Köfte
      RecipeModel(
        name: 'Izgara Köfte',
        ingredients: ['500g kıyma', '1 soğan (rendelenmiş)', '1 yumurta', '3 yemek kaşığı galeta unu', 'Tuz', 'Karabiber', 'Kimyon', 'Pul biber', 'Maydanoz'],
        steps: [
          'Kıymayı geniş bir kaba alın',
          'Rendelenmiş soğanı ekleyin',
          'Yumurta ve galeta ununu ilave edin',
          'Tüm baharatları ekleyin',
          '10 dakika yoğurun',
          'Köfte şekli verin',
          '30 dakika buzdolabında bekletin',
          'Izgarada her iki tarafı da pişirin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/wvqpwt1468339226.jpg',
        isFavorite: true,
        calories: 450,
        protein: 35.0,
        carbs: 10.0,
        fat: 30.0,
        prepTime: 45,
        cookTime: 15,
        servings: 4,
        category: 'Ana Yemek',
      ),
      // 10. Sütlaç
      RecipeModel(
        name: 'Sütlaç',
        ingredients: ['1 litre süt', '1/2 su bardağı pirinç', '1 su bardağı şeker', '2 yemek kaşığı pirinç unu', '1 paket vanilin', 'Tarçın'],
        steps: [
          'Pirinci yıkayıp haşlayın',
          'Sütü ayrı bir tencerede ısıtın',
          'Haşlanmış pirinci süte ekleyin',
          'Şekeri ilave edip karıştırın',
          'Pirinç ununu az sütle açıp ekleyin',
          'Kıvam alana kadar karıştırarak pişirin',
          'Vanilini ekleyin',
          'Kaselere bölüp soğutun',
          'Üzerine tarçın serpin'
        ],
        imageUrl: 'https://www.themealdb.com/images/media/meals/xqwwpy1483908697.jpg',
        isFavorite: false,
        calories: 280,
        protein: 8.0,
        carbs: 50.0,
        fat: 6.0,
        prepTime: 10,
        cookTime: 30,
        servings: 6,
        category: 'Tatlı',
      ),
    ];
  }

  List<AnalysisModel> _getSampleAnalyses() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    // final twoDaysAgo = today.subtract(const Duration(days: 2)); // Reserved for future use
    
    return [
      // Analysis 1: Today's Breakfast
      AnalysisModel(
        date: today.toIso8601String().split('T')[0],
        photoPath: '/mock/kahvalti_1.jpg',
        foods: [
          FoodItem(name: 'Omlet', grams: 150, calories: 200, protein: 14.0, carbs: 2.0, fat: 15.0),
          FoodItem(name: 'Ekmek', grams: 50, calories: 130, protein: 4.0, carbs: 25.0, fat: 1.0),
          FoodItem(name: 'Peynir', grams: 30, calories: 100, protein: 7.0, carbs: 0.5, fat: 8.0),
        ],
        totalCalories: 430,
        totalProtein: 25.0,
        totalCarbs: 27.5,
        totalFat: 24.0,
        notes: 'Sabah kahvaltısı',
      ),
      // Analysis 2: Today's Lunch
      AnalysisModel(
        date: today.toIso8601String().split('T')[0],
        photoPath: '/mock/ogle_yemegi_1.jpg',
        foods: [
          FoodItem(name: 'Tavuk Sote', grams: 200, calories: 280, protein: 32.0, carbs: 8.0, fat: 12.8),
          FoodItem(name: 'Pilav', grams: 150, calories: 190, protein: 3.8, carbs: 37.5, fat: 3.8),
          FoodItem(name: 'Salata', grams: 100, calories: 25, protein: 1.0, carbs: 5.0, fat: 0.2),
          FoodItem(name: 'Ayran', grams: 200, calories: 70, protein: 3.0, carbs: 4.0, fat: 3.5),
        ],
        totalCalories: 565,
        totalProtein: 39.8,
        totalCarbs: 54.5,
        totalFat: 20.3,
        notes: 'Öğle yemeği - iş yerinde',
      ),
      // Analysis 3: Yesterday's Dinner
      AnalysisModel(
        date: yesterday.toIso8601String().split('T')[0],
        photoPath: '/mock/aksam_yemegi_1.jpg',
        foods: [
          FoodItem(name: 'Köfte', grams: 180, calories: 360, protein: 25.2, carbs: 7.2, fat: 21.6),
          FoodItem(name: 'Makarna', grams: 200, calories: 300, protein: 10.0, carbs: 52.0, fat: 6.4),
          FoodItem(name: 'Cacık', grams: 150, calories: 65, protein: 4.5, carbs: 6.0, fat: 3.0),
        ],
        totalCalories: 725,
        totalProtein: 39.7,
        totalCarbs: 65.2,
        totalFat: 31.0,
        notes: 'Akşam yemeği - evde',
      ),
    ];
  }
  
  Future<void> _loadInitialData() async {
    try {
      // Get context for providers
      if (!mounted) return;
      
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      final analysisProvider = Provider.of<AnalysisProvider>(context, listen: false);
      
      // Load recipes from database
      final recipes = await _repository.getAllRecipes();
      recipeProvider.setRecipesFromDb(recipes);
      print('[Main] Loaded ${recipes.length} recipes into provider');
      
      // Load analyses from database  
      final analyses = await _repository.getAllAnalyses();
      analysisProvider.setAnalysesFromDb(analyses);
      print('[Main] Loaded ${analyses.length} analyses into provider');
      
    } catch (e) {
      print('[Main] Error loading initial data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Detect current brightness for splash screen
      final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      
      return Scaffold(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                style: TextStyle(
                  color: isDarkMode ? const Color(0xFF9E9E9E) : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_showOnboarding) {
      return const OnboardingScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseService.isAvailable ? FirebaseAuth.instance.authStateChanges() : Stream.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
           return widget.child;
        }
        return const LoginScreen();
      },
    );
  }
}
