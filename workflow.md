🍅 KitchaApp Development Workflow & Feature Roadmap
COMPLETE & COMPREHENSIVE EDITIONProje: KitchaApp - Flutter Yemek Tarifi ve Kalori Hesaplama Uygulaması
Versiyon: 2.0 (Freemium + Premium Features)
Tarih: 02 Ocak 2026
Mevcut Durum: v1.0 
Temel özellikler (tarif arama, kalori analizi, favoriler, geçmiş)
Dosya Versiyonu: 2.0 - Complete Edition
📋 İÇİNDEKİLER
Proje Özeti
Geliştirme Fazları
Öncelik Sıralaması
Detaylı Feature Workflow
Backend & Infrastructure
Security & Compliance
UI/UX Improvements
Performance & Optimization
DevOps & Monitoring
Marketing & Growth
Community Features
Teknik Altyapı
Test Stratejisi
Deployment Planı
Backup & Recovery
🎯 PROJE ÖZETİ
Mevcut Özellikler (v1.0)

✅ Tarif arama (TheMealDB API)
✅ Fotoğraf tabanlı kalori analizi (Google ML Kit)
✅ Favori tarifler
✅ Analiz geçmişi
✅ Dark mode
✅ Kullanıcı profili
✅ Sosyal paylaşım
✅ Offline mode
✅ Sesli arama
✅ Beslenme raporları

PHASE 1 - Monetization & Analytics

🆕 Freemium model (Guest access + Premium gating)
🆕 Google AdMob entegrasyonu
🆕 In-App Purchases (Aylık/Ömür boyu abonelik)
🆕 RevenueCat backend validation
🆕 Firebase Analytics + Crashlytics
🆕 Privacy Policy & Terms of Service
🆕 Input validation & security hardening

PHASE 1.5 - Retention & Engagement Foundation

🆕 Push Notifications (Firebase Cloud Messaging)
🆕 In-App Review prompts
🆕 A/B Testing (Firebase Remote Config)
🆕 API Caching Strategy (Hive/Firestore)
🆕 Feature Flags system
🆕 User Feedback system

PHASE 2 - AI & Engagement

🆕 Snap & Cook AI (Malzeme tanıma + tarif önerisi)
🆕 Gamification (XP, rozet, sıralama sistemi)
🆕 Akıllı Alışveriş Listesi
🆕 Weekly Challenges
🆕 Achievement System

PHASE 2.5 - Community & Social

🆕 Deep Linking (tarif paylaşımı)
🆕 Referral System (arkadaşını davet et)
🆕 Recipe Comments & Ratings
🆕 Public User Profiles
🆕 Follow/Unfollow system
🆕 Social Feed

PHASE 3 - Seasonal Experience

🆕 Mevsimsel tema motoru
🆕 Tatil bazlı UI dönüşümleri
🆕 Animasyonlu overlay'ler

PHASE 4 - Multilingual & Content

🆕 15+ dil desteği
🆕 Otomatik çeviri (API + cache)
🆕 RTL dil desteği
🆕 Custom Türkçe Recipe Database
🆕 Algolia/Typesense Advanced Search
🆕 AI Personalized Recommendations

PHASE 5 - Premium Polish

🆕 Haptik feedback sistemi
🆕 Wake lock (pişirme modu)
🆕 Mikro animasyonlar
🆕 Skeleton loaders (tüm ekranlarda)
🆕 Accessibility improvements

PHASE 6 - UX Enhancements

🆕 Dinamik porsiyon hesaplayıcı
🆕 AMOLED dark mode
🆕 İnteraktif empty state'ler
🆕 Onboarding flow
🆕 Image compression & optimization

PHASE 7 - Year in Review

🆕 Kitcha Flavor Journey (Spotify Wrapped tarzı)
🆕 Yıllık retrospektif özelliği

🚀 GELİŞTİRME FAZLARI
PHASE 1: Monetization & Analytics Foundation
Hedef: Uygulamayı freemium modele dönüştür, gelir akışı oluştur, analytics kur
Alt Görevler:
1.1 Guest Access Implementation

 main.dart güncelle: LoginScreen zorunluluğunu kaldır
 HomeScreen'i doğrudan başlat
 Firebase Auth optional yap
 SharedPreferences ile guest mode flagı ekle
dart// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Check if user is logged in
  final prefs = await SharedPreferences.getInstance();
  final isGuest = prefs.getBool('is_guest') ?? true;
  
  runApp(MyApp(isGuest: isGuest));
}

class MyApp extends StatelessWidget {
  final bool isGuest;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isGuest ? HomeScreen() : MainScreen(),
    );
  }
}
```
## 1.2 Action Guard System
dart// Dosya: lib/utils/action_guard.dart
class ActionGuard {
  static Future<void> protect(
    BuildContext context, 
    VoidCallback callback,
    {String featureName = 'Bu özellik'}
  ) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      callback();
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LoginBottomSheet(
          featureName: featureName,
        ),
      );
    }
  }
  
  static Future<bool> checkPremium(
    BuildContext context,
    {String featureName = 'Bu özellik'}
  ) async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    if (subscriptionProvider.isPremium) {
      return true;
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PremiumScreen()),
      );
      return false;
    }
  }
}Guard Uygulanacak Özellikler:

 Add to Favorites butonu → ActionGuard.protect()
 Create Meal Plan butonu → ActionGuard.checkPremium()
 Camera Calorie Calculate butonu (free: 1/day) → Custom logic
 Post Comment butonu → ActionGuard.protect()
 AI Snap & Cook → ActionGuard.checkPremium()
 Shopping List Share → ActionGuard.checkPremium()
## 1.3 Firebase Analytics & Crashlytics
yaml# pubspec.yaml
dependencies:
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.9Setup:
dart// lib/services/analytics_service.dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
  
  // Predefined events
  Future<void> logRecipeView(String recipeId, String recipeName) async {
    await logEvent('recipe_viewed', {
      'recipe_id': recipeId,
      'recipe_name': recipeName,
    });
  }
  
  Future<void> logFavoriteAdd(String recipeId) async {
    await logEvent('favorite_added', {'recipe_id': recipeId});
  }
  
  Future<void> logCalorieCalculate(int calories) async {
    await logEvent('calorie_calculated', {'calories': calories});
  }
  
  Future<void> logPremiumPaywallShown() async {
    await logEvent('premium_paywall_shown', null);
  }
  
  Future<void> logSubscriptionPurchase(String type, double price) async {
    await logEvent('subscription_purchased', {
      'subscription_type': type,
      'price': price,
    });
  }
  
  Future<void> logAICameraUsed() async {
    await logEvent('ai_camera_used', null);
  }
  
  Future<void> logShoppingListCreated(int itemCount) async {
    await logEvent('shopping_list_created', {'item_count': itemCount});
  }
}

// Crashlytics setup in main.dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};Tracked Events:
EventParametersPurposerecipe_viewedrecipe_id, recipe_namePopüler tariflerfavorite_addedrecipe_idEngagementcalorie_calculatedcaloriesCore feature usagepremium_paywall_shown-Conversion funnelsubscription_purchasedtype, priceRevenue trackingai_camera_used-AI feature adoptionshopping_list_createditem_countFeature adoptioncomment_postedrecipe_idCommunity engagementbadge_unlockedbadge_idGamification
# 1.4 Google AdMob Integration
##yaml# pubspec.yaml ekle
dependencies:
  google_mobile_ads: ^5.0.0Dosya Yapısı:
lib/services/
├── ad_manager.dart           # Ana ad yöneticisi
├── banner_ad_widget.dart     # Banner widget
└── interstitial_ad_helper.dartAdMob Konfigürasyonu:dart// lib/services/ad_manager.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // Test IDs (geliştirme)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  // Production IDs
  static const String _prodBannerAdUnitId = 'YOUR_BANNER_ID';
  static const String _prodInterstitialAdUnitId = 'YOUR_INTERSTITIAL_ID';
  
  String get bannerAdUnitId {
    return kDebugMode ? _testBannerAdUnitId : _prodBannerAdUnitId;
  }
  
  String get interstitialAdUnitId {
    return kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;
  }
  
  int _interstitialCounter = 0;
  InterstitialAd? _interstitialAd;
  
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
  }
  
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
  
  Future<void> showInterstitialIfReady() async {
    _interstitialCounter++;
    
    // Her 3 tarif tıklamasında göster
    if (_interstitialCounter % 3 == 0 && _interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd(); // Yeni ad yükle
    }
  }
  
  bool shouldShowAds(bool isPremium) {
    return !isPremium;
  }
}

// lib/widgets/banner_ad_widget.dart
class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager().bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('BannerAd failed to load: $error');
        },
      ),
    );
    
    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    
    // Premium kullanıcılara reklam gösterme
    if (subscriptionProvider.isPremium || !_isAdLoaded) {
      return SizedBox.shrink();
    }
    
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}AndroidManifest.xml:
xml<manifest>
  <application>
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
  </application>
</manifest>Info.plist (iOS):
xml<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>Ad Placement Strategy:

 HomeScreen alt kısmına banner
 RecipeDetailScreen alt kısmına banner
 Her 3 tarif tıklamasında interstitial
 Premium kullanıcılara hiç reklam gösterme
## 1.5 RevenueCat Integration (IAP Backend Validation)
## yaml# pubspec.yaml
dependencies:
  purchases_flutter: ^6.0.0  # RevenueCat SDKNeden RevenueCat?

✅ Server-side receipt validation
✅ Fraudulent purchase detection
✅ Cross-platform subscription management
✅ Analytics & webhooks
✅ Free tier: 10K monthly tracked users
Setup:
dart// lib/services/revenue_cat_service.dart
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _apiKey = 'YOUR_REVENUECAT_API_KEY';
  
  Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    
    PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey);
    await Purchases.configure(configuration);
  }
  
  Future<void> login(String userId) async {
    await Purchases.logIn(userId);
  }
  
  Future<void> logout() async {
    await Purchases.logOut();
  }
  
  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }
  
  Future<bool> isPremium() async {
    CustomerInfo customerInfo = await getCustomerInfo();
    return customerInfo.entitlements.all['premium']?.isActive ?? false;
  }
  
  Future<void> purchaseMonthly() async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(
        await _getMonthlyPackage(),
      );
      
      if (customerInfo.entitlements.all['premium']?.isActive ?? false) {
        // Premium activated!
        await _updateFirestore(customerInfo);
      }
    } catch (e) {
      print('Purchase error: $e');
      rethrow;
    }
  }
  
  Future<void> purchaseLifetime() async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(
        await _getLifetimePackage(),
      );
      
      if (customerInfo.entitlements.all['premium']?.isActive ?? false) {
        await _updateFirestore(customerInfo);
      }
    } catch (e) {
      print('Purchase error: $e');
      rethrow;
    }
  }
  
  Future<void> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      await _updateFirestore(customerInfo);
    } catch (e) {
      print('Restore error: $e');
      rethrow;
    }
  }
  
  Future<Package> _getMonthlyPackage() async {
    Offerings offerings = await Purchases.getOfferings();
    return offerings.current!.monthly!;
  }
  
  Future<Package> _getLifetimePackage() async {
    Offerings offerings = await Purchases.getOfferings();
    return offerings.current!.lifetime!;
  }
  
  Future<void> _updateFirestore(CustomerInfo info) async {
    final isPremium = info.entitlements.all['premium']?.isActive ?? false;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isPremium': isPremium,
        'subscriptionType': isPremium ? 'premium' : 'free',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }
}RevenueCat Dashboard Setup:

https://app.revenuecat.com/ → Sign up
Create new project
Add products:

kitcha_plus_monthly (Subscription)
kitcha_pro_lifetime (Non-consumable)


Configure entitlements: "premium"
Add webhook → Firebase Cloud Function
## 1.6 In-App Purchases (IAP) - Native Implementation (Fallback)Ürün ID'leri:

kitcha_plus_monthly - Aylık abonelik (₺39.99)
kitcha_pro_lifetime - Ömür boyu erişim (₺299.99)
Provider Yapısı:
dart// lib/providers/subscription_provider.dart
class SubscriptionProvider extends ChangeNotifier {
  final RevenueCatService _revenueCat = RevenueCatService();
  
  bool _isPremium = false;
  String _subscriptionType = 'free';
  
  bool get isPremium => _isPremium;
  String get subscriptionType => _subscriptionType;
  
  Future<void> initialize() async {
    await _revenueCat.initialize();
    await checkPremiumStatus();
  }
  
  Future<void> checkPremiumStatus() async {
    _isPremium = await _revenueCat.isPremium();
    notifyListeners();
  }
  
  Future<void> buyMonthly() async {
    await _revenueCat.purchaseMonthly();
    await checkPremiumStatus();
  }
  
  Future<void> buyLifetime() async {
    await _revenueCat.purchaseLifetime();
    await checkPremiumStatus();
  }
  
  Future<void> restorePurchases() async {
    await _revenueCat.restorePurchases();
    await checkPremiumStatus();
  }
}Firestore Yapısı:
users/{uid}/
  ├── isPremium: bool
  ├── subscriptionType: 'free' | 'monthly' | 'lifetime'
  ├── subscriptionExpiry: Timestamp (only for monthly)
  ├── purchaseToken: String
  ├── platform: 'android' | 'ios'
  └── lastUpdated: Timestamp
## 1.7 Premium Paywall UI dart// lib/screens/premium_screen.dart
class PremiumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Color(0xFFFF6347),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Kitcha Plus',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Unlimited recipes, AI features & more',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            
            // Feature Comparison
            _buildFeatureComparison(),
            
            // Pricing Cards
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildPricingCard(
                    title: 'Monthly',
                    price: '₺39.99',
                    period: '/month',
                    onTap: () => subscriptionProvider.buyMonthly(),
                    isPrimary: false,
                  ),
                  SizedBox(height: 16),
                  _buildPricingCard(
                    title: 'Lifetime',
                    price: '₺299.99',
                    period: 'one-time',
                    badge: 'BEST VALUE',
                    onTap: () => subscriptionProvider.buyLifetime(),
                    isPrimary: true,
                  ),
                ],
              ),
            ),
            
            // Restore Purchases
            TextButton(
              onPressed: () => subscriptionProvider.restorePurchases(),
              child: Text(
                'Restore Purchases',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureComparison() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildComparisonRow('Basic Recipes', true, true),
          _buildComparisonRow('Calorie Calculator', '1/day', '∞'),
          _buildComparisonRow('Ads', true, false),
          _buildComparisonRow('Meal Planner', false, true),
          _buildComparisonRow('AI Features', false, true),
          _buildComparisonRow('Shopping List Share', false, true),
          _buildComparisonRow('Priority Support', false, true),
        ],
      ),
    );
  }
  
  Widget _buildComparisonRow(String feature, dynamic free, dynamic premium) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF3A3A3A)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: _buildCheckOrText(free),
          ),
          Expanded(
            child: _buildCheckOrText(premium, isPremium: true),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCheckOrText(dynamic value, {bool isPremium = false}) {
    final color = isPremium ? Color(0xFFFF6347) : Colors.grey[600];
    
    if (value is bool) {
      return Center(
        child: value
          ? Icon(Icons.check, color: color)
          : Icon(Icons.close, color: Colors.grey[700]),
      );
    } else {
      return Center(
        child: Text(
          value.toString(),
          style: TextStyle(color: color),
        ),
      );
    }
  }
  
  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    String? badge,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPrimary
            ? LinearGradient(
                colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
              )
            : null,
          color: isPrimary ? null : Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary ? Colors.transparent : Color(0xFF3A3A3A),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: price,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' $period',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
##1.8 Privacy Policy & Terms of Service CRITICAL: App Store/Play Store submission için zorunlu!dart// lib/screens/legal_screen.dart
class LegalScreen extends StatelessWidget {
  final String title;
  final String content;
  
  const LegalScreen({
    required this.title,
    required this.content,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(content),
      ),
    );
  }
}Privacy Policy içeriği (örnek):
Kitcha Privacy Policy

Last Updated: January 2, 2026

1. Information We Collect
   - Email address (if you sign in)
   - Recipe views and favorites
   - Calorie calculations
   - Device information
   - Analytics data

2. How We Use Your Information
   - Provide app functionality
   - Improve user experience
   - Send notifications (if opted in)
   - Personalize content

3. Third-Party Services
   - Firebase (Analytics, Auth, Firestore)
   - Google AdMob (Ads)
   - RevenueCat (Payments)

4. Data Retention
   - Account data: Until deletion
   - Analytics: 14 months

5. Your Rights
   - Access your data
   - Delete your data
   - Opt-out of ads

6. Contact
   support@kitcha.appOnboarding'de consent:
dartCheckboxListTile(
  title: RichText(
    text: TextSpan(
      text: 'I agree to the ',
      children: [
        TextSpan(
          text: 'Terms of Service',
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _openTerms(),
        ),
        TextSpan(text: ' and '),
        TextSpan(
          text: 'Privacy Policy',
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _openPrivacy(),
        ),
      ],
    ),
  ),
  value: _agreedToTerms,
  onChanged: (value) => setState(() => _agreedToTerms = value!),
  
  **Privacy Policy içeriği (şablon):**
```
KITCHA PRIVACY POLICY

Last Updated: January 3, 2026

1. INFORMATION WE COLLECT
   - Email address (if you sign in)
   - Recipe views and favorites
   - Calorie calculations
   - Device information
   - Analytics data (via Firebase)

2. HOW WE USE YOUR INFORMATION
   - Provide app functionality
   - Improve user experience
   - Send notifications (if opted in)
   - Personalize content

3. THIRD-PARTY SERVICES
   - Firebase (Analytics, Auth, Firestore)
   - Google AdMob (Advertising)
   - RevenueCat (Payment processing)

4. DATA RETENTION
   - Account data: Until you delete your account
   - Analytics data: 14 months (Firebase default)
   - Cache data: Until expiration (7-30 days)

5. YOUR RIGHTS (GDPR)
   - Access your data
   - Export your data
   - Delete your data
   - Opt-out of marketing

6. CHILDREN'S PRIVACY
   - Our app is not intended for children under 13
   - We do not knowingly collect data from children

7. CONTACT US
   Email: support@kitcha.app
   Website: www.kitcha.app/privacy
```
)
#1.9 Input Validation & Securitydart// lib/utils/input_validator.dart
class InputValidator {
  static const int maxCommentLength = 500;
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 6;
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email gerekli';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir email girin';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < minPasswordLength) {
      return 'Şifre en az $minPasswordLength karakter olmalı';
    }
    return null;
  }
  
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gerekli';
    }
    if (value.length > maxUsernameLength) {
      return 'Kullanıcı adı maksimum $maxUsernameLength karakter olabilir';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Sadece harf, rakam ve _ kullanılabilir';
    }
    return null;
  }
  
  static String sanitize(String input) {
    // XSS prevention
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }
  
  static String? validateComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yorum boş olamaz';
    }
    if (value.length > maxCommentLength) {
      return 'Yorum maksimum $maxCommentLength karakter olabilir';
    }
    
    // Profanity filter (basit örnek)
    final badWords = ['spam', 'fake', 'scam'];
    for (var word in badWords) {
      if (value.toLowerCase().contains(word)) {
        return 'Uygunsuz içerik tespit edildi';
      }
    }
    
    return null;
  }
}
```
## ACCESSIBILITY - COLOR BLINDNESS FILTERS
## Implementation
dart// lib/providers/accessibility_provider.dart
import 'package:flutter/material.dart';

enum ColorBlindMode {
  none,
  protanopia,    // Kırmızı zayıflığı
  deuteranopia,  // Yeşil zayıflığı
  tritanopia,    // Mavi zayıflığı
  grayscale,     // Tam renk körlüğü
}

class AccessibilityProvider extends ChangeNotifier {
  ColorBlindMode _currentMode = ColorBlindMode.none;
  
  ColorBlindMode get currentMode => _currentMode;
  
  ColorFilter? get colorFilter {
    switch (_currentMode) {
      case ColorBlindMode.protanopia:
        return ColorFilter.matrix(_protanopiaMatrix);
      case ColorBlindMode.deuteranopia:
        return ColorFilter.matrix(_deuteranopiaMatrix);
      case ColorBlindMode.tritanopia:
        return ColorFilter.matrix(_tritanopiaMatrix);
      case ColorBlindMode.grayscale:
        return ColorFilter.matrix(_grayscaleMatrix);
      case ColorBlindMode.none:
        return null;
    }
  }
  
  // Protanopia (Red-weakness) Matrix
  static const List<double> _protanopiaMatrix = [
    0.567, 0.433, 0.000, 0, 0,
    0.558, 0.442, 0.000, 0, 0,
    0.000, 0.242, 0.758, 0, 0,
    0.000, 0.000, 0.000, 1, 0,
  ];
  
  // Deuteranopia (Green-weakness) Matrix
  static const List<double> _deuteranopiaMatrix = [
    0.625, 0.375, 0.000, 0, 0,
    0.700, 0.300, 0.000, 0, 0,
    0.000, 0.300, 0.700, 0, 0,
    0.000, 0.000, 0.000, 1, 0,
  ];
  
  // Tritanopia (Blue-weakness) Matrix
  static const List<double> _tritanopiaMatrix = [
    0.950, 0.050, 0.000, 0, 0,
    0.000, 0.433, 0.567, 0, 0,
    0.000, 0.475, 0.525, 0, 0,
    0.000, 0.000, 0.000, 1, 0,
  ];
  
  // Grayscale Matrix
  static const List<double> _grayscaleMatrix = [
    0.299, 0.587, 0.114, 0, 0,
    0.299, 0.587, 0.114, 0, 0,
    0.299, 0.587, 0.114, 0, 0,
    0.000, 0.000, 0.000, 1, 0,
  ];
  
  Future<void> setMode(ColorBlindMode mode) async {
    _currentMode = mode;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('color_blind_mode', mode.toString());
    
    notifyListeners();
  }
  
  Future<void> loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('color_blind_mode');
    
    if (savedMode != null) {
      _currentMode = ColorBlindMode.values.firstWhere(
        (mode) => mode.toString() == savedMode,
        orElse: () => ColorBlindMode.none,
      );
      notifyListeners();
    }
  }
}

// lib/main.dart - Global Wrapper
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccessibilityProvider()..loadSavedMode(),
      child: Consumer<AccessibilityProvider>(
        builder: (context, accessibility, _) {
          return ColorFiltered(
            colorFilter: accessibility.colorFilter ?? 
                         ColorFilter.mode(Colors.transparent, BlendMode.dst),
            child: MaterialApp(
              title: 'Kitcha',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}

// lib/screens/accessibility_screen.dart
class AccessibilityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccessibilityProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Erişilebilirlik'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Renk Körlüğü Filtreleri',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          // Preview Image
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage('assets/images/color_test.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Filter Options
          _buildFilterOption(
            context,
            ColorBlindMode.none,
            'Normal Görünüm',
            'Filtre yok',
            provider,
          ),
          _buildFilterOption(
            context,
            ColorBlindMode.protanopia,
            'Protanopi',
            'Kırmızı renk zayıflığı',
            provider,
          ),
          _buildFilterOption(
            context,
            ColorBlindMode.deuteranopia,
            'Deuteranopi',
            'Yeşil renk zayıflığı',
            provider,
          ),
          _buildFilterOption(
            context,
            ColorBlindMode.tritanopia,
            'Tritanopi',
            'Mavi renk zayıflığı',
            provider,
          ),
          _buildFilterOption(
            context,
            ColorBlindMode.grayscale,
            'Gri Tonlama',
            'Tam renk körlüğü',
            provider,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterOption(
    BuildContext context,
    ColorBlindMode mode,
    String title,
    String description,
    AccessibilityProvider provider,
  ) {
    return RadioListTile<ColorBlindMode>(
      title: Text(title),
      subtitle: Text(description),
      value: mode,
      groupValue: provider.currentMode,
      onChanged: (value) {
        if (value != null) {
          provider.setMode(value);
          HapticService.light();
        }
      },
    );
  }
}

# Rate Limiting (Client-side):
dart// lib/utils/rate_limiter.dart
class RateLimiter {
  static final Map<String, DateTime> _lastCallTimes = {};
  
  static bool canProceed(String action, {Duration cooldown = const Duration(seconds: 1)}) {
    final now = DateTime.now();
    final lastCall = _lastCallTimes[action];
    
    if (lastCall == null || now.difference(lastCall) >= cooldown) {
      _lastCallTimes[action] = now;
      return true;
    }
    
    return false;
  }
  
  static void reset(String action) {
    _lastCallTimes.remove(action);
  }
}

// Kullanım:
if (!RateLimiter.canProceed('search', cooldown: Duration(milliseconds: 500))) {
  return; // Too many requests
}
## PHASE 1.5: Retention & Engagement Foundation  Hedef: Kullanıcı retention'ını artır, engagement mekanizmalarını kur
## Push Notifications (Firebase Cloud Messaging)
##yaml# pubspec.yaml
dependencies:
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0Setup:
dart// lib/services/notification_service.dart
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get FCM token
      String? token = await _fcm.getToken();
      print('FCM Token: $token');
      
      // Save token to Firestore
      await _saveTokenToFirestore(token);
      
      // Listen for token refresh
      _fcm.onTokenRefresh.listen(_saveTokenToFirestore);
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    }
  }
  
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(RemoteMessage.fromMap({}));
      },
    );
  }
  
  Future<void> _saveTokenToFirestore(String? token) async {
    if (token == null) return;
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'fcmToken': token,
        'fcmTokenUpdated': FieldValue.serverTimestamp(),
      });
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification when app is in foreground
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Kitcha',
        body: notification.body ?? '',
        payload: message.data['route'],
      );
    }
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to specific screen
    final route = message.data['route'];
    if (route != null) {
      // navigatorKey.currentState?.pushNamed(route);
    }
  }
  
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'kitcha_channel',
      'Kitcha Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      0,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // Scheduled notifications
  Future<void> scheduleDaily Reminder() async {
    await _localNotifications.zonedSchedule(
      1,
      'Günlük Hatırlatma 🍽️',
      'Bugün kaç öğün analiz yaptın?',
      _nextInstanceOfTime(20, 0), // 20:00
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    
    return scheduledDate;
  }
}
**Notification Stratejisi:**

| Tip | Timing | Mesaj | CTA |
|-----|--------|-------|-----|
| Welcome | Kayıt sonrası 1 saat | "Kitcha'ya hoş geldin! İlk tarifini keşfet 🍅" | Open app |
| Daily Reminder | Her gün 20:00 | "Bugün kaç öğün analiz yaptın?" | Analyze meal |
| Weekly Report | Pazar 10:00 | "Haftalık raporun hazır! 📊" | View report |
| Badge Unlocked | Anlık | "Yeni rozet kazandın: Chef Master! 🏆" | View badge |
| Challenge | Cumartesi 09:00 | "Yeni haftalık challenge başladı!" | View challenge |
| Inactive User | 3 gün sonra | "Seni özledik! Yeni tarifler seni bekliyor" | Open app |
| Premium Offer | 7. gün (free user) | "Premium'a özel %50 indirim! 🎁" | View offer |

**Implementation:**
```dart
javascript// functions/src/index.ts
exports.sendWeeklyReport = functions.pubsub
  .schedule('every sunday 10:00')
  .timeZone('Europe/Istanbul')
  .onRun(async (context) => {
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where('notificationsEnabled', '==', true)
      .get();
    
    const messages = [];
    
    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      
      messages.push({
        token: userData.fcmToken,
        notification: {
          title: 'Haftalık Rapor 📊',
          body: `Bu hafta ${userData.weeklyRecipes || 0} tarif görüntüledin!`,
        },
        data: {
          route: '/weekly-report',
        },
      });
    }
    
    if (messages.length > 0) {
      await admin.messaging().sendAll(messages);
    }
  });
  
  ## 1.5.2 In-App Review Promptsyaml# pubspec.yaml
dependencies:
  in_app_review: ^2.0.9Implementation:
dart// lib/services/review_service.dart
class ReviewService {
  final InAppReview _inAppReview = InAppReview.instance;
  
  static const int _minActions = 10; // Minimum actions before asking
  static const int _cooldownDays = 30; // Don't ask again for 30 days
  
  Future<void> maybeRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if available
    if (!await _inAppReview.isAvailable()) return;
    
    // Check last request date
    final lastRequest = prefs.getInt('last_review_request') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSince = (now - lastRequest) / (1000 * 60 * 60 * 24);
    
    if (daysSince < _cooldownDays) return;
    
    // Check user actions
    final actionCount = prefs.getInt('user_action_count') ?? 0;
    if (actionCount < _minActions) return;
    
    // Request review
    await _inAppReview.requestReview();
    
    // Save request date
    await prefs.setInt('last_review_request', now);
    await prefs.setInt('user_action_count', 0);
  }
  
  Future<void> openStoreListing() async {
    await _inAppReview.openStoreListing(
      appStoreId: 'YOUR_APP_STORE_ID',
    );
  }
  
  Future<void> incrementActionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('user_action_count') ?? 0;
    await prefs.setInt('user_action_count', count + 1);
  }
}

// Kullanım (önemli aksiyon noktalarında):
// - Favoriye ekleme
// - 10. kalori hesaplama
// - Premium satın alma
await ReviewService().incrementActionCount();
await ReviewService().maybeRequestReview();
## 1.5.3 A/B Testing (Firebase Remote Config)yaml# pubspec.yaml
dependencies:
  firebase_remote_config: ^4.3.8Setup:
dart// lib/services/remote_config_service.dart
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    
    // Set defaults
    await _remoteConfig.setDefaults({
      'premium_monthly_price': 39.99,
      'premium_lifetime_price': 299.99,
      'free_daily_analysis_limit': 1,
      'paywall_button_color': '#FF6347',
      'show_referral_banner': false,
      'feature_flags': '{}',
    });
    
    await _remoteConfig.fetchAndActivate();
  }
  
  double getPremiumMonthlyPrice() {
    return _remoteConfig.getDouble('premium_monthly_price');
  }
  
  double getPremiumLifetimePrice() {
    return _remoteConfig.getDouble('premium_lifetime_price');
  }
  
  int getFreeDailyAnalysisLimit() {
    return _remoteConfig.getInt('free_daily_analysis_limit');
  }
  
  Color getPaywallButtonColor() {
    final hex = _remoteConfig.getString('paywall_button_color');
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
  
  bool shouldShowReferralBanner() {
    return _remoteConfig.getBool('show_referral_banner');
  }
  
  Map<String, bool> getFeatureFlags() {
    final jsonString = _remoteConfig.getString('feature_flags');
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return json.map((key, value) => MapEntry(key, value as bool));
  }
  
  bool isFeatureEnabled(String featureName) {
    final flags = getFeatureFlags();
    return flags[featureName] ?? false;
  }
}Firebase Console'da A/B Test Kurulumu:

Firebase Console → Remote Config
Add parameter: premium_monthly_price
Create experiment:

Variant A: ₺39.99 (50% traffic)
Variant B: ₺49.99 (50% traffic)


Goal: subscription_purchased event
Run for 2 weeks
Feature Flags Kullanımı:
dart// Check if new feature is enabled
final remoteConfig = RemoteConfigService();
if (remoteConfig.isFeatureEnabled('show_snap_and_cook')) {
  // Show Snap & Cook button
}
## 1.5.4 API Caching Strategydart// lib/services/api_cache_service.dart
class ApiCacheService {
  final _hive = Hive;
  
  static const String _recipeBoxName = 'recipe_cache';
  static const String _nutritionBoxName = 'nutrition_cache';
  
  Future<void> initialize() async {
    await _hive.openBox(_recipeBoxName);
    await _hive.openBox(_nutritionBoxName);
  }
  
  // Recipe caching (24 hours)
  Future<void> cacheRecipe(String id, Map<String, dynamic> data) async {
    final box = _hive.box(_recipeBoxName);
    await box.put(id, {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  Future<Map<String, dynamic>?> getRecipe(String id) async {
    final box = _hive.box(_recipeBoxName);
    final cached = box.get(id);
    
    if (cached == null) return null;
    
    final timestamp = cached['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final hoursSince = (now - timestamp) / (1000 * 60 * 60);
    
    // Cache valid for 24 hours
    if (hoursSince > 24) {
      await box.delete(id);
      return null;
    }
    
    return cached['data'] as Map<String, dynamic>;
  }
  
  // Nutrition caching (7 days)
  Future<void> cacheNutrition(String key, Map<String, dynamic> data) async {
    final box = _hive.box(_nutritionBoxName);
    await box.put(key, {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  Future<Map<String, dynamic>?> getNutrition(String key) async {
    final box = _hive.box(_nutritionBoxName);
    final cached = box.get(key);
    
    if (cached == null) return null;
    
    final timestamp = cached['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSince = (now - timestamp) / (1000 * 60 * 60 * 24);
    
    // Cache valid for 7 days
    if (daysSince > 7) {
      await box.delete(key);
      return null;
    }
    
    return cached['data'] as Map<String, dynamic>;
  }
  
  Future<void> clearExpiredCache() async {
    // Clear expired entries
    final recipeBox = _hive.box(_recipeBoxName);
    final nutritionBox = _hive.box(_nutritionBoxName);
    
    for (var key in recipeBox.keys) {
      await getRecipe(key); // Auto-deletes if expired
    }
    
    for (var key in nutritionBox.keys) {
      await getNutrition(key); // Auto-deletes if expired
    }
  }
}

// Hybrid service (Firestore + API)
class HybridRecipeService {
  final ApiCacheService _cache = ApiCacheService();
  
  Future<List<Recipe>> searchRecipes(String query) async {
    // 1. Check cache
    final cached = await _cache.getRecipe('search_$query');
    if (cached != null) {
      return _parseRecipes(cached);
    }
    
    // 2. Check Firestore (custom Turkish recipes)
    final firestoreResults = await _searchFirestore(query);
    if (firestoreResults.isNotEmpty) {
      return firestoreResults;
    }
    
    // 3. Fallback to TheMealDB API
    final apiResults = await _searchTheMealDB(query);
    
    // 4. Cache API results
    await _cache.cacheRecipe('search_$query', {
      'recipes': apiResults.map((r) => r.toJson()).toList(),
    });
    
    // 5. Optionally: Save to Firestore for future
    await _saveToFirestore(apiResults);
    
    return apiResults;
  }
  
  Future<List<Recipe>> _searchFirestore(String query) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('recipes_database')
        .where('titleTR', isGreaterThanOrEqualTo: query)
        .where('titleTR', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(10)
        .get();
    
    return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
  }
  
  Future<List<Recipe>> _searchTheMealDB(String query) async {
    final response = await http.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$query'),
    );
    
    final data = jsonDecode(response.body);
    return _parseRecipes(data);
  }
  
  Future<void> _saveToFirestore(List<Recipe> recipes) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (var recipe in recipes) {
      final docRef = FirebaseFirestore.instance
          .collection('recipes_database')
          .doc(recipe.id);
      batch.set(docRef, recipe.toJson());
    }
    
    await batch.commit();
  }
}
## 1.5.5 Feature Flags Systemdart// lib/services/feature_flag_service.dart
class FeatureFlagService {
  final RemoteConfigService _remoteConfig = RemoteConfigService();
  
  // Local overrides (for testing)
  final Map<String, bool> _localOverrides = {};
  
  bool isEnabled(String featureName) {
    // Check local override first
    if (_localOverrides.containsKey(featureName)) {
      return _localOverrides[featureName]!;
    }
    
    // Check remote config
    return _remoteConfig.isFeatureEnabled(featureName);
  }
  
  void setLocalOverride(String featureName, bool enabled) {
    _localOverrides[featureName] = enabled;
  }
  
  void clearLocalOverrides() {
    _localOverrides.clear();
  }
}

// Feature flags
enum Feature {
  snapAndCook,
  socialFeed,
  referralSystem,
  seasonalThemes,
  advancedSearch,
  weeklyReview,
}

// Usage:
final featureFlags = FeatureFlagService();

if (featureFlags.isEnabled('snap_and_cook')) {
  // Show Snap & Cook feature
}

// Kill switch example: Remote'dan hızlıca kapat
if (featureFlags.isEnabled('social_feed')) {
  // Show social feed
} else {
  // Show placeholder or hide completely
}
## 1.5.6 User Feedback Systemdart// lib/screens/feedback_screen.dart
class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  String _feedbackType = 'bug';
  File? _screenshot;
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geri Bildirim'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Geri bildiriminiz bizim için çok önemli! 💙',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            
            // Feedback type
            DropdownButtonFormField<String>(
              value: _feedbackType,
              decoration: InputDecoration(
                labelText: 'Geri Bildirim Türü',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'bug', child: Text('🐛 Hata Bildirimi')),
                DropdownMenuItem(value: 'feature', child: Text('💡 Özellik İsteği')),
                DropdownMenuItem(value: 'improvement', child: Text('✨ İyileştirme')),
                DropdownMenuItem(value: 'other', child: Text('💬 Diğer')),
              ],
              onChanged: (value) => setState(() => _feedbackType = value!),
            ),
            SizedBox(height: 16),
            
            // Feedback text
            TextFormField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: 'Geri Bildiriminiz',
                hintText: 'Lütfen detaylı bilgi verin...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen geri bildiriminizi yazın';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // Screenshot
            if (_screenshot != null)
              Stack(
                children: [
                  Image.file(_screenshot!, height: 200),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _screenshot = null),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _captureScreenshot,
                icon: Icon(Icons.screenshot),
                label: Text('Ekran Görüntüsü Ekle (Opsiyonel)'),
              ),
            
            SizedBox(height: 24),
            
            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              child: _isSubmitting
                  ? CircularProgressIndicator()
                  : Text('Gönder'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _captureScreenshot() async {
    // Use screenshot package
    final imageFile = await screenshotController.capture();
    if (imageFile != null) {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/screenshot.png').create();
      await file.writeAsBytes(imageFile);
      setState(() => _screenshot = file);
    }
  }
  
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final feedbackId = FirebaseFirestore.instance
          .collection('feedback')
          .doc()
          .id;
      
      String? screenshotUrl;
      if (_screenshot != null) {
        // Upload screenshot to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('feedback_screenshots/$feedbackId.png');
        await storageRef.putFile(_screenshot!);
        screenshotUrl = await storageRef.getDownloadURL();
      }
      
      // Save feedback to Firestore
      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(feedbackId)
          .set({
        'userId': userId,
        'type': _feedbackType,
        'text': _feedbackController.text,
        'screenshotUrl': screenshotUrl,
        'deviceInfo': await _getDeviceInfo(),
        'appVersion': '2.0.0',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geri bildiriminiz alındı, teşekkürler! 🙏')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
  
  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'Android',
        'model': androidInfo.model,
        'version': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'platform': 'iOS',
        'model': iosInfo.model,
        'version': iosInfo.systemVersion,
      };
    }
    return {};
  }
}
## Firestore'da feedback moderasyonu:
feedback/
  ├── {feedbackId}
      ├── userId: String
      ├── type: 'bug' | 'feature' | 'improvement' | 'other'
      ├── text: String
      ├── screenshotUrl: String?
      ├── deviceInfo: Map
      ├── appVersion: String
      ├── status: 'pending' | 'reviewed' | 'resolved'
      ├── adminNotes: String?
      ├── createdAt: Timestamp
      └── updatedAt: Timestamp?
	  
### Bug Report Floating Button

```dart
// lib/widgets/feedback_floating_button.dart
class FeedbackFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeedbackScreen()),
        );
      },
      child: Icon(Icons.bug_report),
      backgroundColor: Color(0xFFFF6347),
      tooltip: 'Hata Bildir',
      mini: true,
    );
  }
}

// Kullanım: HomeScreen, ProfileScreen gibi ana ekranlarda
Scaffold(
  body: ...,
  floatingActionButton: Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      FeedbackFloatingButton(),
      SizedBox(height: 8),
      // Diğer FAB'ler
    ],
  ),
)
```

### Admin Panel for Feedback Management

```dart
// lib/screens/admin/feedback_management_screen.dart
class FeedbackManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Yönetimi'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz feedback yok'));
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return FeedbackCard(
                feedbackId: doc.id,
                data: data,
              );
            },
          );
        },
      ),
    );
  }
}

class FeedbackCard extends StatelessWidget {
  final String feedbackId;
  final Map<String, dynamic> data;
  
  const FeedbackCard({
    required this.feedbackId,
    required this.data,
  });
  
  @override
  Widget build(BuildContext context) {
    final type = data['type'];
    final status = data['status'] ?? 'pending';
    
    return Card(
      margin: EdgeInsets.all(8),
      child: ExpansionTile(
        leading: _getTypeIcon(type),
        title: Text(data['title']),
        subtitle: Text(
          'Status: $status | ${_formatDate(data['createdAt'])}',
        ),
        trailing: _getStatusChip(status),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Açıklama:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(data['description']),
                
                if (data['screenshotUrl'] != null) ...[
                  SizedBox(height: 16),
                  Text(
                    'Ekran Görüntüsü:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Image.network(
                    data['screenshotUrl'],
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ],
                
                SizedBox(height: 16),
                Text(
                  'Cihaz Bilgisi:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(data['deviceInfo'].toString()),
                
                SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _updateStatus(feedbackId, 'in_progress'),
                      child: Text('İşlemde'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _updateStatus(feedbackId, 'resolved'),
                      child: Text('Çözüldü'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _updateStatus(feedbackId, 'closed'),
                      child: Text('Kapat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Icon _getTypeIcon(String type) {
    switch (type) {
      case 'bug':
        return Icon(Icons.bug_report, color: Colors.red);
      case 'feature':
        return Icon(Icons.lightbulb, color: Colors.amber);
      case 'improvement':
        return Icon(Icons.star, color: Colors.blue);
      default:
        return Icon(Icons.message, color: Colors.grey);
    }
  }
  
  Widget _getStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'resolved':
        color = Colors.green;
        break;
      case 'closed':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }
    
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }
  
  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Future<void> _updateStatus(String feedbackId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('feedback')
        .doc(feedbackId)
        .update({'status': newStatus});
  }
}
```	  
	  
## PHASE 2: AI & Engagement Features Hedef: Kullanıcı bağlılığını artır ve AI özellikleriyle diferansiyasyon sağla
## 2.1 Snap & Cook AI (Malzeme Tanıma + Tarif Önerisi) Dosya Yapısı:
lib/screens/ai_kitchen_camera.dart
lib/services/ingredient_detection_service.dart
lib/models/detected_ingredient.dart

## Akış:

Kullanıcı mutfak/buzdolabı fotoğrafı çeker
google_mlkit_image_labeling ile malzemeler tanınır
Tanımlanan malzemeler liste olarak gösterilir
Kullanıcı düzenleyebilir (ekle/çıkar)
API'ye gönderilir ve eşleşen tarifler bulunur
Implementation:dart// lib/models/detected_ingredient.dart
class DetectedIngredient {
  final String name;
  final double confidence;
  bool isSelected;
  
  DetectedIngredient({
    required this.name,
    required this.confidence,
    this.isSelected = true,
  });
}

// lib/services/ingredient_detection_service.dart
class IngredientDetectionService {
  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );
  
  // Ingredient mapping (English labels → Turkish ingredients)
  final Map<String, String> _ingredientMap = {
    'tomato': 'domates',
    'potato': 'patates',
    'onion': 'soğan',
    'garlic': 'sarımsak',
    'chicken': 'tavuk',
    'beef': 'sığır eti',
    'fish': 'balık',
    'egg': 'yumurta',
    'milk': 'süt',
    'cheese': 'peynir',
    'bread': 'ekmek',
    'rice': 'pirinç',
    'pasta': 'makarna',
    'apple': 'elma',
    'banana': 'muz',
    'carrot': 'havuç',
    'pepper': 'biber',
    'mushroom': 'mantar',
    'spinach': 'ıspanak',
    'cucumber': 'salatalık',
    // ... add more mappings
  };
  
  Future<List<DetectedIngredient>> detectIngredients(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final labels = await _labeler.processImage(inputImage);
    
    final ingredients = <DetectedIngredient>[];
    
    for (var label in labels) {
      final labelLower = label.label.toLowerCase();
      
      // Check if label matches an ingredient
      for (var entry in _ingredientMap.entries) {
        if (labelLower.contains(entry.key)) {
          ingredients.add(DetectedIngredient(
            name: entry.value,
            confidence: label.confidence,
          ));
          break;
        }
      }
    }
    
    // Remove duplicates and sort by confidence
    final uniqueIngredients = ingredients.toSet().toList();
    uniqueIngredients.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return uniqueIngredients;
  }
  
  Future<List<Recipe>> findRecipesByIngredients(
    List<String> ingredients,
  ) async {
    // Search in Firestore first
    final firestoreRecipes = await _searchFirestore(ingredients);
    if (firestoreRecipes.isNotEmpty) {
      return firestoreRecipes;
    }
    
    // Fallback to API (if available)
    return await _searchAPI(ingredients);
  }
  
  Future<List<Recipe>> _searchFirestore(List<String> ingredients) async {
    // Query recipes that contain ANY of the ingredients
    final snapshot = await FirebaseFirestore.instance
        .collection('recipes_database')
        .where('ingredients', arrayContainsAny: ingredients)
        .limit(20)
        .get();
    
    final recipes = snapshot.docs
        .map((doc) => Recipe.fromFirestore(doc))
        .toList();
    
    // Score recipes based on ingredient match count
    recipes.sort((a, b) {
      final aMatchCount = _countMatches(a.ingredients, ingredients);
      final bMatchCount = _countMatches(b.ingredients, ingredients);
      return bMatchCount.compareTo(aMatchCount);
    });
    
    return recipes;
  }
  
  int _countMatches(List<String> recipeIngredients, List<String> userIngredients) {
    int count = 0;
    for (var userIngredient in userIngredients) {
      for (var recipeIngredient in recipeIngredients) {
        if (recipeIngredient.toLowerCase().contains(userIngredient.toLowerCase())) {
          count++;
          break;
        }
      }
    }
    return count;
  }
  
  Future<List<Recipe>> _searchAPI(List<String> ingredients) async {
    // TheMealDB doesn't support ingredient-based search
    // Alternative: Spoonacular API (if using)
    // OR: Use OpenAI to generate recipe ideas
    return [];
  }
  
  void dispose() {
    _labeler.close();
  }
}

// lib/screens/ai_kitchen_camera.dart
class AIKitchenCameraScreen extends StatefulWidget {
  @override
  _AIKitchenCameraScreenState createState() => _AIKitchenCameraScreenState();
}

class _AIKitchenCameraScreenState extends State<AIKitchenCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final IngredientDetectionService _detectionService = IngredientDetectionService();
  
  List<DetectedIngredient> _detectedIngredients = [];
  List<Recipe> _suggestedRecipes = [];
  bool _isDetecting = false;
  bool _isFindingRecipes = false;
  File? _image;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snap & Cook AI 🍳'),
        backgroundColor: Color(0xFFFF6347),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _captureImage,
        label: Text('Fotoğraf Çek'),
        icon: Icon(Icons.camera_alt),
        backgroundColor: Color(0xFFFF6347),
      ),
    );
  }
  
  Widget _buildBody() {
    if (_image == null) {
      return _buildEmptyState();
    }
    
    if (_isDetecting) {
      return _buildLoadingState();
    }
    
    if (_detectedIngredients.isEmpty) {
      return _buildNoIngredientsState();
    }
    
    return _buildDetectedIngredientsState();
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 120,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Mutfağını Fotoğrafla',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Buzdolabı veya mutfağındaki malzemeleri çek, sana tarif önerelim!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/scanning.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 24),
          Text(
            'Malzemeler Taranıyor...',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoIngredientsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Malzeme Bulunamadı',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 8),
          Text(
            'Lütfen daha net bir fotoğraf çekin',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _captureImage,
            child: Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetectedIngredientsState() {
    return Column(
      children: [
        // Image preview
        Container(
          height: 200,
          width: double.infinity,
          child: Image.file(_image!, fit: BoxFit.cover),
        ),
        
        // Detected ingredients
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text(
                'Tespit Edilen Malzemeler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Kullanmak istemediklerinizi kaldırabilirsiniz',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _detectedIngredients.map((ingredient) {
                  return FilterChip(
                    label: Text('${ingredient.name} (${(ingredient.confidence * 100).toInt()}%)'),
                    selected: ingredient.isSelected,
                    onSelected: (selected) {
                      setState(() {
                        ingredient.isSelected = selected;
                      });
                    },
                    selectedColor: Color(0xFFFF6347).withOpacity(0.3),
                    checkmarkColor: Color(0xFFFF6347),
                  );
                }).toList(),
              ),
              
              SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isFindingRecipes ? null : _findRecipes,
                child: _isFindingRecipes
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Tarif Bul 🍽️'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6347),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              
              if (_suggestedRecipes.isNotEmpty) ...[
                SizedBox(height: 32),
                Text(
                  'Önerilen Tarifler (${_suggestedRecipes.length})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                
                ..._suggestedRecipes.map((recipe) => RecipeCard(recipe: recipe)),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Future<void> _captureImage() async {
    // Check premium status for free users
    final subscriptionProvider = context.read<SubscriptionProvider>();
    
    if (!subscriptionProvider.isPremium) {
      // Check daily limit
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastScanDate = prefs.getString('last_ai_scan_date') ?? '';
      final scanCount = prefs.getInt('ai_scan_count') ?? 0;
      
      if (lastScanDate == today && scanCount >= 1) {
        // Show premium paywall
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Günlük Limit Aşıldı'),
            content: Text('Sınırsız tarama için Premium\'a geçin!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PremiumScreen()),
                  );
                },
                child: Text('Premium Al'),
              ),
            ],
          ),
        );
        return;
      }
    }
    
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        _isDetecting = true;
        _detectedIngredients = [];
        _suggestedRecipes = [];
      });
      
      // Detect ingredients
      final ingredients = await _detectionService.detectIngredients(photo.path);
      
      setState(() {
        _isDetecting = false;
        _detectedIngredients = ingredients;
      });
      
      // Update scan count
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastScanDate = prefs.getString('last_ai_scan_date') ?? '';
      
      if (lastScanDate != today) {
        await prefs.setString('last_ai_scan_date', today);
        await prefs.setInt('ai_scan_count', 1);
      } else {
        final scanCount = prefs.getInt('ai_scan_count') ?? 0;
        await prefs.setInt('ai_scan_count', scanCount + 1);
      }
      
      // Log analytics
      await AnalyticsService().logAICameraUsed();
    }
  }
  
  Future<void> _findRecipes() async {
    setState(() => _isFindingRecipes = true);
    
    final selectedIngredients = _detectedIngredients
        .where((i) => i.isSelected)
        .map((i) => i.name)
        .toList();
    
    final recipes = await _detectionService.findRecipesByIngredients(
      selectedIngredients,
    );
    
    setState(() {
      _isFindingRecipes = false;
      _suggestedRecipes = recipes;
    });
    
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bu malzemelerle tarif bulunamadı 😕')),
      );
    }
  }
  
  @override
  void dispose() {
    _detectionService.dispose();
    super.dispose();
  }
}Monetization:

 Free: 1 tarama/gün (SharedPreferences counter)
 Premium: Sınırsız tarama
 Limit aşıldığında premium paywall göster
UI Elements:

 "Snap & Cook" butonu (HomeScreen'de büyük CTA)
 Scanning animasyonu (Lottie - scanning.json)
 Detected ingredients (editable chips)
 "Find Recipes" butonu
 Recipe suggestions list
## 2.2 Gamification SystemDosya Yapısı:
lib/services/gamification_service.dart
lib/models/badge.dart
lib/models/user_rank.dart
lib/screens/leaderboard_screen.dart
lib/widgets/xp_gain_animation.dartXP Sistemi:AksiyonXPPremium BonusTarif görüntüle+1+2Favorilere ekle+5+7Kalori hesapla+3+5Yoruma cevap ver+3+5Tarifi pişir (checkbox)+10+15Alışveriş listesi oluştur+2+4AI Camera kullan+5+10Haftalık challenge tamamla+50+75Seviye Sistemi:SeviyeGerekli XPBaşlık10Newbie Chef 👨‍🍳250Home Cook 🏠3150Kitchen Pro 🔪4350Sous Chef 👨‍🍳5700Master Chef ⭐61200Gordon Ramsay 🔥72000Iron Chef 🏆Rozetler:dart// lib/models/badge.dart
enum BadgeType {
  newbie,       // İlk 5 tarif
  foodie,       // 50 tarif görüntüle
  collector,    // 20 favori
  analyzer,     // 50 kalori hesaplama
  social,       // 20 yorum yap
  streaker,     // 7 gün üst üste kullan
  premium,      // Premium üye
  achiever,     // Tüm rozetleri topla
}

class Badge {
  final BadgeType type;
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int requiredCount;
  final int xpReward;
  
  const Badge({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.requiredCount,
    required this.xpReward,
  });
  
  static const List<Badge> all = [
    Badge(
      type: BadgeType.newbie,
      id: 'newbie_chef',
      name: 'Newbie Chef',
      description: 'İlk 5 tarifini görüntüle',
      iconPath: 'assets/badges/newbie.png',
      requiredCount: 5,
      xpReward: 10,
    ),
    Badge(
      type: BadgeType.foodie,
      id: 'foodie',
      name: 'Foodie',
      description: '50 tarif görüntüle',
      iconPath: 'assets/badges/foodie.png',
      requiredCount: 50,
      xpReward: 50,
    ),
    Badge(
      type: BadgeType.collector,
      id: 'collector',
      name: 'Collector',
      description: '20 tarifi favorilere ekle',
      iconPath: 'assets/badges/collector.png',
      requiredCount: 20,
      xpReward: 30,
    ),
    Badge(
      type: BadgeType.analyzer,
      id: 'calorie_warrior',
      name: 'Calorie Warrior',
      description: '50 kalori hesaplama yap',
      iconPath: 'assets/badges/analyzer.png',
      requiredCount: 50,
      xpReward: 40,
    ),
    Badge(
      type: BadgeType.social,
      id: 'social_butterfly',
      name: 'Social Butterfly',
      description: '20 yorum yap',
      iconPath: 'assets/badges/social.png',
      requiredCount: 20,
      xpReward: 25,
    ),
    Badge(
      type: BadgeType.streaker,
      id: 'consistency_king',
      name: 'Consistency King',
      description: '7 gün üst üste kullan',
      iconPath: 'assets/badges/streaker.png',
      requiredCount: 7,
      xpReward: 100,
    ),
    Badge(
      type: BadgeType.premium,
      id: 'premium_member',
      name: 'Premium Member',
      description: 'Premium üyeliğe geç',
      iconPath: 'assets/badges/premium.png',
      requiredCount: 1,
      xpReward: 200,
    ),
  ];
}

// lib/services/gamification_service.dart
class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Stream<UserStats> watchUserStats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(UserStats.empty());
    
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => UserStats.fromFirestore(doc));
  }
  
  Future<void> addXP(int xp, {String? reason}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    final userRef = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final currentXP = userDoc.data()?['totalXP'] ?? 0;
      final newXP = currentXP + xp;
      
      transaction.update(userRef, {
        'totalXP': newXP,
        'lastXPGain': {
          'amount': xp,
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
      
      // Check level up
      final currentLevel = _calculateLevel(currentXP);
      final newLevel = _calculateLevel(newXP);
      
      if (newLevel > currentLevel) {
        transaction.update(userRef, {
          'currentLevel': newLevel,
        });
        
        // Trigger level up notification
        await _sendLevelUpNotification(newLevel);
      }
      
      // Check badge unlocks
      await _checkBadgeUnlocks(userId);
    });
    
    // Log analytics
    await AnalyticsService().logEvent('xp_gained', {
      'amount': xp,
      'reason': reason,
    });
  }
  
  int _calculateLevel(int xp) {
    if (xp < 50) return 1;
    if (xp < 150) return 2;
    if (xp < 350) return 3;
    if (xp < 700) return 4;
    if (xp < 1200) return 5;
    if (xp < 2000) return 6;
    return 7;
  }
  
  Future<void> _checkBadgeUnlocks(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data()!;
    
    final unlockedBadges = List<String>.from(userData['badges'] ?? []);
    
    for (var badge in Badge.all) {
      if (unlockedBadges.contains(badge.id)) continue;
      
      bool shouldUnlock = false;
      
      switch (badge.type) {
        case BadgeType.newbie:
          shouldUnlock = (userData['totalRecipesViewed'] ?? 0) >= badge.requiredCount;
          break;
        case BadgeType.foodie:
          shouldUnlock = (userData['totalRecipesViewed'] ?? 0) >= badge.requiredCount;
          break;
        case BadgeType.collector:
          shouldUnlock = (userData['totalFavorites'] ?? 0) >= badge.requiredCount;
          break;
        case BadgeType.analyzer:
          shouldUnlock = (userData['totalAnalyses'] ?? 0) >= badge.requiredCount;
          break;
        case BadgeType.social:
          shouldUnlock = (userData['totalComments'] ?? 0) >= badge.requiredCount;
          break;
        case BadgeType.streaker:
          shouldUnlock = await _checkStreakCount(userId) >= badge.requiredCount;
          break;
        case BadgeType.premium:
          shouldUnlock = userData['isPremium'] == true;
          break;
        default:
          break;
      }
      
      if (shouldUnlock) {
        await _unlockBadge(userId, badge);
      }
    }
  }
  Future<int> _checkStreakCount(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get last 30 days of activity
    final activitySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_activity')
        .orderBy('date', descending: true)
        .limit(30)
        .get();
    
    int streakCount = 0;
    DateTime checkDate = today;
    
    for (var doc in activitySnapshot.docs) {
      final activityDate = (doc.data()['date'] as Timestamp).toDate();
      final activityDay = DateTime(
        activityDate.year,
        activityDate.month,
        activityDate.day,
      );
      
      if (activityDay == checkDate) {
        streakCount++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streakCount;
  }
  
  Future<void> _unlockBadge(String userId, Badge badge) async {
    await _firestore.collection('users').doc(userId).update({
      'badges': FieldValue.arrayUnion([badge.id]),
      'totalXP': FieldValue.increment(badge.xpReward),
    });
    
    // Send notification
    await NotificationService().showLocalNotification(
      title: '🏆 Yeni Rozet Kazandın!',
      body: '${badge.name} - ${badge.description}',
      payload: '/badges',
    );
    
    // Log analytics
    await AnalyticsService().logEvent('badge_unlocked', {
      'badge_id': badge.id,
      'badge_name': badge.name,
    });
  }
  
  Future<void> _sendLevelUpNotification(int level) async {
    final levelNames = {
      1: 'Newbie Chef 👨‍🍳',
      2: 'Home Cook 🏠',
      3: 'Kitchen Pro 🔪',
      4: 'Sous Chef 👨‍🍳',
      5: 'Master Chef ⭐',
      6: 'Gordon Ramsay 🔥',
      7: 'Iron Chef 🏆',
    };
    
    await NotificationService().showLocalNotification(
      title: '🎉 Seviye Atladın!',
      body: 'Artık ${levelNames[level]}\'sın!',
      payload: '/profile',
    );
  }
  
  // Track daily activity
  Future<void> trackDailyActivity() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayString = today.toIso8601String().split('T')[0];
    
    final activityRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_activity')
        .doc(todayString);
    
    await activityRef.set({
      'date': Timestamp.fromDate(today),
      'hasActivity': true,
    }, SetOptions(merge: true));
  }
  
  // Action-specific XP rewards
  Future<void> onRecipeViewed(String recipeId, bool isPremium) async {
    final xp = isPremium ? 2 : 1;
    await addXP(xp, reason: 'recipe_viewed');
    
    // Increment counter
    await _incrementCounter('totalRecipesViewed');
    
    // Track daily activity
    await trackDailyActivity();
  }
  
  Future<void> onFavoriteAdded(String recipeId, bool isPremium) async {
    final xp = isPremium ? 7 : 5;
    await addXP(xp, reason: 'favorite_added');
    await _incrementCounter('totalFavorites');
    await trackDailyActivity();
  }
  
  Future<void> onCalorieCalculated(int calories, bool isPremium) async {
    final xp = isPremium ? 5 : 3;
    await addXP(xp, reason: 'calorie_calculated');
    await _incrementCounter('totalAnalyses');
    await trackDailyActivity();
  }
  
  Future<void> onCommentPosted(String recipeId, bool isPremium) async {
    final xp = isPremium ? 5 : 3;
    await addXP(xp, reason: 'comment_posted');
    await _incrementCounter('totalComments');
    await trackDailyActivity();
  }
  
  Future<void> onRecipeCooked(String recipeId, bool isPremium) async {
    final xp = isPremium ? 15 : 10;
    await addXP(xp, reason: 'recipe_cooked');
    await _incrementCounter('totalRecipesCooked');
    await trackDailyActivity();
  }
  
  Future<void> onShoppingListCreated(bool isPremium) async {
    final xp = isPremium ? 4 : 2;
    await addXP(xp, reason: 'shopping_list_created');
    await trackDailyActivity();
  }
  
  Future<void> onAICameraUsed(bool isPremium) async {
    final xp = isPremium ? 10 : 5;
    await addXP(xp, reason: 'ai_camera_used');
    await trackDailyActivity();
  }
  
  Future<void> _incrementCounter(String field) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    await _firestore.collection('users').doc(userId).update({
      field: FieldValue.increment(1),
    });
  }
}

// lib/models/user_stats.dart
class UserStats {
  final int totalXP;
  final int currentLevel;
  final List<String> badges;
  final int totalRecipesViewed;
  final int totalFavorites;
  final int totalAnalyses;
  final int totalComments;
  final int totalRecipesCooked;
  final int streakDays;
  
  UserStats({
    required this.totalXP,
    required this.currentLevel,
    required this.badges,
    required this.totalRecipesViewed,
    required this.totalFavorites,
    required this.totalAnalyses,
    required this.totalComments,
    required this.totalRecipesCooked,
    required this.streakDays,
  });
  
  factory UserStats.empty() {
    return UserStats(
      totalXP: 0,
      currentLevel: 1,
      badges: [],
      totalRecipesViewed: 0,
      totalFavorites: 0,
      totalAnalyses: 0,
      totalComments: 0,
      totalRecipesCooked: 0,
      streakDays: 0,
    );
  }
  
  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStats(
      totalXP: data['totalXP'] ?? 0,
      currentLevel: data['currentLevel'] ?? 1,
      badges: List<String>.from(data['badges'] ?? []),
      totalRecipesViewed: data['totalRecipesViewed'] ?? 0,
      totalFavorites: data['totalFavorites'] ?? 0,
      totalAnalyses: data['totalAnalyses'] ?? 0,
      totalComments: data['totalComments'] ?? 0,
      totalRecipesCooked: data['totalRecipesCooked'] ?? 0,
      streakDays: data['streakDays'] ?? 0,
    );
  }
  
  int get nextLevelXP {
    const levelThresholds = [0, 50, 150, 350, 700, 1200, 2000];
    if (currentLevel >= levelThresholds.length) {
      return levelThresholds.last;
    }
    return levelThresholds[currentLevel];
  }
  
  double get levelProgress {
    final currentThreshold = currentLevel > 1 
        ? [0, 50, 150, 350, 700, 1200, 2000][currentLevel - 1]
        : 0;
    final nextThreshold = nextLevelXP;
    final progress = (totalXP - currentThreshold) / (nextThreshold - currentThreshold);
    return progress.clamp(0.0, 1.0);
  }
  
  String get rankTitle {
    const ranks = {
      1: 'Newbie Chef 👨‍🍳',
      2: 'Home Cook 🏠',
      3: 'Kitchen Pro 🔪',
      4: 'Sous Chef 👨‍🍳',
      5: 'Master Chef ⭐',
      6: 'Gordon Ramsay 🔥',
      7: 'Iron Chef 🏆',
    };
    return ranks[currentLevel] ?? 'Unknown';
  }
}

// lib/widgets/xp_gain_animation.dart
class XPGainAnimation extends StatefulWidget {
  final int xp;
  final VoidCallback? onComplete;
  
  const XPGainAnimation({
    required this.xp,
    this.onComplete,
  });
  
  @override
  _XPGainAnimationState createState() => _XPGainAnimationState();
}

class _XPGainAnimationState extends State<XPGainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -2),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF6347).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '+${widget.xp} XP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// lib/screens/leaderboard_screen.dart
class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sıralama 🏆'),
        backgroundColor: Color(0xFFFF6347),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Günlük'),
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboard('daily'),
          _buildLeaderboard('weekly'),
          _buildLeaderboard('monthly'),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboard(String period) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('totalXP', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Henüz veri yok'));
        }
        
        final users = snapshot.data!.docs;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        
        return Column(
          children: [
            // Top 3 podium
            _buildPodium(users),
            
            // Rest of the list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: users.length - 3,
                itemBuilder: (context, index) {
                  final rank = index + 4;
                  final userDoc = users[index + 3];
                  final userData = userDoc.data() as Map<String, dynamic>;
                  final isCurrentUser = userDoc.id == currentUserId;
                  
                  return _buildLeaderboardItem(
                    rank: rank,
                    userName: userData['displayName'] ?? 'Anonymous',
                    xp: userData['totalXP'] ?? 0,
                    level: userData['currentLevel'] ?? 1,
                    avatarUrl: userData['avatarUrl'],
                    isCurrentUser: isCurrentUser,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildPodium(List<QueryDocumentSnapshot> users) {
    if (users.length < 3) return SizedBox.shrink();
    
    final first = users[0].data() as Map<String, dynamic>;
    final second = users[1].data() as Map<String, dynamic>;
    final third = users[2].data() as Map<String, dynamic>;
    
    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumPlace(
            rank: 2,
            userName: second['displayName'] ?? 'Anonymous',
            xp: second['totalXP'] ?? 0,
            height: 120,
            color: Colors.grey[400]!,
          ),
          SizedBox(width: 8),
          _buildPodiumPlace(
            rank: 1,
            userName: first['displayName'] ?? 'Anonymous',
            xp: first['totalXP'] ?? 0,
            height: 150,
            color: Color(0xFFFFD700), // Gold
          ),
          SizedBox(width: 8),
          _buildPodiumPlace(
            rank: 3,
            userName: third['displayName'] ?? 'Anonymous',
            xp: third['totalXP'] ?? 0,
            height: 100,
            color: Color(0xFFCD7F32), // Bronze
          ),
        ],
      ),
    );
  }
  
  Widget _buildPodiumPlace({
    required int rank,
    required String userName,
    required int xp,
    required double height,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Text(
            '#$rank',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          userName,
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$xp XP',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        SizedBox(height: 8),
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLeaderboardItem({
    required int rank,
    required String userName,
    required int xp,
    required int level,
    String? avatarUrl,
    required bool isCurrentUser,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? Color(0xFFFF6347).withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? Color(0xFFFF6347) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Color(0xFFFF6347) : Colors.grey[800],
              ),
            ),
          ),
          
          // Avatar
          CircleAvatar(
            radius: 25,
            backgroundImage: avatarUrl != null 
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null 
                ? Icon(Icons.person)
                : null,
          ),
          
          SizedBox(width: 12),
          
          // Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Level $level',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6347),
                ),
              ),
              Text(
                'XP',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
```

**Firestore Yapısı:**
```
users/{uid}/
  ├── totalXP: int
  ├── currentLevel: int
  ├── badges: Array<String>
  ├── totalRecipesViewed: int
  ├── totalFavorites: int
  ├── totalAnalyses: int
  ├── totalComments: int
  ├── totalRecipesCooked: int
  ├── streakDays: int
  ├── lastActionDate: Timestamp
  └── daily_activity/
      └── {YYYY-MM-DD}
          ├── date: Timestamp
          └── hasActivity: bool
```

**UI Integration:**

```dart
// ProfileScreen'de gamification widget'ları
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gamificationService = GamificationService();
    
    return StreamBuilder<UserStats>(
      stream: gamificationService.watchUserStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final stats = snapshot.data!;
        
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Level & XP Card
            _buildLevelCard(stats),
            SizedBox(height: 16),
            
            // Badges Section
            _buildBadgesSection(stats),
            SizedBox(height: 16),
            
            // Stats Section
            _buildStatsSection(stats),
            SizedBox(height: 16),
            
            // Leaderboard Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LeaderboardScreen()),
                );
              },
              child: Text('Sıralamayı Gör 🏆'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildLevelCard(UserStats stats) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            stats.rankTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Level ${stats.currentLevel}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          
          // Progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${stats.totalXP} XP',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    '${stats.nextLevelXP} XP',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: stats.levelProgress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 10,
                ),
              ),
            ],
          ),
          
          if (stats.streakDays > 0) ...[
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  '${stats.streakDays} gün streak!',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildBadgesSection(UserStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rozetler (${stats.badges.length}/${Badge.all.length})',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: Badge.all.length,
          itemBuilder: (context, index) {
            final badge = Badge.all[index];
            final isUnlocked = stats.badges.contains(badge.id);
            
            return GestureDetector(
              onTap: () => _showBadgeDialog(context, badge, isUnlocked),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUnlocked 
                          ? Color(0xFFFF6347).withOpacity(0.2)
                          : Colors.grey[300],
                    ),
                    child: isUnlocked
                        ? Image.asset(badge.iconPath)
                        : Icon(Icons.lock, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    badge.name.split(' ')[0],
                    style: TextStyle(
                      fontSize: 10,
                      color: isUnlocked ? Colors.black : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildStatsSection(UserStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İstatistikler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        _buildStatItem(
          icon: Icons.restaurant_menu,
          label: 'Görüntülenen Tarifler',
          value: stats.totalRecipesViewed.toString(),
        ),
        _buildStatItem(
          icon: Icons.favorite,
          label: 'Favori Tarifler',
          value: stats.totalFavorites.toString(),
        ),
        _buildStatItem(
          icon: Icons.analytics,
          label: 'Kalori Hesaplamaları',
          value: stats.totalAnalyses.toString(),
        ),
        _buildStatItem(
          icon: Icons.comment,
          label: 'Yorumlar',
          value: stats.totalComments.toString(),
        ),
        _buildStatItem(
          icon: Icons.check_circle,
          label: 'Pişirilen Tarifler',
          value: stats.totalRecipesCooked.toString(),
        ),
      ],
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFFF6347), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6347),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showBadgeDialog(BuildContext context, Badge badge, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isUnlocked
                ? Image.asset(badge.iconPath, width: 80, height: 80)
                : Icon(Icons.lock, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (!isUnlocked) ...[
              SizedBox(height: 16),
              Text(
                'Bu rozeti kazanmak için:\n${badge.requiredCount} ${_getActionName(badge.type)}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }
  
  String _getActionName(BadgeType type) {
    switch (type) {
      case BadgeType.newbie:
      case BadgeType.foodie:
        return 'tarif görüntüle';
      case BadgeType.collector:
        return 'tarifi favorilere ekle';
      case BadgeType.analyzer:
        return 'kalori hesaplama yap';
      case BadgeType.social:
        return 'yorum yap';
      case BadgeType.streaker:
        return 'gün üst üste kullan';
      case BadgeType.premium:
        return 'Premium üye ol';
      default:
        return '';
    }
  }
}
```

**2.3 Smart Shopping List**

**Dosya Yapısı:**
```
lib/screens/shopping_list_screen.dart
lib/models/shopping_item.dart
lib/providers/shopping_list_provider.dart
lib/services/shopping_list_service.dart
```

**Implementation:**

```dart
// lib/models/shopping_item.dart
enum ShoppingCategory {
  produce,
  dairy,
  meat,
  pantry,
  frozen,
  bakery,
  other,
}

class ShoppingItem {
  final String id;
  final String name;
  final String quantity;
  final ShoppingCategory category;
  final String? recipeId;
  final String? recipeName;
  final bool isChecked;
  final DateTime addedAt;
  
  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.recipeId,
    this.recipeName,
    this.isChecked = false,
    required this.addedAt,
  });
  
  ShoppingItem copyWith({
    String? id,
    String? name,
    String? quantity,
    ShoppingCategory? category,
    String? recipeId,
    String? recipeName,
    bool? isChecked,
    DateTime? addedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      isChecked: isChecked ?? this.isChecked,
      addedAt: addedAt ?? this.addedAt,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category.toString().split('.').last,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'isChecked': isChecked,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
  
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      category: ShoppingCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => ShoppingCategory.other,
      ),
      recipeId: json['recipeId'],
      recipeName: json['recipeName'],
      isChecked: json['isChecked'] ?? false,
      addedAt: (json['addedAt'] as Timestamp).toDate(),
    );
  }
}

// lib/services/shopping_list_service.dart
class ShoppingListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Category detection algorithm
  final Map<String, ShoppingCategory> _categoryKeywords = {
    // Produce
    'domates': ShoppingCategory.produce,
    'salatalık': ShoppingCategory.produce,
    'biber': ShoppingCategory.produce,
    'soğan': ShoppingCategory.produce,
    'sarımsak': ShoppingCategory.produce,
    'patates': ShoppingCategory.produce,
    'havuç': ShoppingCategory.produce,
    'marul': ShoppingCategory.produce,
    'elma': ShoppingCategory.produce,
    'muz': ShoppingCategory.produce,
    
    // Dairy
    'süt': ShoppingCategory.dairy,
    'yoğurt': ShoppingCategory.dairy,
    'peynir': ShoppingCategory.dairy,
    'tereyağı': ShoppingCategory.dairy,
    'krema': ShoppingCategory.dairy,
    
    // Meat
    'tavuk': ShoppingCategory.meat,
    'et': ShoppingCategory.meat,
    'balık': ShoppingCategory.meat,
    'köfte': ShoppingCategory.meat,
    'sosis': ShoppingCategory.meat,
    
    // Pantry
    'un': ShoppingCategory.pantry,
    'pirinç': ShoppingCategory.pantry,
    'makarna': ShoppingCategory.pantry,
    'şeker': ShoppingCategory.pantry,
    'tuz': ShoppingCategory.pantry,
    'yağ': ShoppingCategory.pantry,
    'baharat': ShoppingCategory.pantry,
    
    // Frozen
    'dondurma': ShoppingCategory.frozen,
    'donmuş': ShoppingCategory.frozen,
    
    // Bakery
    'ekmek': ShoppingCategory.bakery,
    'poğaça': ShoppingCategory.bakery,
    'simit': ShoppingCategory.bakery,
  };
  
  ShoppingCategory detectCategory(String itemName) {
    final lowerName = itemName.toLowerCase();
    
    for (var entry in _categoryKeywords.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return ShoppingCategory.other;
  }
  
  String _getUserShoppingListPath() {
    final userId = _auth.currentUser?.uid ?? 'anonymous';
    return 'shopping_lists/$userId/items';
  }
  
  Stream<List<ShoppingItem>> watchShoppingList() {
    return _firestore
        .collection(_getUserShoppingListPath())
        .orderBy('addedAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShoppingItem.fromJson(doc.data()))
          .toList();
    });
  }
  
  Future<void> addItem({
    required String name,
    required String quantity,
    String? recipeId,
    String? recipeName,
  }) async {
    final category = detectCategory(name);
    
    final item = ShoppingItem(
      id: _firestore.collection(_getUserShoppingListPath()).doc().id,
      name: name,
      quantity: quantity,
      category: category,
      recipeId: recipeId,
      recipeName: recipeName,
      addedAt: DateTime.now(),
    );
    
    await _firestore
        .collection(_getUserShoppingListPath())
        .doc(item.id)
        .set(item.toJson());
  }
  
  Future<void> addItemsFromRecipe(Recipe recipe) async {
    final batch = _firestore.batch();
    
    for (var ingredient in recipe.ingredients) {
      final category = detectCategory(ingredient.name);
      
      final item = ShoppingItem(
        id: _firestore.collection(_getUserShoppingListPath()).doc().id,
        name: ingredient.name,
        quantity: ingredient.quantity ?? '1 adet',
        category: category,
        recipeId: recipe.id,
        recipeName: recipe.title,
        addedAt: DateTime.now(),
      );
      
      final docRef = _firestore
          .collection(_getUserShoppingListPath())
          .doc(item.id);
      
      batch.set(docRef, item.toJson());
    }
    
    await batch.commit();
  }
  
  Future<void> toggleItem(String itemId, bool isChecked) async {
    await _firestore
        .collection(_getUserShoppingListPath())
        .doc(itemId)
        .update({'isChecked': isChecked});
  }
  
  Future<void> deleteItem(String itemId) async {
    await _firestore
        .collection(_getUserShoppingListPath())
        .doc(itemId)
        .delete();
  }
  
  Future<void> clearCompleted() async {
    final snapshot = await _firestore
        .collection(_getUserShoppingListPath())
        .where('isChecked', isEqualTo: true)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
  
  Future<void> clearAll() async {
    final snapshot = await _firestore
        .collection(_getUserShoppingListPath())
        .get();
    
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
  
  Future<String> shareList(List<ShoppingItem> items, bool isPremium) async {
    // Premium feature: Share list via WhatsApp
    if (!isPremium) {
      throw Exception('Premium feature');
    }
    
    // Group by category
    final grouped = <ShoppingCategory, List<ShoppingItem>>{};
    for (var item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    
    // Format message
    final buffer = StringBuffer();
    buffer.writeln('🛒 Alışveriş Listem\n');
    
    for (var entry in grouped.entries) {
      final categoryName = _getCategoryName(entry.key);
      buffer.writeln('$categoryName:');
      
      for (var item in entry.value) {
        final checkbox = item.isChecked ? '☑️' : '☐';
        buffer.writeln('$checkbox ${item.quantity} ${item.name}');
      }
      
      buffer.writeln();
    }
    
    buffer.writeln('Kitcha ile oluşturuldu 🍅');
    
    return buffer.toString();
  }
  
  String _getCategoryName(ShoppingCategory category) {
    switch (category) {
      case ShoppingCategory.produce:
        return '🥬 Sebze & Meyve';
      case ShoppingCategory.dairy:
        return '🥛 Süt Ürünleri';
      case ShoppingCategory.meat:
        return '🍖 Et & Balık';
      case ShoppingCategory.pantry:
        return '🥫 Temel Gıda';
      case ShoppingCategory.frozen:
        return '❄️ Donmuş Ürünler';
      case ShoppingCategory.bakery:
        return '🥖 Fırın Ürünleri';
      case ShoppingCategory.other:
        return '📦 Diğer';
    }
  }
}

// lib/providers/shopping_list_provider.dart
class ShoppingListProvider extends ChangeNotifier {
  final ShoppingListService _service = ShoppingListService();
  List<ShoppingItem> _items = [];
  
  List<ShoppingItem> get items => _items;
  
  List<ShoppingItem> get uncheckedItems => 
      _items.where((item) => !item.isChecked).toList();
  
  List<ShoppingItem> get checkedItems => 
      _items.where((item) => item.isChecked).toList();
  
  Map<ShoppingCategory, List<ShoppingItem>> get groupedItems {
    final grouped = <ShoppingCategory, List<ShoppingItem>>{};
    for (var item in uncheckedItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }
  
  void startWatching() {
    _service.watchShoppingList().listen((items) {
      _items = items;
      notifyListeners();
    });
  }
  
  Future<void> addItem({
    required String name,
    required String quantity,
    String? recipeId,
    String? recipeName,
  }) async {
    await _service.addItem(
      name: name,
      quantity: quantity,
      recipeId: recipeId,
      recipeName: recipeName,
    );
    
    // Track gamification
    await GamificationService().onShoppingListCreated(false);
  }
  
  Future<void> addItemsFromRecipe(Recipe recipe) async {
    await _service.addItemsFromRecipe(recipe);
    await GamificationService().onShoppingListCreated(false);
  }
  
  Future<void> toggleItem(String itemId, bool isChecked) async {
    await _service.toggleItem(itemId, isChecked);
  }
  
  Future<void> deleteItem(String itemId) async {
    await _service.deleteItem(itemId);
  }
  
  Future<void> clearCompleted() async {
    await _service.clearCompleted();
  }
  
  Future<void> clearAll() async {
    await _service.clearAll();
  }
  
  Future<String> shareList(bool isPremium) async {
    return await _service.shareList(_items, isPremium);
  }
}

// lib/screens/shopping_list_screen.dart
class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    context.read<ShoppingListProvider>().startWatching();
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Alışveriş Listesi 🛒'),
        backgroundColor: Color(0xFFFF6347),
        actions: [
          if (provider.items.isNotEmpty) ...[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => _shareList(
                context,
                provider,
                subscriptionProvider.isPremium,
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear_completed',
                  child: Text('Tamamlananları Temizle'),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Text('Hepsini Temizle'),
                ),
              ],
              onSelected: (value) {
                if (value == 'clear_completed') {
                  provider.clearCompleted();
                } else if (value == 'clear_all') {
                  _showClearAllDialog(context, provider);
                }
              },
            ),
          ],
        ],
      ),
      body: provider.items.isEmpty
          ? _buildEmptyState()
          : _buildListView(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFFF6347),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty_shopping_cart.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 24),
          Text(
            'Alışveriş listeniz boş',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tariflerden malzeme ekleyin veya\nmanuel olarak ekleyin',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListView(ShoppingListProvider provider) {
    final grouped = provider.groupedItems;
    final checkedItems = provider.checkedItems;
    
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Summary
        if (provider.items.isNotEmpty) ...[
          _buildSummaryCard(provider),
          SizedBox(height: 16),
        ],
        
        // Unchecked items by category
        ...grouped.entries.map((entry) {
          return _buildCategorySection(
            category: entry.key,
            items: entry.value,
            provider: provider,
          );
        }),
        
        // Checked items (collapsed)
        if (checkedItems.isNotEmpty) ...[
          _buildCheckedSection(checkedItems, provider),
        ],
      ],
    );
  }
  
  Widget _buildSummaryCard(ShoppingListProvider provider) {
    final total = provider.items.length;
    final checked = provider.checkedItems.length;
    final progress = total > 0 ? checked / total : 0.0;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İlerleme',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$checked / $total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategorySection({
    required ShoppingCategory category,
    required List<ShoppingItem> items,
    required ShoppingListProvider provider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _getCategoryName(category),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6347),
            ),
          ),
        ),
        ...items.map((item) => _buildShoppingItem(item, provider)),
        SizedBox(height: 8),
      ],
    );
  }
  
  Widget _buildCheckedSection(
    List<ShoppingItem> items,
    ShoppingListProvider provider,
  ) {
    return ExpansionTile(
      title: Text('Tamamlananlar (${items.length})'),
      initiallyExpanded: false,
      children: items.map((item) => _buildShoppingItem(item, provider)).toList(),
    );
  }
  
  Widget _buildShoppingItem(ShoppingItem item, ShoppingListProvider provider) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteItem(item.id),
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: (value) => provider.toggleItem(item.id, value!),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isChecked 
                ? TextDecoration.lineThrough
                : null,
            color: item.isChecked ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.quantity),
            if (item.recipeName != null)
              Text(
                '📖 ${item.recipeName}',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFF6347),
                ),
              ),
          ],
        ),
        activeColor: Color(0xFFFF6347),
      ),
    );
  }
  
  String _getCategoryName(ShoppingCategory category) {
    switch (category) {
      case ShoppingCategory.produce:
        return '🥬 Sebze & Meyve';
      case ShoppingCategory.dairy:
        return '🥛 Süt Ürünleri';
      case ShoppingCategory.meat:
        return '🍖 Et & Balık';
      case ShoppingCategory.pantry:
        return '🥫 Temel Gıda';
      case ShoppingCategory.frozen:
        return '❄️ Donmuş Ürünler';
      case ShoppingCategory.bakery:
        return '🥖 Fırın Ürünleri';
      case ShoppingCategory.other:
        return '📦 Diğer';
    }
  }
  
  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yeni Ürün Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ürün Adı',
                hintText: 'örn: Domates',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Miktar',
                hintText: 'örn: 2 kg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty &&
                  _quantityController.text.isNotEmpty) {
                context.read<ShoppingListProvider>().addItem(
                  name: _nameController.text,
                  quantity: _quantityController.text,
                );
                
                _nameController.clear();
                _quantityController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }
  
  void _showClearAllDialog(BuildContext context, ShoppingListProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tümünü Temizle'),
        content: Text('Tüm alışveriş listesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _shareList(
    BuildContext context,
    ShoppingListProvider provider,
    bool isPremium,
  ) async {
    if (!isPremium) {
      // Show premium paywall
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Premium Özellik'),
          content: Text('Alışveriş listesini paylaşmak için Premium\'a geçin!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PremiumScreen()),
                );
              },
              child: Text('Premium Al'),
            ),
          ],
        ),
      );
      return;
    }
    
    try {
      final message = await provider.shareList(isPremium);
      
      // Share via WhatsApp or other apps
      await Share.share(
        message,
        subject: 'Alışveriş Listem',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paylaşım hatası: $e')),
      );
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
```

**RecipeDetailScreen'de "Add to Shopping List" butonu:**

```dart
// RecipeDetailScreen içinde
FloatingActionButton.extended(
  onPressed: () async {
    await context.read<ShoppingListProvider>().addItemsFromRecipe(recipe);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe.ingredients.length} malzeme alışveriş listesine eklendi!'),
        action: SnackBarAction(
          label: 'GÖR',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ShoppingListScreen()),
            );
          },
        ),
      ),
    );
  },
  label: Text('Alışveriş Listesine Ekle'),
  icon: Icon(Icons.shopping_cart),
  backgroundColor: Color(0xFFFF6347),
)
```
## 4. 🏅 WEEKLY CHALLENGES (Complete Implementation)

### Challenge System

```dart
// lib/models/weekly_challenge.dart
enum ChallengeType {
  recipeCount,      // "View 10 recipes"
  categoryFocus,    // "Try 3 dessert recipes"
  calorieGoal,      // "Track 2000 calories"
  favoritesGoal,    // "Add 5 favorites"
  streakGoal,       // "3-day streak"
  aiUsage,          // "Use AI Camera 3 times"
}

class WeeklyChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetCount;
  final int rewardXP;
  final String? rewardBadgeId;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, int> leaderboard; // userId -> progress
  final int participantCount;
  
  WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetCount,
    required this.rewardXP,
    this.rewardBadgeId,
    required this.startDate,
    required this.endDate,
    this.leaderboard = const {},
    this.participantCount = 0,
  });
  
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
  
  bool get isCompleted {
    return DateTime.now().isAfter(endDate);
  }
  
  factory WeeklyChallenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeeklyChallenge(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      type: ChallengeType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
      ),
      targetCount: data['targetCount'],
      rewardXP: data['rewardXP'],
      rewardBadgeId: data['rewardBadgeId'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      leaderboard: Map<String, int>.from(data['leaderboard'] ?? {}),
      participantCount: data['participantCount'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'targetCount': targetCount,
      'rewardXP': rewardXP,
      'rewardBadgeId': rewardBadgeId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'leaderboard': leaderboard,
      'participantCount': participantCount,
    };
  }
}

class UserChallengeProgress {
  final String userId;
  final String challengeId;
  final int currentProgress;
  final bool isCompleted;
  final DateTime? completedAt;
  
  UserChallengeProgress({
    required this.userId,
    required this.challengeId,
    required this.currentProgress,
    this.isCompleted = false,
    this.completedAt,
  });
  
  factory UserChallengeProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserChallengeProgress(
      userId: data['userId'],
      challengeId: data['challengeId'],
      currentProgress: data['currentProgress'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }
}
```

### Challenge Service

```dart
// lib/services/challenge_service.dart
class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current active challenge
  Future<WeeklyChallenge?> getCurrentChallenge() async {
    final now = DateTime.now();
    
    final snapshot = await _firestore
        .collection('challenges')
        .where('startDate', isLessThan: Timestamp.fromDate(now))
        .where('endDate', isGreaterThan: Timestamp.fromDate(now))
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    
    return WeeklyChallenge.fromFirestore(snapshot.docs.first);
  }
  
  // Get user's progress for a challenge
  Future<UserChallengeProgress?> getUserProgress(String challengeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    
    final doc = await _firestore
        .collection('user_challenges')
        .doc('${userId}_$challengeId')
        .get();
    
    if (!doc.exists) {
      // Create initial progress
      final progress = UserChallengeProgress(
        userId: userId,
        challengeId: challengeId,
        currentProgress: 0,
      );
      
      await _firestore
          .collection('user_challenges')
          .doc('${userId}_$challengeId')
          .set(progress.toJson());
      
      return progress;
    }
    
    return UserChallengeProgress.fromFirestore(doc);
  }
  
  // Update challenge progress
  Future<void> updateProgress({
    required String challengeId,
    required int increment,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    final docRef = _firestore
        .collection('user_challenges')
        .doc('${userId}_$challengeId}');
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      
      if (!doc.exists) {
        transaction.set(docRef, {
          'userId': userId,
          'challengeId': challengeId,
          'currentProgress': increment,
          'isCompleted': false,
        });
        return;
      }
      
      final data = doc.data()!;
      final currentProgress = data['currentProgress'] ?? 0;
      final newProgress = currentProgress + increment;
      
      transaction.update(docRef, {
        'currentProgress': newProgress,
      });
      
      // Check if challenge is completed
      final challenge = await getCurrentChallenge();
      if (challenge != null && newProgress >= challenge.targetCount) {
        await _completeChallenge(challengeId, userId);
      }
    });
  }
  
  Future<void> _completeChallenge(String challengeId, String userId) async {
    final challenge = await _firestore
        .collection('challenges')
        .doc(challengeId)
        .get();
    
    if (!challenge.exists) return;
    
    final challengeData = WeeklyChallenge.fromFirestore(challenge);
    
    // Mark as completed
    await _firestore
        .collection('user_challenges')
        .doc('${userId}_$challengeId')
        .update({
      'isCompleted': true,
      'completedAt': FieldValue.serverTimestamp(),
    });
    
    // Award XP
    await GamificationService().addXP(
      challengeData.rewardXP,
      reason: 'challenge_completed',
    );
    
    // Award badge if any
    if (challengeData.rewardBadgeId != null) {
      await _firestore.collection('users').doc(userId).update({
        'badges': FieldValue.arrayUnion([challengeData.rewardBadgeId]),
      });
    }
    
    // Send notification
    await NotificationService().showLocalNotification(
      title: '🎉 Challenge Tamamlandı!',
      body: '${challengeData.title} - ${challengeData.rewardXP} XP kazandın!',
      payload: '/challenges',
    );
    
    // Update leaderboard
    await _firestore.collection('challenges').doc(challengeId).update({
      'leaderboard.$userId': FieldValue.serverTimestamp(),
    });
  }
  
  // Join challenge
  Future<void> joinChallenge(String challengeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    await _firestore.collection('challenges').doc(challengeId).update({
      'participantCount': FieldValue.increment(1),
    });
    
    // Create initial progress
    final progress = UserChallengeProgress(
      userId: userId,
      challengeId: challengeId,
      currentProgress: 0,
    );
    
    await _firestore
        .collection('user_challenges')
        .doc('${userId}_$challengeId')
        .set(progress.toJson());
  }
  
  // Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard(String challengeId) async {
    final snapshot = await _firestore
        .collection('user_challenges')
        .where('challengeId', isEqualTo: challengeId)
        .where('isCompleted', isEqualTo: true)
        .orderBy('completedAt')
        .limit(10)
        .get();
    
    final List<Map<String, dynamic>> leaderboard = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final userId = data['userId'];
      
      // Get user info
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      
      leaderboard.add({
        'userId': userId,
        'username': userData?['username'] ?? 'Anonymous',
        'avatarUrl': userData?['avatarUrl'],
        'completedAt': data['completedAt'],
        'rank': leaderboard.length + 1,
      });
    }
    
    return leaderboard;
  }
  
  // Admin: Create new challenge
  Future<void> createChallenge(WeeklyChallenge challenge) async {
    await _firestore
        .collection('challenges')
        .doc(challenge.id)
        .set(challenge.toJson());
  }
}
```

### Challenge Screen UI

```dart
// lib/screens/challenges_screen.dart
class ChallengesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Haftalık Challenge'),
        backgroundColor: Color(0xFFFF6347),
      ),
      body: FutureBuilder<WeeklyChallenge?>(
        future: ChallengeService().getCurrentChallenge(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData) {
            return _buildNoChallengeState();
          }
          
          final challenge = snapshot.data!;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Challenge header
                _buildChallengeHeader(challenge),
                
                // User progress
                FutureBuilder<UserChallengeProgress?>(
                  future: ChallengeService().getUserProgress(challenge.id),
                  builder: (context, progressSnapshot) {
                    if (!progressSnapshot.hasData) {
                      return SizedBox.shrink();
                    }
                    
                    final progress = progressSnapshot.data!;
                    
                    return _buildProgressCard(challenge, progress);
                  },
                ),
                
                // Leaderboard
                _buildLeaderboard(challenge.id),
                
                // Past challenges
                _buildPastChallenges(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildNoChallengeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 24),
          Text(
            'Şu Anda Aktif Challenge Yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Yeni challenge çok yakında!',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengeHeader(WeeklyChallenge challenge) {
    final daysLeft = challenge.endDate.difference(DateTime.now()).inDays;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            size: 64,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            challenge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            challenge.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                '$daysLeft gün kaldı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                '${challenge.participantCount} katılımcı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressCard(
    WeeklyChallenge challenge,
    UserChallengeProgress progress,
  ) {
    final percentage = (progress.currentProgress / challenge.targetCount)
        .clamp(0.0, 1.0);
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İlerleme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${progress.currentProgress}/${challenge.targetCount}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6347),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 20,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6347)),
            ),
          ),
          
          SizedBox(height: 16),
          
          if (!progress.isCompleted) ...[
            Text(
              'Ödül: ${challenge.rewardXP} XP',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            if (challenge.rewardBadgeId != null)
              Text(
                '+ Özel Rozet 🏆',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Tamamlandı! 🎉',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildLeaderboard(String challengeId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ChallengeService().getLeaderboard(challengeId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        }
        
        final leaderboard = snapshot.data!;
        
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🏆 Sıralama',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ...leaderboard.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                
                return _buildLeaderboardItem(
                  rank: index + 1,
                  username: user['username'],
                  avatarUrl: user['avatarUrl'],
                );
              }),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLeaderboardItem({
    required int rank,
    required String username,
    String? avatarUrl,
  }) {
    Color? medalColor;
    IconData? medalIcon;
    
    if (rank == 1) {
      medalColor = Color(0xFFFFD700); // Gold
      medalIcon = Icons.emoji_events;
    } else if (rank == 2) {
      medalColor = Colors.grey[400]; // Silver
      medalIcon = Icons.emoji_events;
    } else if (rank == 3) {
      medalColor = Color(0xFFCD7F32); // Bronze
      medalIcon = Icons.emoji_events;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rank <= 3 ? medalColor?.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3 ? medalColor! : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            child: medalIcon != null
                ? Icon(medalIcon, color: medalColor, size: 28)
                : Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null
                ? Icon(Icons.person)
                : null,
          ),
          
          SizedBox(width: 12),
          
          // Username
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPastChallenges() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geçmiş Challenge\'lar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Yakında...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
```
---

### PHASE 2.5: Community & Social Features

#### **Hedef:** Sosyal özelliklerle kullanıcı engagement'ını artır

**2.5.1 Deep Linking (Tarif Paylaşımı)**

```yaml
# pubspec.yaml
dependencies:
  uni_links: ^0.5.1
  share_plus: ^7.2.1
```

**Setup:**

```dart
// lib/services/deep_link_service.dart
class DeepLinkService {
  static const String scheme = 'kitcha';
  static const String host = 'app';
  
  StreamSubscription? _subscription;
  
  void initialize(BuildContext context) {
    // Handle initial link (app was closed)
    _handleInitialLink(context);
    
    // Handle links while app is running
    _subscription = linkStream.listen((String? link) {
      if (link != null) {
        _handleLink(context, link);
      }
    });
  }
  
  Future<void> _handleInitialLink(BuildContext context) async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleLink(context, initialLink);
      }
    } catch (e) {
      print('Deep link error: $e');
    }
  }
  
  void _handleLink(BuildContext context, String link) {
    final uri = Uri.parse(link);
    
    // kitcha://recipe/123
    if (uri.pathSegments.isNotEmpty) {
      final resource = uri.pathSegments[0];
      
      if (resource == 'recipe' && uri.pathSegments.length > 1) {
        final recipeId = uri.pathSegments[1];
        _navigateToRecipe(context, recipeId);
      } else if (resource == 'profile' && uri.pathSegments.length > 1) {
        final userId = uri.pathSegments[1];
        _navigateToProfile(context, userId);
      } else if (resource == 'premium') {
        _navigateToPremium(context);
      }
    }
  }
  
  void _navigateToRecipe(BuildContext context, String recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(recipeId: recipeId),
      ),
    );
  }
  
  void _navigateToProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(userId: userId),
      ),
    );
  }
  
  void _navigateToPremium(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PremiumScreen()),
    );
  }
  
  static String createRecipeLink(String recipeId) {
    return 'kitcha://recipe/$recipeId';
  }
  
  static String createProfileLink(String userId) {
    return 'kitcha://profile/$userId';
  }
  
  void dispose() {
    _subscription?.cancel();
  }
}

// Share recipe with deep link
Future<void> shareRecipe(Recipe recipe) async {
  final deepLink = DeepLinkService.createRecipeLink(recipe.id);
  
  final message = '''
🍅 Kitcha'dan bir tarif: ${recipe.title}

⏱️ ${recipe.prepTime} dakika | 🔥 ${recipe.calories} kcal

Tarifi görmek için tıkla:
$deepLink

Kitcha - Your Smart Kitchen Companion
''';
  
  await Share.share(message);
}
```

**Android Manifest:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <application>
    <activity>
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
          android:scheme="kitcha"
          android:host="app" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

**iOS Info.plist:**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>kitcha</string>
    </array>
  </dict>
</array>
```

**2.5.2 Referral System (Arkadaşını Davet Et)**

```dart
// lib/services/referral_service.dart
class ReferralService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<String> getUserReferralCode() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not logged in');
    
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();
    
    if (userData?['referralCode'] != null) {
      return userData!['referralCode'];
    }
    
    // Generate new referral code
    final code = _generateCode(userId);
    await _firestore.collection('users').doc(userId).update({
      'referralCode': code,
    });
    
    return code;
  }
  
  String _generateCode(String userId) {
    // Generate 6-character code from user ID
    final hash = userId.hashCode.abs().toString();
    return hash.substring(0, 6).toUpperCase();
  }
  
  Future<void> applyReferralCode(String code) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not logged in');
    
    // Check if user already used a referral code
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.data()?['referredBy'] != null) {
      throw Exception('Already used a referral code');
    }
    
    // Find referrer
    final referrerSnapshot = await _firestore
        .collection('users')
        .where('referralCode', isEqualTo: code)
        .limit(1)
        .get();
    
    if (referrerSnapshot.docs.isEmpty) {
      throw Exception('Invalid referral code');
    }
    
    final referrerId = referrerSnapshot.docs.first.id;
    
    if (referrerId == userId) {
      throw Exception('Cannot use your own referral code');
    }
    
    // Apply referral
    await _firestore.runTransaction((transaction) async {
      // Update referee (current user)
      transaction.update(
        _firestore.collection('users').doc(userId),
        {
          'referredBy': referrerId,
          'premiumBonusDays': FieldValue.increment(7), // 7 days free
        },
      );
      
      // Update referrer
      transaction.update(
        _firestore.collection('users').doc(referrerId),
        {
          'referralCount': FieldValue.increment(1),
          'premiumBonusDays': FieldValue.increment(7), // 7 days free
        },
      );
    });
    
    // Send notifications
    await _sendReferralNotification(referrerId, userId);
  }
  
  Future<void> _sendReferralNotification(
    String referrerId,
    String refereeId,
  ) async {
    // Send push notification to referrer
    final referrerDoc = await _firestore.collection('users').doc(referrerId).get();
    final fcmToken = referrerDoc.data()?['fcmToken'];
    
    if (fcmToken != null) {
      // Send notification via Cloud Function
      await _firestore.collection('notifications').add({
        'userId': referrerId,
        'title': '🎉 Yeni Davet!',
        'body': 'Arkadaşın Kitcha\'ya katıldı! Her ikiniz 7 gün premium kazandınız.',
        'type': 'referral',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  Future<String> shareReferralLink() async {
    final code = await getUserReferralCode();
    final deepLink = 'kitcha://referral/$code';
    
    final message = '''
🍅 Kitcha'yı denedin mi?

Davet kodumla kayıt ol, her ikimiz 7 gün Premium kazanalım!

Davet Kodu: $code

İndirmek için:
$deepLink
''';
    
    await Share.share(message);
    return code;
  }
  
  Future<Map<String, dynamic>> getReferralStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};
    
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};
    
    return {
      'referralCode': userData['referralCode'] ?? '',
      'referralCount': userData['referralCount'] ?? 0,
      'premiumBonusDays': userData['premiumBonusDays'] ?? 0,
    };
  }
}

// lib/screens/referral_screen.dart
class ReferralScreen extends StatelessWidget {
  final ReferralService _referralService = ReferralService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arkadaşını Davet Et 🎁'),
        backgroundColor: Color(0xFFFF6347),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _referralService.getReferralStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          final stats = snapshot.data ?? {};
          final code = stats['referralCode'] ?? '';
          final count = stats['referralCount'] ?? 0;
          final bonusDays = stats['premiumBonusDays'] ?? 0;
          
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.card_giftcard, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Arkadaşlarını davet et,\nher davet 7 gün Premium kazan!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Referral code
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFFF6347), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Davet Kodun',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          code,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: Color(0xFFFF6347),
                          ),
                        ),
                        SizedBox(width: 16),
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Kod kopyalandı!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people,
                      label: 'Davet Edilenler',
                      value: count.toString(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star,
                      label: 'Premium Günler',
                      value: bonusDays.toString(),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              // Share button
              ElevatedButton.icon(
                onPressed: () => _referralService.shareReferralLink(),
                icon: Icon(Icons.share),
                label: Text('Davet Linkini Paylaş'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6347),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              
              SizedBox(height: 32),
              
              // How it works
              Text(
                'Nasıl Çalışır?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              _buildStep(
                number: '1',
                text: 'Davet kodunu veya linkini arkadaşınla paylaş',
              ),
              _buildStep(
                number: '2',
                text: 'Arkadaşın kodunu kullanarak kayıt olsun',
              ),
              _buildStep(
                number: '3',
                text: 'Her ikiniz 7 gün Premium kazanın!',
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFFFF6347), size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6347),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep({required String number, required String text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFFFF6347),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
```
## 3. 👥 COMMUNITY FEATURES (Full Implementation)

### Public User Profiles

```dart
// lib/models/public_profile.dart
class PublicProfile {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int totalRecipes;
  final int totalFavorites;
  final int followersCount;
  final int followingCount;
  final List<String> badges;
  final int totalXP;
  final int currentLevel;
  final bool isPremium;
  final DateTime joinedAt;
  final bool isFollowing; // For current user perspective
  
  PublicProfile({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.totalRecipes,
    required this.totalFavorites,
    required this.followersCount,
    required this.followingCount,
    required this.badges,
    required this.totalXP,
    required this.currentLevel,
    required this.isPremium,
    required this.joinedAt,
    this.isFollowing = false,
  });
  
  factory PublicProfile.fromFirestore(DocumentSnapshot doc, bool isFollowing) {
    final data = doc.data() as Map<String, dynamic>;
    return PublicProfile(
      userId: doc.id,
      username: data['username'] ?? 'Anonymous',
      avatarUrl: data['avatarUrl'],
      bio: data['bio'],
      totalRecipes: data['totalRecipesViewed'] ?? 0,
      totalFavorites: data['totalFavorites'] ?? 0,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      totalXP: data['totalXP'] ?? 0,
      currentLevel: data['currentLevel'] ?? 1,
      isPremium: data['isPremium'] ?? false,
      joinedAt: (data['createdAt'] as Timestamp).toDate(),
      isFollowing: isFollowing,
    );
  }
}

// lib/services/social_service.dart
class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<PublicProfile> getPublicProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('User not found');
    
    final currentUserId = _auth.currentUser?.uid;
    bool isFollowing = false;
    
    if (currentUserId != null && currentUserId != userId) {
      final followDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(userId)
          .get();
      isFollowing = followDoc.exists;
    }
    
    return PublicProfile.fromFirestore(doc, isFollowing);
  }
  
  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('Not logged in');
    if (currentUserId == targetUserId) throw Exception('Cannot follow yourself');
    
    await _firestore.runTransaction((transaction) async {
      // Add to current user's following
      transaction.set(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId),
        {'followedAt': FieldValue.serverTimestamp()},
      );
      
      // Add to target user's followers
      transaction.set(
        _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId),
        {'followedAt': FieldValue.serverTimestamp()},
      );
      
      // Update counts
      transaction.update(
        _firestore.collection('users').doc(currentUserId),
        {'followingCount': FieldValue.increment(1)},
      );
      
      transaction.update(
        _firestore.collection('users').doc(targetUserId),
        {'followersCount': FieldValue.increment(1)},
      );
    });
    
    // Send notification
    await NotificationService().sendFollowNotification(
      userId: targetUserId,
      followerName: _auth.currentUser!.displayName ?? 'Someone',
    );
  }
  
  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('Not logged in');
    
    await _firestore.runTransaction((transaction) async {
      // Remove from current user's following
      transaction.delete(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId),
      );
      
      // Remove from target user's followers
      transaction.delete(
        _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId),
      );
      
      // Update counts
      transaction.update(
        _firestore.collection('users').doc(currentUserId),
        {'followingCount': FieldValue.increment(-1)},
      );
      
      transaction.update(
        _firestore.collection('users').doc(targetUserId),
        {'followersCount': FieldValue.increment(-1)},
      );
    });
  }
  
  Stream<List<PublicProfile>> getFollowers(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('followers')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<PublicProfile> followers = [];
      
      for (var doc in snapshot.docs) {
        final followerProfile = await getPublicProfile(doc.id);
        followers.add(followerProfile);
      }
      
      return followers;
    });
  }
  
  Stream<List<PublicProfile>> getFollowing(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<PublicProfile> following = [];
      
      for (var doc in snapshot.docs) {
        final followingProfile = await getPublicProfile(doc.id);
        following.add(followingProfile);
      }
      
      return following;
    });
  }
}
```

### Public Profile Screen

```dart
// lib/screens/public_profile_screen.dart
class PublicProfileScreen extends StatelessWidget {
  final String userId;
  
  const PublicProfileScreen({required this.userId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PublicProfile>(
        future: SocialService().getPublicProfile(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          
          final profile = snapshot.data!;
          final isOwnProfile = FirebaseAuth.instance.currentUser?.uid == userId;
          
          return CustomScrollView(
            slivers: [
              // App bar with cover image
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
                      ),
                    ),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Profile header
                    Transform.translate(
                      offset: Offset(0, -50),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: profile.avatarUrl != null
                                  ? NetworkImage(profile.avatarUrl!)
                                  : null,
                              child: profile.avatarUrl == null
                                  ? Icon(Icons.person, size: 60)
                                  : null,
                            ),
                          ),
                          
                          SizedBox(height: 12),
                          
                          // Username & premium badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                profile.username,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (profile.isPremium) ...[
                                SizedBox(width: 8),
                                Icon(
                                  Icons.verified,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                              ],
                            ],
                          ),
                          
                          SizedBox(height: 4),
                          
                          // Level
                          Text(
                            'Level ${profile.currentLevel} • ${profile.totalXP} XP',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          
                          if (profile.bio != null) ...[
                            SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                profile.bio!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                          
                          SizedBox(height: 20),
                          
                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem(
                                label: 'Tarifler',
                                value: profile.totalRecipes.toString(),
                              ),
                              _StatItem(
                                label: 'Favoriler',
                                value: profile.totalFavorites.toString(),
                              ),
                              GestureDetector(
                                onTap: () => _showFollowers(context, userId),
                                child: _StatItem(
                                  label: 'Takipçi',
                                  value: profile.followersCount.toString(),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showFollowing(context, userId),
                                child: _StatItem(
                                  label: 'Takip',
                                  value: profile.followingCount.toString(),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Follow/Edit button
                          if (!isOwnProfile)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (profile.isFollowing) {
                                    await SocialService().unfollowUser(userId);
                                  } else {
                                    await SocialService().followUser(userId);
                                  }
                                  // Refresh
                                  (context as Element).markNeedsBuild();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: profile.isFollowing
                                      ? Colors.grey
                                      : Color(0xFFFF6347),
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  profile.isFollowing ? 'Takipten Çık' : 'Takip Et',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to edit profile
                                },
                                icon: Icon(Icons.edit),
                                label: Text('Profili Düzenle'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6347),
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Badges section
                    if (profile.badges.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rozetler (${profile.badges.length})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                              itemCount: profile.badges.length,
                              itemBuilder: (context, index) {
                                final badgeId = profile.badges[index];
                                final badge = Badge.all.firstWhere(
                                  (b) => b.id == badgeId,
                                  orElse: () => Badge.all.first,
                                );
                                return Image.asset(badge.iconPath);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Public favorites (optional)
                    // Divider(),
                    // _buildPublicFavorites(userId),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showFollowers(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowersScreen(userId: userId),
      ),
    );
  }
  
  void _showFollowing(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowingScreen(userId: userId),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatItem({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
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
```

### Recipe Comments & Ratings

```dart
// lib/models/recipe_comment.dart
class RecipeComment {
  final String id;
  final String recipeId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating; // 1-5 stars
  final String text;
  final List<String> images;
  final int helpfulCount;
  final List<RecipeComment> replies;
  final DateTime createdAt;
  final bool isEdited;
  
  RecipeComment({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.text,
    this.images = const [],
    this.helpfulCount = 0,
    this.replies = const [],
    required this.createdAt,
    this.isEdited = false,
  });
  
  factory RecipeComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecipeComment(
      id: doc.id,
      recipeId: data['recipeId'],
      userId: data['userId'],
      userName: data['userName'],
      userAvatar: data['userAvatar'],
      rating: data['rating'],
      text: data['text'],
      images: List<String>.from(data['images'] ?? []),
      helpfulCount: data['helpfulCount'] ?? 0,
      replies: [], // Load separately if needed
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isEdited: data['isEdited'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'text': text,
      'images': images,
      'helpfulCount': helpfulCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'isEdited': isEdited,
    };
  }
}

// lib/services/comment_service.dart
class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<void> addComment({
    required String recipeId,
    required int rating,
    required String text,
    List<File>? images,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');
    
    // Upload images if any
    List<String> imageUrls = [];
    if (images != null && images.isNotEmpty) {
      for (var image in images) {
        final url = await _uploadImage(image, recipeId);
        imageUrls.add(url);
      }
    }
    
    final comment = RecipeComment(
      id: _firestore.collection('comments').doc().id,
      recipeId: recipeId,
      userId: currentUser.uid,
      userName: currentUser.displayName ?? 'Anonymous',
      userAvatar: currentUser.photoURL,
      rating: rating,
      text: text,
      images: imageUrls,
      createdAt: DateTime.now(),
    );
    
    await _firestore
        .collection('comments')
        .doc(comment.id)
        .set(comment.toJson());
    
    // Update recipe rating
    await _updateRecipeRating(recipeId);
    
    // Log analytics
    await AnalyticsService().logEvent('comment_posted', {
      'recipe_id': recipeId,
      'rating': rating,
    });
  }
  
  Future<String> _uploadImage(File image, String recipeId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'comment_images/$recipeId/$timestamp.jpg';
    
    // Compress image first
    final compressed = await ImageService.compressImage(image);
    
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(compressed);
    
    return await ref.getDownloadURL();
  }
  
  Future<void> _updateRecipeRating(String recipeId) async {
    final snapshot = await _firestore
        .collection('comments')
        .where('recipeId', isEqualTo: recipeId)
        .get();
    
    if (snapshot.docs.isEmpty) return;
    
    final ratings = snapshot.docs.map((doc) => doc.data()['rating'] as int);
    final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
    final totalRatings = ratings.length;
    
    await _firestore.collection('recipes').doc(recipeId).update({
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    });
  }
  
  Stream<List<RecipeComment>> getComments(String recipeId) {
    return _firestore
        .collection('comments')
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('helpfulCount', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeComment.fromFirestore(doc))
          .toList();
    });
  }
  
  Future<void> markAsHelpful(String commentId) async {
    await _firestore.collection('comments').doc(commentId).update({
      'helpfulCount': FieldValue.increment(1),
    });
  }
  
  Future<void> reportComment(String commentId, String reason) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    
    await _firestore.collection('reported_comments').add({
      'commentId': commentId,
      'reportedBy': currentUser.uid,
      'reason': reason,
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
  
  Future<void> deleteComment(String commentId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    
    final doc = await _firestore.collection('comments').doc(commentId).get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    if (data['userId'] != currentUser.uid) {
      throw Exception('Not authorized to delete this comment');
    }
    
    await _firestore.collection('comments').doc(commentId).delete();
  }
}
```

### Comments UI Component

```dart
// lib/widgets/comments_section.dart
class CommentsSection extends StatefulWidget {
  final String recipeId;
  
  const CommentsSection({required this.recipeId});
  
  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _textController = TextEditingController();
  int _rating = 5;
  List<File> _selectedImages = [];
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.comment, color: Color(0xFFFF6347)),
              SizedBox(width: 8),
              Text(
                'Yorumlar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Add comment form
        _buildAddCommentForm(),
        
        Divider(),
        
        // Comments list
        StreamBuilder<List<RecipeComment>>(
          stream: CommentService().getComments(widget.recipeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Henüz yorum yok',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'İlk yorumu siz yapın!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            final comments = snapshot.data!;
            
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommentCard(comment: comments[index]);
              },
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildAddCommentForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating stars
          Row(
            children: [
              Text('Puanınız:'),
              SizedBox(width: 12),
              ...List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Comment text field
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Yorumunuzu yazın...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
            maxLength: 500,
          ),
          
          SizedBox(height: 12),
          
          // Image picker & submit button
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.photo_camera),
                onPressed: _pickImage,
                tooltip: 'Fotoğraf ekle',
              ),
              
              if (_selectedImages.isNotEmpty) ...[
                SizedBox(width: 8),
                Text('${_selectedImages.length} fotoğraf seçildi'),
              ],
              
              Spacer(),
              
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComment,
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6347),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    
    if (images != null) {
      setState(() {
        _selectedImages = images.map((xFile) => File(xFile.path)).toList();
      });
    }
  }
  
  Future<void> _submitComment() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir yorum yazın')),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      await CommentService().addComment(
        recipeId: widget.recipeId,
        rating: _rating,
        text: _textController.text.trim(),
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
      );
      
      // Clear form
      _textController.clear();
      setState(() {
        _rating = 5;
        _selectedImages = [];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorumunuz eklendi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class CommentCard extends StatelessWidget {
  final RecipeComment comment;
  
  const CommentCard({required this.comment});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info & rating
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicProfileScreen(userId: comment.userId),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: comment.userAvatar != null
                      ? NetworkImage(comment.userAvatar!)
                      : null,
                  child: comment.userAvatar == null
                      ? Icon(Icons.person)
                      : null,
                ),
              ),
              
              SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < comment.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                        SizedBox(width: 8),
                        Text(
                          _formatDate(comment.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Menu button
              PopupMenuButton(
                itemBuilder: (context) => [
                  if (comment.userId == FirebaseAuth.instance.currentUser?.uid)
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Sil'),
                    ),
                  PopupMenuItem(
                    value: 'report',
                    child: Text('Bildir'),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'delete') {
                    await CommentService().deleteComment(comment.id);
                  } else if (value == 'report') {
                    _showReportDialog(context, comment.id);
                  }
                },
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Comment text
          Text(comment.text),
          
          // Images
          if (comment.images.isNotEmpty) ...[
            SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: comment.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        comment.images[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          SizedBox(height: 12),
          
          // Actions
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  CommentService().markAsHelpful(comment.id);
                },
                icon: Icon(Icons.thumb_up_outlined, size: 16),
                label: Text('Faydalı (${comment.helpfulCount})'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                ),
              ),
              
              // Reply button (future feature)
              // TextButton.icon(
              //   onPressed: () {},
              //   icon: Icon(Icons.reply, size: 16),
              //   label: Text('Yanıtla'),
              // ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yıl önce';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
  
  void _showReportDialog(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yorumu Bildir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bu yorumu neden bildiriyorsunuz?'),
            SizedBox(height: 16),
            ...['Spam', 'Hakaret', 'Yanıltıcı', 'Diğer'].map((reason) {
              return ListTile(
                title: Text(reason),
                onTap: () async {
                  await CommentService().reportComment(commentId, reason);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Yorum bildirildi')),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
```

---

## 📦 DOSYA YAPISI GÜNCELLEMESI (Tüm Yeni Dosyalar)

```
lib/
├── main.dart (✏️ Guest access + Deep linking)
├── config/
│   └── api_keys.dart (🆕)
├── models/
│   ├── badge.dart (🆕)
│   ├── user_stats.dart (🆕)
│   ├── shopping_item.dart (🆕)
│   ├── detected_ingredient.dart (🆕)
│   └── (existing models)
├── screens/
│   ├── premium_screen.dart (🆕)
│   ├── legal_screen.dart (🆕)
│   ├── ai_kitchen_camera.dart (🆕)
│   ├── shopping_list_screen.dart (🆕)
│   ├── leaderboard_screen.dart (🆕)
│   ├── referral_screen.dart (🆕)
│   ├── feedback_screen.dart (🆕)
│   ├── public_profile_screen.dart (🆕)
│   └── (existing screens)
├── widgets/
│   ├── banner_ad_widget.dart (🆕)
│   ├── xp_gain_animation.dart (🆕)
│   ├── login_bottom_sheet.dart (🆕)
│   └── (existing widgets)
├── providers/
│   ├── subscription_provider.dart (🆕)
│   ├── shopping_list_provider.dart (🆕)
│   └── (existing providers)
├── services/
│   ├── analytics_service.dart (🆕)
│   ├── ad_manager.dart (🆕)
│   ├── revenue_cat_service.dart (🆕)
│   ├── remote_config_service.dart (🆕)
│   ├── notification_service.dart (🆕)
│   ├── review_service.dart (🆕)
│   ├── api_cache_service.dart (🆕)
│   ├── feature_flag_service.dart (🆕)
│   ├── gamification_service.dart (🆕)
│   ├── ingredient_detection_service.dart (🆕)
│   ├── shopping_list_service.dart (🆕)
│   ├── deep_link_service.dart (🆕)
│   ├── referral_service.dart (🆕)
│   └── (existing services)
├── utils/
│   ├── action_guard.dart (🆕)
│   ├── input_validator.dart (🆕)
│   ├── rate_limiter.dart (🆕)
│   └── (existing utils)
└── assets/
    ├── animations/
    │   ├── scanning.json (🆕)
    │   ├── empty_shopping_cart.json (🆕)
    │   └── confetti.json (🆕)
    └── badges/ (🆕)
        ├── newbie.png
        ├── foodie.png
        ├── collector.png
        ├── analyzer.png
        ├── social.png
        ├── streaker.png
        └── premium.png
```

---

## 🎯 SONRAKİ ADIMLAR VE ROADMAP DEVAMI

Bu dosya PART 2'yi tamamlıyor. PART 3'te şunlar olacak:

1. **PHASE 3: Seasonal Themes** (detaylı implementation)
2. **PHASE 4: Multilingual & Content** (çeviri sistemi + Türkçe tarif database)
3. **PHASE 5-7**: Premium Polish, UX Enhancements, Year in Review
4. **Backend & Infrastructure** (tüm eksikler)
5. **Security & Compliance** (GDPR, encryption, etc.)
6. **DevOps & Monitoring** (CI/CD, logging, alerts)
7. **Marketing & Growth** (ASO, attribution tracking)
8. **Test Stratejisi** (unit, widget, integration tests)
9. **Deployment Planı** (beta, soft launch, global)
10. **Backup & Recovery** stratejisi

## COMPLETE & COMPREHENSIVE EDITION - PART 3

**Devamı - Seasonal Themes, Multilingual, Backend Infrastructure & More**

---

### PHASE 3: Seasonal Experience

#### **Hedef:** Tatil dönemlerinde uygulamayı dinamik olarak dönüştür

**3.1 Seasonal Logic Service**

```dart
// lib/services/seasonal_service.dart
enum SeasonalTheme {
  none,
  newYear,       // 25 Aralık - 7 Ocak
  valentines,    // 10-14 Şubat
  ramadan,       // Ramazan ayı (değişken)
  spring,        // 20 Mart - 20 Haziran
  summer,        // 21 Haziran - 22 Eylül
  halloween,     // 25-31 Ekim
  thanksgiving,  // Kasım son perşembe (ABD)
  christmas,     // 20-25 Aralık
}

class SeasonalThemeData {
  final SeasonalTheme theme;
  final String name;
  final Color primaryColor;
  final Color accentColor;
  final String animationAsset;
  final List<String> emojis;
  final String greeting;
  
  const SeasonalThemeData({
    required this.theme,
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.animationAsset,
    required this.emojis,
    required this.greeting,
  });
}

class SeasonalService {
  static const Map<SeasonalTheme, SeasonalThemeData> _themes = {
    SeasonalTheme.newYear: SeasonalThemeData(
      theme: SeasonalTheme.newYear,
      name: 'Yeni Yıl',
      primaryColor: Color(0xFFFFD700),
      accentColor: Color(0xFFFF6347),
      animationAsset: 'assets/animations/fireworks.json',
      emojis: ['🎊', '🎉', '✨', '🥳'],
      greeting: 'Mutlu Yıllar! 🎉',
    ),
    SeasonalTheme.valentines: SeasonalThemeData(
      theme: SeasonalTheme.valentines,
      name: 'Sevgililer Günü',
      primaryColor: Color(0xFFFF69B4),
      accentColor: Color(0xFFFF1493),
      animationAsset: 'assets/animations/hearts.json',
      emojis: ['💕', '💖', '💗', '❤️'],
      greeting: 'Sevgiyle! 💕',
    ),
    SeasonalTheme.ramadan: SeasonalThemeData(
      theme: SeasonalTheme.ramadan,
      name: 'Ramazan',
      primaryColor: Color(0xFF9B59B6),
      accentColor: Color(0xFF8E44AD),
      animationAsset: 'assets/animations/stars_moon.json',
      emojis: ['🌙', '⭐', '🕌', '🤲'],
      greeting: 'Hayırlı Ramazanlar! 🌙',
    ),
    SeasonalTheme.halloween: SeasonalThemeData(
      theme: SeasonalTheme.halloween,
      name: 'Halloween',
      primaryColor: Color(0xFFFF8C00),
      accentColor: Color(0xFF8B4513),
      animationAsset: 'assets/animations/bats.json',
      emojis: ['🎃', '👻', '🦇', '🕷️'],
      greeting: 'Hadi biraz korkalım! 🎃',
    ),
    SeasonalTheme.christmas: SeasonalThemeData(
      theme: SeasonalTheme.christmas,
      name: 'Noel',
      primaryColor: Color(0xFFDC143C),
      accentColor: Color(0xFF228B22),
      animationAsset: 'assets/animations/snowflakes.json',
      emojis: ['🎄', '🎅', '❄️', '⛄'],
      greeting: 'Mutlu Noeller! 🎄',
    ),
  };
  
  SeasonalTheme getCurrentTheme() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;
    
    // Yeni Yıl (25 Aralık - 7 Ocak)
    if ((month == 12 && day >= 25) || (month == 1 && day <= 7)) {
      return SeasonalTheme.newYear;
    }
    
    // Sevgililer Günü (10-14 Şubat)
    if (month == 2 && day >= 10 && day <= 14) {
      return SeasonalTheme.valentines;
    }
    
    // Ramazan (TODO: Calculate Islamic calendar)
    // Bu yıl için hardcode edilebilir, sonra API ile alınabilir
    
    // Halloween (25-31 Ekim)
    if (month == 10 && day >= 25) {
      return SeasonalTheme.halloween;
    }
    
    // Noel (20-25 Aralık)
    if (month == 12 && day >= 20 && day < 25) {
      return SeasonalTheme.christmas;
    }
    
    // İlkbahar, Yaz, vs. (optional)
    
    return SeasonalTheme.none;
  }
  
  SeasonalThemeData? getThemeData(SeasonalTheme theme) {
    return _themes[theme];
  }
  
  bool isSeasonActive() {
    return getCurrentTheme() != SeasonalTheme.none;
  }
}

// lib/widgets/seasonal_overlay.dart
class SeasonalOverlay extends StatelessWidget {
  final Widget child;
  
  const SeasonalOverlay({required this.child});
  
  @override
  Widget build(BuildContext context) {
    final seasonalService = SeasonalService();
    final currentTheme = seasonalService.getCurrentTheme();
    
    if (currentTheme == SeasonalTheme.none) {
      return child;
    }
    
    final themeData = seasonalService.getThemeData(currentTheme);
    if (themeData == null) return child;
    
    return Stack(
      children: [
        child,
        
        // Animated overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Lottie.asset(
              themeData.animationAsset,
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
        ),
      ],
    );
  }
}

// lib/widgets/seasonal_header.dart
class SeasonalHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final seasonalService = SeasonalService();
    final currentTheme = seasonalService.getCurrentTheme();
    
    if (currentTheme == SeasonalTheme.none) {
      return SizedBox.shrink();
    }
    
    final themeData = seasonalService.getThemeData(currentTheme);
    if (themeData == null) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeData.primaryColor, themeData.accentColor],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            themeData.emojis.join(' '),
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              themeData.greeting,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**HomeScreen'e entegrasyon:**

```dart
// lib/screens/home_screen.dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SeasonalOverlay(
      child: Scaffold(
        body: ListView(
          children: [
            // Seasonal header
            SeasonalHeader(),
            
            // Rest of content
            // ...
          ],
        ),
      ),
    );
  }
}
```

---

### PHASE 4: Multilingual & Content

#### **Hedef:** Global expansion için çoklu dil desteği ve içerik zenginleştirme

**4.1 Easy Localization Setup**

```yaml
# pubspec.yaml
dependencies:
  easy_localization: ^3.0.3
```

**Dil dosyaları:**

```
assets/translations/
├── en.json
├── tr.json
├── de.json
├── fr.json
├── es.json
├── ar.json (RTL)
└── ...
```

```json
// assets/translations/en.json
{
  "app_name": "Kitcha",
  "home": {
    "title": "Home",
    "search_hint": "Search recipes...",
    "categories": "Categories",
    "popular": "Popular Recipes"
  },
  "recipe": {
    "ingredients": "Ingredients",
    "instructions": "Instructions",
    "prep_time": "Prep Time",
    "cook_time": "Cook Time",
    "servings": "Servings",
    "calories": "Calories",
    "add_to_favorites": "Add to Favorites",
    "add_to_shopping_list": "Add to Shopping List",
    "share": "Share"
  },
  "profile": {
    "level": "Level",
    "xp": "XP",
    "badges": "Badges",
    "stats": "Statistics"
  },
  "premium": {
    "title": "Go Premium",
    "unlimited_analyses": "Unlimited Calorie Analyses",
    "no_ads": "Ad-Free Experience",
    "ai_features": "AI-Powered Features",
    "monthly": "Monthly",
    "lifetime": "Lifetime",
    "restore": "Restore Purchases"
  }
}

// assets/translations/tr.json
{
  "app_name": "Kitcha",
  "home": {
    "title": "Ana Sayfa",
    "search_hint": "Tarif ara...",
    "categories": "Kategoriler",
    "popular": "Popüler Tarifler"
  },
  "recipe": {
    "ingredients": "Malzemeler",
    "instructions": "Tarif",
    "prep_time": "Hazırlık Süresi",
    "cook_time": "Pişirme Süresi",
    "servings": "Porsiyon",
    "calories": "Kalori",
    "add_to_favorites": "Favorilere Ekle",
    "add_to_shopping_list": "Alışveriş Listesine Ekle",
    "share": "Paylaş"
  },
  "profile": {
    "level": "Seviye",
    "xp": "XP",
    "badges": "Rozetler",
    "stats": "İstatistikler"
  },
  "premium": {
    "title": "Premium'a Geç",
    "unlimited_analyses": "Sınırsız Kalori Hesaplama",
    "no_ads": "Reklamsız Deneyim",
    "ai_features": "Yapay Zeka Özellikleri",
    "monthly": "Aylık",
    "lifetime": "Ömür Boyu",
    "restore": "Satın Alımları Geri Yükle"
  }
}
```

**main.dart setup:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('tr', 'TR'),
        Locale('de', 'DE'),
        Locale('fr', 'FR'),
        Locale('es', 'ES'),
        Locale('ar', 'SA'),
        Locale('ru', 'RU'),
        Locale('pt', 'BR'),
        Locale('it', 'IT'),
        Locale('ja', 'JP'),
        Locale('ko', 'KR'),
        Locale('zh', 'CN'),
        Locale('hi', 'IN'),
        Locale('nl', 'NL'),
        Locale('pl', 'PL'),
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'app_name'.tr(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: HomeScreen(),
    );
  }
}
```

**Kullanım:**

```dart
// Text widget'larda
Text('home.title'.tr())
Text('recipe.ingredients'.tr())

// Parametre ile
Text('greeting'.tr(args: ['John'])) // "Hello, John!"

// Çoğul
Text('items_count'.plural(5)) // "5 items"
```

**4.2 Translation API Integration (İsteğe bağlı)**

```dart
// lib/services/translation_api.dart
class TranslationApi {
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  static const String _apiKey = 'YOUR_API_KEY';
  
  Future<String> translate(
    String text,
    String targetLanguage,
    {String sourceLanguage = 'auto'},
  ) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': text,
        'target': targetLanguage,
        'source': sourceLanguage,
        'key': _apiKey,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['translations'][0]['translatedText'];
    } else {
      throw Exception('Translation failed');
    }
  }
  
  Future<Map<String, String>> translateBatch(
    List<String> texts,
    String targetLanguage,
  ) async {
    final translations = <String, String>{};
    
    for (var text in texts) {
      final translated = await translate(text, targetLanguage);
      translations[text] = translated;
    }
    
    return translations;
  }
}

// lib/services/translation_service.dart
class TranslationService {
  final TranslationApi _api = TranslationApi();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<String> getTranslation(
    String text,
    String targetLanguage,
  ) async {
    // 1. Check cache first
    final cached = await _getCachedTranslation(text, targetLanguage);
    if (cached != null) return cached;
    
    // 2. Call API
    final translated = await _api.translate(text, targetLanguage);
    
    // 3. Cache it
    await _cacheTranslation(text, targetLanguage, translated);
    
    return translated;
  }
  
  Future<String?> _getCachedTranslation(String text, String lang) async {
    final hash = _hash(text);
    final doc = await _firestore
        .collection('translation_cache')
        .doc('$hash\_$lang')
        .get();
    
    return doc.data()?['translation'];
  }
  
  Future<void> _cacheTranslation(String text, String lang, String translation) async {
    final hash = _hash(text);
    await _firestore
        .collection('translation_cache')
        .doc('$hash\_$lang')
        .set({
      'text': text,
      'language': lang,
      'translation': translation,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  String _hash(String text) {
    // Simple hash function
    return text.hashCode.abs().toString();
  }
}
```

**4.3 RTL Language Support**

```dart
// lib/utils/app_theme.dart
class AppTheme {
  static ThemeData getTheme(Locale locale, bool isDark) {
    final isRTL = ['ar', 'fa', 'he'].contains(locale.languageCode);
    
    return ThemeData(
      // ... other theme properties
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
    );
  }
}

// Kullanım
MaterialApp(
  theme: AppTheme.getTheme(context.locale, false),
  darkTheme: AppTheme.getTheme(context.locale, true),
  // ...
)
```

**4.4 Custom Turkish Recipe Database**

```dart
// lib/services/recipe_database_service.dart
class RecipeDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Seed initial Turkish recipes
  Future<void> seedTurkishRecipes() async {
    final recipes = [
      {
        'id': 'tr_001',
        'titleTR': 'İskender Kebap',
        'titleEN': 'Iskender Kebab',
        'category': 'Ana Yemek',
        'difficulty': 'Orta',
        'prepTime': 30,
        'cookTime': 45,
        'servings': 4,
        'calories': 650,
        'ingredients': [
          {'name': 'kuzu eti', 'quantity': '500g'},
          {'name': 'pide', 'quantity': '2 adet'},
          {'name': 'tereyağı', 'quantity': '50g'},
          {'name': 'domates', 'quantity': '3 adet'},
          {'name': 'yoğurt', 'quantity': '200g'},
        ],
        'instructions': [
          'Kuzu etini ince doğrayın',
          'Pideyi küp şeklinde kesin',
          'Yoğurdu çırpın',
          'Domates sosu hazırlayın',
          'Pidenin üzerine eti yerleştirin',
          'Domates sosu ve tereyağı dökün',
          'Yoğurtla servis edin',
        ],
        'imageUrl': 'https://example.com/iskender.jpg',
        'tags': ['kebap', 'et', 'türk mutfağı'],
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'tr_002',
        'titleTR': 'Menemen',
        'titleEN': 'Turkish Scrambled Eggs',
        'category': 'Kahvaltı',
        'difficulty': 'Kolay',
        'prepTime': 10,
        'cookTime': 15,
        'servings': 2,
        'calories': 280,
        'ingredients': [
          {'name': 'yumurta', 'quantity': '4 adet'},
          {'name': 'domates', 'quantity': '2 adet'},
          {'name': 'yeşil biber', 'quantity': '2 adet'},
          {'name': 'soğan', 'quantity': '1 adet'},
          {'name': 'zeytinyağı', 'quantity': '2 yemek kaşığı'},
        ],
        'instructions': [
          'Sebzeleri doğrayın',
          'Yağda kavurun',
          'Yumurtaları ekleyin',
          'Karıştırarak pişirin',
        ],
        'imageUrl': 'https://example.com/menemen.jpg',
        'tags': ['kahvaltı', 'yumurta', 'kolay'],
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      // ... 50-100 more Turkish recipes
    ];
    
    final batch = _firestore.batch();
    
    for (var recipe in recipes) {
      final docRef = _firestore.collection('recipes_database').doc(recipe['id'] as String);
      batch.set(docRef, recipe);
    }
    
    await batch.commit();
  }
  
  // Search recipes (Algolia integration)
  Future<List<Recipe>> searchRecipes(String query, String language) async {
    // If using Algolia
    // return await AlgoliaService().search(query, language);
    
    // Fallback: Firestore query
    final field = language == 'tr' ? 'titleTR' : 'titleEN';
    
    final snapshot = await _firestore
        .collection('recipes_database')
        .where(field, isGreaterThanOrEqualTo: query)
        .where(field, isLessThanOrEqualTo: query + '\uf8ff')
        .limit(20)
        .get();
    
    return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
  }
  
  // Get recipe by ID
  Future<Recipe?> getRecipe(String id) async {
    final doc = await _firestore.collection('recipes_database').doc(id).get();
    if (!doc.exists) return null;
    return Recipe.fromFirestore(doc);
  }
  
  // Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final snapshot = await _firestore
        .collection('recipes_database')
        .where('category', isEqualTo: category)
        .limit(20)
        .get();
    
    return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
  }
  
  // Get premium recipes
  Future<List<Recipe>> getPremiumRecipes() async {
    final snapshot = await _firestore
        .collection('recipes_database')
        .where('isPremium', isEqualTo: true)
        .limit(20)
        .get();
    
    return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
  }
}
```

**4.5 Algolia Integration (Advanced Search)**

```yaml
# pubspec.yaml
dependencies:
  algolia: ^1.1.1
```

```dart
// lib/services/algolia_service.dart
class AlgoliaService {
  final Algolia _algolia = Algolia.init(
    applicationId: 'YOUR_APP_ID',
    apiKey: 'YOUR_SEARCH_KEY',
  );
  
  Future<List<Recipe>> search(String query, String language) async {
    final algoliaQuery = _algolia.instance
        .index('recipes')
        .query(query)
        .setHitsPerPage(20)
        .filters('language:$language');
    
    final snapshot = await algoliaQuery.getObjects();
    
    return snapshot.hits.map((hit) {
      return Recipe.fromJson(hit.data);
    }).toList();
  }
  
  Future<List<Recipe>> searchByIngredients(List<String> ingredients) async {
    final query = ingredients.join(' OR ');
    
    final algoliaQuery = _algolia.instance
        .index('recipes')
        .query(query)
        .setHitsPerPage(50);
    
    final snapshot = await algoliaQuery.getObjects();
    
    // Score by ingredient match count
    final recipes = snapshot.hits.map((hit) {
      return Recipe.fromJson(hit.data);
    }).toList();
    
    recipes.sort((a, b) {
      final aMatchCount = _countMatches(a.ingredients, ingredients);
      final bMatchCount = _countMatches(b.ingredients, ingredients);
      return bMatchCount.compareTo(aMatchCount);
    });
    
    return recipes;
  }
  
  int _countMatches(List<String> recipeIngredients, List<String> userIngredients) {
    int count = 0;
    for (var userIngredient in userIngredients) {
      for (var recipeIngredient in recipeIngredients) {
        if (recipeIngredient.toLowerCase().contains(userIngredient.toLowerCase())) {
          count++;
          break;
        }
      }
    }
    return count;
  }
}
```

---

### PHASE 5: Premium Polish

#### **Hedef:** Premium kullanıcı deneyimi iyileştirmeleri

**5.1 Haptic Feedback System**

```yaml
# pubspec.yaml
dependencies:
  vibration: ^1.8.4
```

```dart
// lib/services/haptic_service.dart
class HapticService {
  static Future<void> light() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 10);
    }
  }
  
  static Future<void> medium() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 20);
    }
  }
  
  static Future<void> heavy() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 40);
    }
  }
  
  static Future<void> success() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 50, 100, 50], intensities: [128, 255, 128, 255]);
    }
  }
  
  static Future<void> error() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 100, 100, 100], intensities: [255, 255, 255, 255]);
    }
  }
}

// Kullanım:
onPressed: () {
  HapticService.medium();
  // ... action
}

onFavoriteAdd: () {
  HapticService.success();
  // ... add to favorites
}
```

**5.2 Wake Lock (Pişirme Modu)**

```yaml
# pubspec.yaml
dependencies:
  wakelock_plus: ^1.2.0
```

```dart
// lib/screens/recipe_detail_screen.dart
class RecipeDetailScreen extends StatefulWidget {
  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isCookingMode = false;
  
  @override
  void dispose() {
    if (_isCookingMode) {
      WakelockPlus.disable();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: Icon(_isCookingMode ? Icons.lightbulb : Icons.lightbulb_outline),
            tooltip: _isCookingMode ? 'Pişirme Modunu Kapat' : 'Pişirme Modu',
            onPressed: () {
              setState(() {
                _isCookingMode = !_isCookingMode;
              });
              
              if (_isCookingMode) {
                WakelockPlus.enable();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pişirme modu aktif - Ekran açık kalacak'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                WakelockPlus.disable();
              }
              
              HapticService.medium();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
```

**5.3 Micro Animations**

```dart
// lib/widgets/animated_counter.dart
class AnimatedCounter extends StatelessWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  
  const AnimatedCounter({
    required this.value,
    this.duration = const Duration(milliseconds: 500),
    this.style,
  });
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }
}

// lib/widgets/animated_favorite_button.dart
class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onPressed;
  
  const AnimatedFavoriteButton({
    required this.isFavorite,
    required this.onPressed,
  });
  
  @override
  _AnimatedFavoriteButtonState createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: widget.isFavorite ? Colors.red : null,
        ),
        onPressed: () {
          _controller.forward(from: 0);
          HapticService.medium();
          widget.onPressed();
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// lib/widgets/shimmer_skeleton.dart
class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  
  const ShimmerSkeleton({
    required this.width,
    required this.height,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Kullanım:
ListView.builder(
  itemCount: _isLoading ? 5 : recipes.length,
  itemBuilder: (context, index) {
    if (_isLoading) {
      return ShimmerSkeleton(width: double.infinity, height: 200);
    }
    return RecipeCard(recipe: recipes[index]);
  },
)
```

---

### PHASE 6: UX Enhancements 

**6.1 Dynamic Portion Calculator**

```dart
// lib/widgets/portion_calculator.dart
class PortionCalculator extends StatefulWidget {
  final Recipe recipe;
  final Function(int newServings) onServingsChanged;
  
  const PortionCalculator({
    required this.recipe,
    required this.onServingsChanged,
  });
  
  @override
  _PortionCalculatorState createState() => _PortionCalculatorState();
}

class _PortionCalculatorState extends State<PortionCalculator> {
  late int _servings;
  
  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFF6347).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.people, color: Color(0xFFFF6347)),
          SizedBox(width: 12),
          Text(
            'Porsiyon:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: _servings > 1 ? () => _updateServings(_servings - 1) : null,
          ),
          AnimatedCounter(
            value: _servings,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6347),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () => _updateServings(_servings + 1),
          ),
        ],
      ),
    );
  }
  
  void _updateServings(int newServings) {
    setState(() {
      _servings = newServings;
    });
    widget.onServingsChanged(newServings);
    HapticService.light();
  }
}

// Kullanım:
class RecipeDetailScreen extends StatefulWidget {
  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late int _currentServings;
  
  @override
  void initState() {
    super.initState();
    _currentServings = widget.recipe.servings;
  }
  
  @override
  Widget build(BuildContext context) {
    final multiplier = _currentServings / widget.recipe.servings;
    
    return ListView(
      children: [
        PortionCalculator(
          recipe: widget.recipe,
          onServingsChanged: (newServings) {
            setState(() {
              _currentServings = newServings;
            });
          },
        ),
        
        // Ingredients with adjusted quantities
        ...widget.recipe.ingredients.map((ingredient) {
          final adjustedQuantity = _adjustQuantity(
            ingredient.quantity,
            multiplier,
          );
          
          return ListTile(
            title: Text(ingredient.name),
            trailing: Text(adjustedQuantity),
          );
        }),
      ],
    );
  }
  
  String _adjustQuantity(String? quantity, double multiplier) {
    if (quantity == null) return '';
    
    // Extract number from quantity string
    final regex = RegExp(r'(\d+\.?\d*)');
    final match = regex.firstMatch(quantity);
    
    if (match != null) {
      final number = double.parse(match.group(1)!);
      final adjusted = (number * multiplier).toStringAsFixed(1);
      return quantity.replaceFirst(match.group(1)!, adjusted);
    }
    
    return quantity;
  }
}
```

**6.2 AMOLED Dark Mode**

```dart
// lib/utils/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFFFF6347),
    scaffoldBackgroundColor: Colors.white,
    // ...
  );
  
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFFFF6347),
    scaffoldBackgroundColor: Color(0xFF121212),
    // ...
  );
  
  static ThemeData amoledTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFFFF6347),
    scaffoldBackgroundColor: Colors.black, // Pure black for AMOLED
    cardColor: Color(0xFF0A0A0A),
    dividerColor: Color(0xFF1A1A1A),
    // ...
  );
}

// Settings screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('Tema'),
          trailing: DropdownButton<String>(
            value: _currentTheme,
            items: [
              DropdownMenuItem(value: 'light', child: Text('Açık')),
              DropdownMenuItem(value: 'dark', child: Text('Koyu')),
              DropdownMenuItem(value: 'amoled', child: Text('AMOLED')),
            ],
            onChanged: (value) {
              // Save preference and update theme
              _updateTheme(value!);
            },
          ),
        ),
      ],
    );
  }
}
```

**6.3 Interactive Empty States**

```dart
// lib/widgets/kitcha_empty_state.dart
class KitchaEmptyState extends StatelessWidget {
  final String animationAsset;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  
  const KitchaEmptyState({
    required this.animationAsset,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            animationAsset,
            width: 200,
            height: 200,
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          if (actionText != null && onAction != null) ...[
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6347),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Kullanım:
// Favorites boş
KitchaEmptyState(
  animationAsset: 'assets/animations/empty_favorites.json',
  title: 'Henüz Favori Yok',
  description: 'Beğendiğin tarifleri favorilere ekleyerek buradan hızlıca ulaşabilirsin',
  actionText: 'Tarif Keşfet',
  onAction: () => Navigator.pushNamed(context, '/explore'),
)

// Shopping list boş
KitchaEmptyState(
  animationAsset: 'assets/animations/empty_shopping_cart.json',
  title: 'Alışveriş Listeniz Boş',
  description: 'Tariflerden malzeme ekleyin veya manuel olarak ekleyin',
  actionText: 'Malzeme Ekle',
  onAction: () => _showAddItemDialog(),
)
```

**6.4 Onboarding Flow**

```yaml
# pubspec.yaml
dependencies:
  introduction_screen: ^3.1.12
```

```dart
// lib/screens/onboarding_screen.dart
class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Tarif Keşfet",
          body: "Binlerce tarif arasından sana uygun olanı bul",
          image: Center(
            child: Image.asset('assets/images/onboarding_1.png', height: 250),
          ),
        ),
        PageViewModel(
          title: "Kalori Hesapla",
          body: "Fotoğraf çekerek kalori ve besin değerlerini öğren",
          image: Center(
            child: Image.asset('assets/images/onboarding_2.png', height: 250),
          ),
        ),
        PageViewModel(
          title: "AI ile Pişir",
          body: "Elindeki malzemelerden tarif önerisi al",
          image: Center(
            child: Image.asset('assets/images/onboarding_3.png', height: 250),
          ),
        ),
        PageViewModel(
          title: "Premium'a Geç",
          body: "Sınırsız özelliklerle mutfakta ustalaş",
          image: Center(
            child: Image.asset('assets/images/onboarding_4.png', height: 250),
          ),
        ),
      ],
      onDone: () => _onOnboardingDone(context),
      onSkip: () => _onOnboardingDone(context),
      showSkipButton: true,
      skip: const Text("Geç"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Başla", style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        activeColor: Color(0xFFFF6347),
      ),
    );
  }
  
  void _onOnboardingDone(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }
}
```

**6.5 Image Compression & Optimization**

```yaml
# pubspec.yaml
dependencies:
  flutter_image_compress: ^2.1.0
```

```dart
// lib/services/image_service.dart
class ImageService {
  static Future<File> compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf('.');
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_compressed.jpg";
    
    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 85,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );
    
    return File(result!.path);
  }
  
  static Future<File> compressForCalorieAnalysis(File file) async {
    // Optimize for ML Kit processing
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.path.replaceFirst('.', '_ml.'),
      quality: 90,
      minWidth: 800,
      minHeight: 800,
    );
    
    return File(result!.path);
  }
  
  static Future<Uint8List> compressBytes(Uint8List bytes) async {
    return await FlutterImageCompress.compressWithList(
      bytes,
      quality: 85,
    );
  }
}
```

---

### PHASE 7: Year in Review (Spotify Wrapped Style) 

#### **Hedef:** Kullanıcının yıllık aktivitesini eğlenceli bir şekilde özetle

```dart
// lib/services/user_stats_service.dart
class UserStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<YearInReviewData> generateYearInReview(int year) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not logged in');
    
    // Get user's activity for the year
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .doc(year.toString())
        .get();
    
    if (!snapshot.exists) {
      throw Exception('No data for $year');
    }
    
    final data = snapshot.data()!;
    
    return YearInReviewData(
      year: year,
      totalRecipesViewed: data['totalRecipesViewed'] ?? 0,
      totalFavorites: data['totalFavorites'] ?? 0,
      totalAnalyses: data['totalAnalyses'] ?? 0,
      totalCalories: data['totalCalories'] ?? 0,
      mostViewedCategory: data['mostViewedCategory'] ?? '',
      favoriteRecipe: data['favoriteRecipe'] ?? '',
      topIngredient: data['topIngredient'] ?? '',
      consecutiveDays: data['longestStreak'] ?? 0,
      badgesEarned: data['badgesEarned'] ?? 0,
      xpGained: data['xpGained'] ?? 0,
      monthlyBreakdown: Map<int, int>.from(data['monthlyBreakdown'] ?? {}),
    );
  }
  
  Future<bool> hasEnoughDataForReview(int year) async {
    try {
      final data = await generateYearInReview(year);
      return data.totalRecipesViewed >= 10;
    } catch (e) {
      return false;
    }
  }
}

// lib/models/year_in_review_data.dart
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
  
  YearInReviewData({
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
  
  String get calorieEquivalent {
    // Convert calories to fun equivalents
    final pizzas = (totalCalories / 285).round();
    return '$pizzas pizza';
  }
  
  String get personalityType {
    // Determine user's cooking personality
    if (mostViewedCategory == 'Dessert') {
      return 'Sweet Tooth 🍰';
    } else if (mostViewedCategory == 'Breakfast') {
      return 'Early Bird 🌅';
    } else if (mostViewedCategory == 'Main Course') {
      return 'Home Chef 👨‍🍳';
    } else {
      return 'Foodie Explorer 🌍';
    }
  }
}

// lib/screens/year_in_review_screen.dart
class YearInReviewScreen extends StatefulWidget {
  final YearInReviewData data;
  
  const YearInReviewScreen({required this.data});
  
  @override
  _YearInReviewScreenState createState() => _YearInReviewScreenState();
}

class _YearInReviewScreenState extends State<YearInReviewScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              HapticService.light();
            },
            children: [
              _buildWelcomeSlide(),
              _buildRecipesSlide(),
              _buildCategoriesSlide(),
              _buildCaloriesSlide(),
              _buildStreakSlide(),
              _buildAchievementsSlide(),
              _buildPersonalitySlide(),
              _buildShareSlide(),
            ],
          ),
          
          // Progress indicator
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) {
                return Container(
                  width: 30,
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index <= _currentPage
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          
          // Close button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/confetti.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 40),
          Text(
            '${widget.data.year}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Kitcha Flavor Journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'Kaydır 👉',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecipesSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
          SizedBox(height: 40),
          AnimatedCounter(
            value: widget.data.totalRecipesViewed,
            duration: Duration(seconds: 2),
            style: TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'tarif görüntüledin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 40),
          Text(
            '${widget.data.totalFavorites} tanesini\nfavorilere ekledin 💕',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoriesSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00796B), Color(0xFF004D40)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'En çok ilgilendiğin\nkategori:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 40),
          Text(
            widget.data.mostViewedCategory,
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'En sevdiğin tarif:\n${widget.data.favoriteRecipe}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCaloriesSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department, size: 80, color: Colors.white),
          SizedBox(height: 40),
          AnimatedCounter(
            value: widget.data.totalCalories,
            duration: Duration(seconds: 2),
            style: TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'kalori hesapladın',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'Bu ${widget.data.calorieEquivalent} eder! 🍕',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreakSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.whatshot, size: 80, color: Colors.white),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedCounter(
                value: widget.data.consecutiveDays,
                duration: Duration(seconds: 2),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.local_fire_department, size: 60, color: Colors.orange),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'gün üst üste\nKitcha kullandın',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'İnanılmaz bir tutku! 🔥',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 80, color: Colors.yellow),
          SizedBox(height: 40),
          Text(
            'Bu yıl',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedCounter(
                value: widget.data.badgesEarned,
                duration: Duration(seconds: 2),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'rozet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'kazandın',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 40),
          Text(
            '${widget.data.xpGained} XP topladın 🌟',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPersonalitySlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Senin mutfak\nkişiliğin:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 40),
          Text(
            widget.data.personalityType,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'En çok kullandığın\nmalzeme:\n${widget.data.topIngredient}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShareSlide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6347), Color(0xFFFF4500)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.share, size: 80, color: Colors.white),
          SizedBox(height: 40),
          Text(
            '${widget.data.year} Flavor Journey\'ini\narkadaşlarınla paylaş!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _shareYearInReview,
            icon: Icon(Icons.share),
            label: Text('Paylaş'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFFFF6347),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _shareYearInReview() async {
    final message = '''
🍅 Kitcha ${widget.data.year} Flavor Journey

${widget.data.totalRecipesViewed} tarif görüntüledim
${widget.data.totalFavorites} favori ekledim
${widget.data.totalCalories} kalori hesapladım
${widget.data.consecutiveDays} gün streak! 🔥

Ben bir ${widget.data.personalityType}!

Sen de Kitcha'yı indir, kendi yolculuğunu keşfet!
''';
    
    await Share.share(message);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
```

---

## 🔐 SECURITY & COMPLIANCE

### Data Encryption

```dart
// lib/services/encryption_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final _storage = FlutterSecureStorage();
  
  Future<String> encrypt(String plainText) async {
    final key = await _getOrCreateKey();
    final iv = IV.fromLength(16);
    
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    
    return encrypted.base64;
  }
  
  Future<String> decrypt(String encryptedText) async {
    final key = await _getOrCreateKey();
    final iv = IV.fromLength(16);
    
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    
    return decrypted;
  }
  
  Future<Key> _getOrCreateKey() async {
    String? keyString = await _storage.read(key: 'encryption_key');
    
    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      await _storage.write(key: 'encryption_key', value: key.base64);
      return key;
    }
    
    return Key.fromBase64(keyString);
  }
}
```

### GDPR Compliance - Data Deletion

```dart
// lib/services/data_deletion_service.dart
class DataDeletionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<void> deleteAllUserData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not logged in');
    
    try {
      // 1. Delete Firestore data
      await _deleteFirestoreData(userId);
      
      // 2. Delete Storage files
      await _deleteStorageFiles(userId);
      
      // 3. Anonymize analytics
      await _anonymizeAnalytics(userId);
      
      // 4. Delete auth account
      await _auth.currentUser?.delete();
      
      print('All user data deleted successfully');
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }
  
  Future<void> _deleteFirestoreData(String userId) async {
    // Delete main user document
    await _firestore.collection('users').doc(userId).delete();
    
    // Delete shopping list
    final shoppingListSnapshot = await _firestore
        .collection('shopping_lists')
        .doc(userId)
        .collection('items')
        .get();
    
    for (var doc in shoppingListSnapshot.docs) {
      await doc.reference.delete();
    }
    
    // Delete daily activity
    final activitySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_activity')
        .get();
    
    for (var doc in activitySnapshot.docs) {
      await doc.reference.delete();
    }
    
    // Delete analytics
    final analyticsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .get();
    
    for (var doc in analyticsSnapshot.docs) {
      await doc.reference.delete();
    }
  }
  
  Future<void> _deleteStorageFiles(String userId) async {
    try {
      final userPhotosRef = _storage.ref().child('user_images/$userId');
      final listResult = await userPhotosRef.listAll();
      
      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      print('Error deleting storage files: $e');
    }
  }
  
  Future<void> _anonymizeAnalytics(String userId) async {
    // Set analytics user ID to null
    await FirebaseAnalytics.instance.setUserId(id: null);
  }
}

// Settings screen'de
ElevatedButton(
  onPressed: () async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hesabı Sil'),
        content: Text('Tüm verileriniz kalıcı olarak silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await DataDeletionService().deleteAllUserData();
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  },
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  child: Text('Hesabımı Sil'),
)
```

### Data Export (GDPR)

```dart
// lib/services/data_export_service.dart
class DataExportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<String> exportUserData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not logged in');
    
    final data = <String, dynamic>{};
    
    // User profile
    final userDoc = await _firestore.collection('users').doc(userId).get();
    data['profile'] = userDoc.data();
    
    // Shopping list
    final shoppingListSnapshot = await _firestore
        .collection('shopping_lists')
        .doc(userId)
        .collection('items')
        .get();
    data['shopping_list'] = shoppingListSnapshot.docs
        .map((doc) => doc.data())
        .toList();
    
    // Analytics
    final analyticsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .get();
    data['analytics'] = analyticsSnapshot.docs
        .map((doc) => doc.data())
        .toList();
    
    // Convert to JSON
    final jsonString = jsonEncode(data);
    return jsonString;
  }
  
  Future<void> downloadUserData(BuildContext context) async {
    try {
      final jsonString = await exportUserData();
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/kitcha_data_export.json');
      await file.writeAsString(jsonString);
      
      // Share file
      await Share.shareXFiles([XFile(file.path)]);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verileriniz dışa aktarıldı')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }
}
```

---

## 💾 BACKUP & RECOVERY

```dart
// lib/services/backup_service.dart
class BackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Backup to Cloud Storage
  Future<void> backupToCloud() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not logged in');
    
    // Export data
    final dataExportService = DataExportService();
    final jsonString = await dataExportService.exportUserData();
    
    // Upload to Firebase Storage
    final timestamp = DateTime.now().toIso8601String();
    final storageRef = _storage.ref().child('backups/$userId/$timestamp.json');
    
    await storageRef.putString(jsonString);
    
    // Save backup metadata
    await _firestore.collection('backups').doc(userId).set({
      'lastBackup': FieldValue.serverTimestamp(),
      'backupPath': 'backups/$userId/$timestamp.json',
    }, SetOptions(merge: true));
  }
  
  // Restore from Cloud Storage
  Future<void> restoreFromCloud() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not logged in');
    
    // Get backup metadata
    final backupDoc = await _firestore.collection('backups').doc(userId).get();
    if (!backupDoc.exists) {
      throw Exception('No backup found');
    }
    
    final backupPath = backupDoc.data()?['backupPath'];
    if (backupPath == null) {
      throw Exception('Invalid backup path');
    }
    
    // Download backup
    final storageRef = _storage.ref().child(backupPath);
    final jsonString = await storageRef.getData();
    
    if (jsonString == null) {
      throw Exception('Failed to download backup');
    }
    
    // Parse data
    final data = jsonDecode(utf8.decode(jsonString));
    
    // Restore data
    await _restoreUserData(userId, data);
  }
  
  Future<void> _restoreUserData(String userId, Map<String, dynamic> data) async {
    // Restore profile
    if (data['profile'] != null) {
      await _firestore.collection('users').doc(userId).set(
        data['profile'],
        SetOptions(merge: true),
      );
    }
    
    // Restore shopping list
    if (data['shopping_list'] != null) {
      final batch = _firestore.batch();
      
      for (var item in data['shopping_list']) {
        final docRef = _firestore
            .collection('shopping_lists')
            .doc(userId)
            .collection('items')
            .doc(item['id']);
        
        batch.set(docRef, item);
      }
      
      await batch.commit();
    }
    
    // Restore analytics
    if (data['analytics'] != null) {
      final batch = _firestore.batch();
      
      for (var analytic in data['analytics']) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('analytics')
            .doc(analytic['year'].toString());
        
        batch.set(docRef, analytic);
      }
      
      await batch.commit();
    }
  }
  
  // Auto-backup (scheduled)
  Future<void> scheduleAutoBackup() async {
    // Check if auto-backup is enabled
    final prefs = await SharedPreferences.getInstance();
    final autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? false;
    
    if (!autoBackupEnabled) return;
    
    // Check last backup time
    final lastBackup = prefs.getInt('last_auto_backup') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSince = (now - lastBackup) / (1000 * 60 * 60 * 24);
    
    // Backup every 7 days
    if (daysSince >= 7) {
      await backupToCloud();
      await prefs.setInt('last_auto_backup', now);
    }
  }
}
```

---

Bu PART 3 dosyasında şunları tamamladık:
1. ✅ PHASE 3: Seasonal Themes
2. ✅ PHASE 4: Multilingual & Content
3. ✅ PHASE 5: Premium Polish
4. ✅ PHASE 6: UX Enhancements
5. ✅ PHASE 7: Year in Review
6. ✅ Security & Compliance
7. ✅ Backup & Recovery

**PART 4'te ne olacak:**
- DevOps & CI/CD
- Monitoring & Logging
- Marketing & ASO
- Test Stratejisi (Unit, Widget, Integration)
- Deployment Planı
- Performans Optimizasyonları
- Offline-First Architecture
- Widget Testing detayları

## COMPLETE & COMPREHENSIVE EDITION - PART 4 (FINAL)

**Final Bölüm - DevOps, Testing, Marketing, Deployment & Best Practices**

---

## 🚀 DEVOPS & CI/CD

### GitHub Actions CI/CD Pipeline

```yaml
# .github/workflows/main.yml
name: Flutter CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
  
  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{secrets.FIREBASE_APP_ID_ANDROID}}
          token: ${{secrets.FIREBASE_TOKEN}}
          groups: beta-testers
          file: build/app/outputs/bundle/release/app-release.aab
  
  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
      
      - name: Upload to TestFlight
        # Configure fastlane or similar
        run: echo "Upload to TestFlight"
```

### Codemagic Alternative (Recommended for Flutter)

```yaml
# codemagic.yaml
workflows:
  android-workflow:
    name: Android Workflow
    max_build_duration: 60
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
    scripts:
      - name: Get dependencies
        script: flutter pub get
      
      - name: Run tests
        script: flutter test
      
      - name: Build APK
        script: flutter build apk --release
      
      - name: Build App Bundle
        script: flutter build appbundle --release
    
    artifacts:
      - build/**/outputs/**/*.apk
      - build/**/outputs/**/*.aab
    
    publishing:
      email:
        recipients:
          - developer@kitcha.app
      
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
        in_app_update_priority: 0
  
  ios-workflow:
    name: iOS Workflow
    max_build_duration: 60
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
    scripts:
      - name: Get dependencies
        script: flutter pub get
      
      - name: Run tests
        script: flutter test
      
      - name: Build IPA
        script: flutter build ipa --release
    
    artifacts:
      - build/ios/ipa/*.ipa
    
    publishing:
      email:
        recipients:
          - developer@kitcha.app
      
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
```

---

## 📊 MONITORING & LOGGING

### Sentry Integration (Recommended)

```yaml
# pubspec.yaml
dependencies:
  sentry_flutter: ^7.14.0
```

```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.tracesSampleRate = 1.0;
      options.environment = kDebugMode ? 'development' : 'production';
      options.beforeSend = (event, hint) {
        // Filter out events
        if (event.level == SentryLevel.info) {
          return null;
        }
        return event;
      };
    },
    appRunner: () => runApp(MyApp()),
  );
}

// Error handling
try {
  // ... code
} catch (exception, stackTrace) {
  await Sentry.captureException(
    exception,
    stackTrace: stackTrace,
    hint: Hint()..set('context', 'Recipe loading'),
  );
}
```

### Custom Logging Service

```dart
// lib/services/logger_service.dart
import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: kDebugMode ? Level.debug : Level.error,
  );
  
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }
  
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }
  
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
    
    // Send to Sentry in production
    if (!kDebugMode) {
      Sentry.captureException(
        error ?? Exception(message),
        stackTrace: stackTrace,
      );
    }
  }
  
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error, stackTrace);
    
    // Always send fatal errors to Sentry
    Sentry.captureException(
      error ?? Exception(message),
      stackTrace: stackTrace,
    );
  }
}

// Usage:
LoggerService.info('Recipe loaded: ${recipe.title}');
LoggerService.error('Failed to load recipe', error, stackTrace);
```

### Firebase Performance Monitoring

```dart
// lib/services/performance_service.dart
class PerformanceService {
  static Future<T> trace<T>(
    String traceName,
    Future<T> Function() operation,
  ) async {
    final trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();
    
    try {
      final result = await operation();
      trace.putAttribute('success', 'true');
      return result;
    } catch (e) {
      trace.putAttribute('success', 'false');
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }
  
  static HttpMetric newHttpMetric(String url, HttpMethod method) {
    return FirebasePerformance.instance.newHttpMetric(url, method);
  }
}

// Usage:
final recipes = await PerformanceService.trace(
  'load_recipes',
  () => _recipeService.getRecipes(),
);

// HTTP metrics
final metric = PerformanceService.newHttpMetric(
  'https://api.example.com/recipes',
  HttpMethod.Get,
);
await metric.start();
// ... make request
metric.responseCode = 200;
await metric.stop();
```

---

## 🧪 TEST STRATEGY

### Unit Tests

```dart
// test/unit/gamification_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirebaseFirestore, FirebaseAuth])
void main() {
  group('GamificationService', () {
    late GamificationService service;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    
    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      service = GamificationService(
        firestore: mockFirestore,
        auth: mockAuth,
      );
    });
    
    test('addXP increases user XP', () async {
      // Arrange
      final userId = 'test_user';
      when(mockAuth.currentUser?.uid).thenReturn(userId);
      
      final userRef = mockFirestore.collection('users').doc(userId);
      when(userRef.get()).thenAnswer((_) async => MockDocumentSnapshot({
        'totalXP': 100,
      }));
      
      // Act
      await service.addXP(50, reason: 'test');
      
      // Assert
      verify(userRef.update({'totalXP': 150})).called(1);
    });
    
    test('_calculateLevel returns correct level', () {
      expect(service.calculateLevel(0), 1);
      expect(service.calculateLevel(50), 2);
      expect(service.calculateLevel(150), 3);
      expect(service.calculateLevel(2000), 7);
    });
    
    test('badge unlock triggers notification', () async {
      // Arrange
      final userId = 'test_user';
      when(mockAuth.currentUser?.uid).thenReturn(userId);
      
      // Mock user data
      when(mockFirestore.collection('users').doc(userId).get())
          .thenAnswer((_) async => MockDocumentSnapshot({
        'totalRecipesViewed': 50,
        'badges': [],
      }));
      
      // Act
      await service._checkBadgeUnlocks(userId);
      
      // Assert
      verify(mockFirestore.collection('users').doc(userId).update({
        'badges': contains('foodie'),
      })).called(1);
    });
  });
}
```

### Widget Tests

```dart
// test/widget/premium_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('PremiumScreen', () {
    testWidgets('displays pricing cards', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => SubscriptionProvider(),
            child: PremiumScreen(),
          ),
        ),
      );
      
      // Verify pricing cards exist
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Lifetime'), findsOneWidget);
      expect(find.text('₺39.99'), findsOneWidget);
      expect(find.text('₺299.99'), findsOneWidget);
    });
    
    testWidgets('shows feature comparison', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => SubscriptionProvider(),
            child: PremiumScreen(),
          ),
        ),
      );
      
      // Verify features are listed
      expect(find.text('Basic Recipes'), findsOneWidget);
      expect(find.text('Calorie Calculator'), findsOneWidget);
      expect(find.text('Ads'), findsOneWidget);
      expect(find.text('Meal Planner'), findsOneWidget);
    });
    
    testWidgets('tapping monthly button calls buyMonthly', (WidgetTester tester) async {
      final mockProvider = MockSubscriptionProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SubscriptionProvider>.value(
            value: mockProvider,
            child: PremiumScreen(),
          ),
        ),
      );
      
      // Find and tap monthly button
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      
      // Verify method was called
      verify(mockProvider.buyMonthly()).called(1);
    });
  });
}
```

### Integration Tests

```dart
// integration_test/freemium_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Freemium Flow', () {
    testWidgets('guest user can browse recipes but not favorite', (tester) async {
      // Launch app as guest
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Should see home screen
      expect(find.text('Home'), findsOneWidget);
      
      // Tap on a recipe
      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();
      
      // Should see recipe details
      expect(find.byType(RecipeDetailScreen), findsOneWidget);
      
      // Try to favorite (should show login prompt)
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      
      // Should show login bottom sheet
      expect(find.byType(LoginBottomSheet), findsOneWidget);
      expect(find.text('Bu özellik'), findsOneWidget);
    });
    
    testWidgets('free user hits calorie calculation limit', (tester) async {
      // Launch app as logged in free user
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Navigate to calorie calculator
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();
      
      // Use it once (allowed)
      // ... take photo and analyze
      
      // Try to use again (should show premium paywall)
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();
      
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Günlük Limit Aşıldı'), findsOneWidget);
    });
    
    testWidgets('premium purchase flow', (tester) async {
      // Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Navigate to premium screen
      await tester.tap(find.text('Premium'));
      await tester.pumpAndSettle();
      
      // Should see premium screen
      expect(find.byType(PremiumScreen), findsOneWidget);
      
      // Tap lifetime purchase
      await tester.tap(find.text('Lifetime'));
      await tester.pumpAndSettle();
      
      // Should trigger purchase flow
      // (In test environment, this will be mocked)
    });
  });
}
```

### Golden Tests (Visual Regression)

```dart
// test/golden/recipe_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('RecipeCard Golden Tests', () {
    testGoldens('RecipeCard renders correctly', (tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'Test Recipe',
        imageUrl: 'https://example.com/image.jpg',
        prepTime: 30,
        calories: 500,
      );
      
      await tester.pumpWidgetBuilder(
        RecipeCard(recipe: recipe),
        surfaceSize: Size(400, 300),
      );
      
      await screenMatchesGolden(tester, 'recipe_card_default');
    });
    
    testGoldens('RecipeCard dark mode', (tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'Test Recipe',
        imageUrl: 'https://example.com/image.jpg',
        prepTime: 30,
        calories: 500,
      );
      
      await tester.pumpWidgetBuilder(
        RecipeCard(recipe: recipe),
        surfaceSize: Size(400, 300),
        wrapper: materialAppWrapper(
          theme: ThemeData.dark(),
        ),
      );
      
      await screenMatchesGolden(tester, 'recipe_card_dark');
    });
  });
}
```

### Test Coverage Target

```bash
# Generate coverage report
flutter test --coverage

# View coverage (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Coverage targets:
# - Overall: 80%
# - Services: 90%
# - Widgets: 80%
# - Screens: 70%
# - Models: 95%
```

---

## 📱 MARKETING & ASO (App Store Optimization)

### App Store Listing

**Title (30 characters max):**
- EN: "Kitcha: AI Recipe & Calorie"
- TR: "Kitcha: Yapay Zeka Tarifler"

**Subtitle (30 characters max):**
- EN: "Smart Kitchen Companion"
- TR: "Akıllı Mutfak Asistanı"

**Keywords (100 characters max):**
- EN: recipe,calorie,diet,meal plan,AI,nutrition,cooking,food,healthy,tracker
- TR: tarif,kalori,diyet,yemek,yapay zeka,beslenme,pişirme,sağlıklı

**Description (4000 characters max):**

```
🍅 Kitcha - Your Smart Kitchen Companion

Transform your cooking experience with Kitcha, the AI-powered app that makes meal planning effortless!

✨ KEY FEATURES:

📖 RECIPE DISCOVERY
• Browse thousands of delicious recipes
• Smart search by ingredients, category, or cuisine
• Save favorites for quick access
• Get personalized recommendations

📸 SNAP & COOK AI
• Take a photo of your fridge or pantry
• AI automatically detects ingredients
• Get instant recipe suggestions
• Never waste food again!

🔥 SMART CALORIE TRACKER
• Snap a photo of any meal
• Get instant calorie & nutrition info
• Track your daily intake
• Achieve your health goals

🛒 SHOPPING LIST
• One-tap ingredient additions from recipes
• Auto-organized by category
• Share with family & friends
• Never forget an item

🏆 GAMIFICATION
• Earn XP for cooking
• Unlock badges & achievements
• Compete on leaderboards
• Level up your cooking skills

⭐ PREMIUM FEATURES:
• Unlimited AI scans
• Ad-free experience
• Advanced meal planning
• Priority support

🌍 MULTILINGUAL
Available in 15+ languages

🎨 BEAUTIFUL UI
• Dark mode & AMOLED support
• Smooth animations
• Intuitive navigation

📊 PRIVACY FIRST
• Your data, your control
• GDPR compliant
• Secure encryption

Download Kitcha today and start your culinary journey! 🍳

---

🇹🇷 TÜRKÇE AÇIKLAMA:

Kitcha ile mutfakta yapay zeka gücünü deneyimleyin!

Özellikler:
✓ Binlerce Türkçe tarif
✓ AI ile malzeme tanıma
✓ Kalori hesaplama
✓ Alışveriş listesi
✓ Rozet & sıralama sistemi

Hemen indirin! 🍅
```

**Screenshots (Required: 5-8 per platform):**

1. **Hero Shot:** App icon + "Smart Kitchen Companion" tagline
2. **Recipe Discovery:** Beautiful recipe grid with search
3. **AI Camera:** Camera interface with detected ingredients
4. **Calorie Tracker:** Food photo with nutrition breakdown
5. **Shopping List:** Organized shopping list by category
6. **Gamification:** Profile screen with badges & XP
7. **Premium:** Premium features comparison
8. **(Optional) Seasonal:** App with seasonal theme active

**App Preview Video (15-30 seconds):**
- 0-5s: Logo animation + tagline
- 5-10s: Recipe browsing
- 10-15s: AI ingredient detection
- 15-20s: Calorie calculation
- 20-25s: Gamification highlights
- 25-30s: CTA: "Download Now!"

### Social Media Assets

```
assets/marketing/
├── app_icon_1024x1024.png
├── screenshots/
│   ├── en/
│   │   ├── 1_hero.png (1242x2688)
│   │   ├── 2_recipes.png
│   │   ├── 3_ai_camera.png
│   │   ├── 4_calorie.png
│   │   └── 5_gamification.png
│   └── tr/
│       └── (same structure)
├── social/
│   ├── facebook_cover.png (820x312)
│   ├── instagram_post.png (1080x1080)
│   ├── instagram_story.png (1080x1920)
│   └── twitter_header.png (1500x500)
└── press_kit/
    ├── logo_variations/
    ├── color_palette.pdf
    └── brand_guidelines.pdf
```

### Launch Strategy

**Phase 1: Soft Launch (Turkey) - Week 1-2**
- Release to Google Play & App Store (TR only)
- Target: 1,000 downloads
- Monitor: Crash rate, retention, IAP conversion
- Iterate based on feedback

**Phase 2: Influencer Campaign - Week 3-4**
- Partner with 5-10 Turkish food bloggers/YouTubers
- Provide promo codes for Premium
- Target: 10,000 downloads
- Track: Referral codes, social mentions

**Phase 3: Content Marketing - Week 5-8**
- Blog posts on cooking tips
- YouTube tutorials
- Instagram Reels with recipes
- TikTok viral challenges
- Target: 50,000 downloads

**Phase 4: Paid Ads - Week 9-12**
- Google Ads (Search + Display)
- Facebook/Instagram Ads
- TikTok Ads (if budget allows)
- Budget: $5,000-10,000
- Target: 100,000 downloads
- ROAS goal: 3:1

**Phase 5: Global Expansion - Month 4+**
- Launch in: US, UK, DE, FR, ES
- Localized marketing
- International influencers
- Target: 500,000 downloads (Year 1)

---

## 🎯 KEY PERFORMANCE INDICATORS (KPIs)

### User Acquisition
- DAU (Daily Active Users): Target 10,000 by Month 6
- MAU (Monthly Active Users): Target 50,000 by Month 6
- Install-to-Registration rate: 40%+
- Organic vs Paid: 60/40 split

### Engagement
- Session duration: 5+ minutes
- Sessions per user per week: 3+
- Recipe views per session: 5+
- Feature adoption:
  - Calorie calculator: 60% of users
  - AI Camera: 40% of users
  - Shopping List: 30% of users

### Retention
- Day 1: 40%+
- Day 7: 20%+
- Day 30: 10%+
- Monthly churn: <30%

### Monetization
- Free to Premium conversion: 3-5%
- Monthly subscription renewal: 70%+
- Lifetime purchase rate: 1-2%
- ARPU (Average Revenue Per User): $0.50+
- LTV (Lifetime Value): $10+
- CAC (Customer Acquisition Cost): <$3

### Technical
- Crash-free rate: 99.5%+
- App load time: <3 seconds
- API response time: <500ms
- Image load time: <2 seconds

---

## 🚢 DEPLOYMENT PLAN

### Beta Testing

**TestFlight (iOS) Setup:**
```bash
# 1. Archive app
flutter build ipa --release

# 2. Upload to App Store Connect
# (via Xcode or Transporter app)

# 3. Add beta testers in App Store Connect
# External Testing: 50-100 testers
# Internal Testing: 5-10 team members
```

**Google Play Internal Testing:**
```bash
# 1. Build app bundle
flutter build appbundle --release

# 2. Upload to Google Play Console
# Internal testing track → Upload AAB

# 3. Add testers via email list
# Max 100 testers for internal testing
```

**Firebase App Distribution (Alternative):**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Upload APK
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups beta-testers \
  --release-notes "Beta v1.0 - Initial testing"
```

### Production Release

**Google Play Store:**

1. **Console Setup:**
   - Create app in Google Play Console
   - Fill in store listing
   - Upload screenshots & app icon
   - Set content rating
   - Add privacy policy URL

2. **Release Tracks:**
   - Internal testing → Alpha → Beta → Production
   - Use staged rollout: 10% → 25% → 50% → 100%

3. **Required Files:**
   - App Bundle (AAB)
   - Keystore (keep safe!)
   - google-services.json

4. **Build Command:**
```bash
flutter build appbundle --release \
  --dart-define=ENV=production \
  --dart-define=SPOONACULAR_KEY=$SPOONACULAR_KEY
```

**Apple App Store:**

1. **App Store Connect Setup:**
   - Create app
   - Fill in metadata
   - Upload screenshots
   - Set age rating
   - Add privacy policy

2. **Release Process:**
   - TestFlight → App Review → Release

3. **Required Files:**
   - IPA file
   - Provisioning profiles
   - Push notification certificate
   - GoogleService-Info.plist

4. **Build Command:**
```bash
flutter build ipa --release \
  --dart-define=ENV=production \
  --export-options-plist=ios/ExportOptions.plist
```

### Version Management

```
# Semantic Versioning: MAJOR.MINOR.PATCH

v1.0.0 - Initial release
v1.1.0 - New feature: AI Camera
v1.1.1 - Bug fixes
v1.2.0 - New feature: Gamification
v2.0.0 - Major redesign
```

**pubspec.yaml:**
```yaml
version: 1.0.0+1
# format: VERSION_NAME+BUILD_NUMBER
```

**Update version:**
```bash
# Automatically increment build number
flutter build apk --build-number=$(($(git rev-list --count HEAD)))
```

---

## ⚡ PERFORMANCE OPTIMIZATIONS

### Image Loading

```dart
// lib/widgets/optimized_image.dart
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  
  const OptimizedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
  });
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => ShimmerSkeleton(
        width: width ?? double.infinity,
        height: height ?? 200,
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      memCacheWidth: (width ?? 400).toInt(),
      memCacheHeight: (height ?? 400).toInt(),
      maxWidthDiskCache: 1024,
      maxHeightDiskCache: 1024,
    );
  }
}
```

### List Performance

```dart
// Use AutomaticKeepAliveClientMixin for expensive widgets
class ExpensiveWidget extends StatefulWidget {
  @override
  _ExpensiveWidgetState createState() => _ExpensiveWidgetState();
}

class _ExpensiveWidgetState extends State<ExpensiveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ... expensive build
  }
}

// Use const constructors
const RecipeCard(recipe: recipe)  // ✅ Good
RecipeCard(recipe: recipe)         // ❌ Rebuilds unnecessarily
```

### Lazy Loading

```dart
// Pagination for large lists
class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _scrollController = ScrollController();
  List<Recipe> _recipes = [];
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialRecipes();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreRecipes();
    }
  }
  
  Future<void> _loadInitialRecipes() async {
    final query = FirebaseFirestore.instance
        .collection('recipes')
        .limit(20);
    
    final snapshot = await query.get();
    
    setState(() {
      _recipes = snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    });
  }
  
  Future<void> _loadMoreRecipes() async {
    if (_isLoadingMore || _lastDocument == null) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    final query = FirebaseFirestore.instance
        .collection('recipes')
        .startAfterDocument(_lastDocument!)
        .limit(20);
    
    final snapshot = await query.get();
    
    setState(() {
      _recipes.addAll(
        snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList(),
      );
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _isLoadingMore = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _recipes.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _recipes.length) {
          return Center(child: CircularProgressIndicator());
        }
        return RecipeCard(recipe: _recipes[index]);
      },
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 🌐 OFFLINE-FIRST ARCHITECTURE

### Sync Strategy

```dart
// lib/services/sync_service.dart
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HiveInterface _hive = Hive;
  
  // Queue for offline actions
  final Box<Map> _syncQueue = Hive.box('sync_queue');
  
  Future<void> addToSyncQueue(String action, Map<String, dynamic> data) async {
    await _syncQueue.add({
      'action': action,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  Future<void> syncWhenOnline() async {
    if (!await _isOnline()) return;
    
    final items = _syncQueue.values.toList();
    
    for (var item in items) {
      try {
        await _processSyncItem(item);
        await _syncQueue.delete(item.key);
      } catch (e) {
        LoggerService.error('Sync failed for item', e);
      }
    }
  }
  
  Future<void> _processSyncItem(Map<String, dynamic> item) async {
    final action = item['action'];
    final data = item['data'];
    
    switch (action) {
      case 'add_favorite':
        await _firestore
            .collection('users')
            .doc(data['userId'])
            .collection('favorites')
            .doc(data['recipeId'])
            .set(data);
        break;
      
      case 'add_shopping_item':
        await _firestore
            .collection('shopping_lists')
            .doc(data['userId'])
            .collection('items')
            .doc(data['itemId'])
            .set(data);
        break;
      
      // ... other actions
    }
  }
  
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

// Usage:
Future<void> addToFavorites(Recipe recipe) async {
  // Save locally immediately
  await _hive.box('favorites').put(recipe.id, recipe.toJson());
  
  // Queue for sync
  await SyncService().addToSyncQueue('add_favorite', {
    'userId': _auth.currentUser!.uid,
    'recipeId': recipe.id,
    'recipeData': recipe.toJson(),
  });
  
  // Try to sync now
  await SyncService().syncWhenOnline();
}
```

### Conflict Resolution

```dart
// Last-write-wins strategy
Future<void> resolveConflict(
  String documentId,
  Map<String, dynamic> localData,
  Map<String, dynamic> serverData,
) async {
  final localTimestamp = localData['updatedAt'] as int;
  final serverTimestamp = serverData['updatedAt'] as int;
  
  if (localTimestamp > serverTimestamp) {
    // Local is newer, push to server
    await _firestore.collection('items').doc(documentId).set(localData);
  } else {
    // Server is newer, update local
    await _hive.box('items').put(documentId, serverData);
  }
}
```

## 📸 WIDGET TESTING & GOLDEN TESTS

### Golden Test Setup

```yaml
# pubspec.yaml
dev_dependencies:
  golden_toolkit: ^0.15.0
  flutter_test:
    sdk: flutter
```

### Complete Golden Test Suite

```dart
// test/golden/recipe_card_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  setUpAll(() async {
    // Load fonts for golden tests
    await loadAppFonts();
  });

  group('RecipeCard Golden Tests', () {
    testGoldens('RecipeCard default state', (tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'İskender Kebap',
        imageUrl: 'https://example.com/iskender.jpg',
        prepTime: 30,
        calories: 650,
        category: 'Ana Yemek',
        isFavorite: false,
      );

      await tester.pumpWidgetBuilder(
        RecipeCard(recipe: recipe),
        surfaceSize: Size(400, 300),
      );

      await screenMatchesGolden(tester, 'recipe_card_default');
    });

    testGoldens('RecipeCard with favorite', (tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'İskender Kebap',
        imageUrl: 'https://example.com/iskender.jpg',
        prepTime: 30,
        calories: 650,
        category: 'Ana Yemek',
        isFavorite: true,
      );

      await tester.pumpWidgetBuilder(
        RecipeCard(recipe: recipe),
        surfaceSize: Size(400, 300),
      );

      await screenMatchesGolden(tester, 'recipe_card_favorite');
    });

    testGoldens('RecipeCard dark mode', (tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'İskender Kebap',
        imageUrl: 'https://example.com/iskender.jpg',
        prepTime: 30,
        calories: 650,
        category: 'Ana Yemek',
        isFavorite: false,
      );

      await tester.pumpWidgetBuilder(
        RecipeCard(recipe: recipe),
        surfaceSize: Size(400, 300),
        wrapper: materialAppWrapper(
          theme: ThemeData.dark(),
        ),
      );

      await screenMatchesGolden(tester, 'recipe_card_dark');
    });

    testGoldens('RecipeCard loading state', (tester) async {
      await tester.pumpWidgetBuilder(
        RecipeCardSkeleton(),
        surfaceSize: Size(400, 300),
      );

      await screenMatchesGolden(tester, 'recipe_card_loading');
    });

    testGoldens('RecipeCard premium badge', (tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'Premium Tarif',
        imageUrl: 'https://example.com/premium.jpg',
        prepTime: 45,
        calories: 800,
        category: 'Özel',
        isPremium: true,
        isFavorite: false,
      );

      await tester.pumpWidgetBuilder(
        RecipeCard(recipe: recipe),
        surfaceSize: Size(400, 300),
      );

      await screenMatchesGolden(tester, 'recipe_card_premium');
    });
  });

  group('Premium Screen Golden Tests', () {
    testGoldens('Premium screen default', (tester) async {
      await tester.pumpWidgetBuilder(
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
          child: PremiumScreen(),
        ),
        surfaceSize: Size(400, 800),
      );

      await screenMatchesGolden(tester, 'premium_screen_default');
    });

    testGoldens('Premium screen dark mode', (tester) async {
      await tester.pumpWidgetBuilder(
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
          child: PremiumScreen(),
        ),
        surfaceSize: Size(400, 800),
        wrapper: materialAppWrapper(
          theme: ThemeData.dark(),
        ),
      );

      await screenMatchesGolden(tester, 'premium_screen_dark');
    });
  });

  group('Multi-Device Golden Tests', () {
    final devices = [
      Device.phone,
      Device.iphone11,
      Device.tabletPortrait,
      Device.tabletLandscape,
    ];

    for (final device in devices) {
      testGoldens('HomeScreen on ${device.name}', (tester) async {
        await tester.pumpWidgetBuilder(
          HomeScreen(),
          surfaceSize: device.size,
        );

        await screenMatchesGolden(
          tester,
          'home_screen_${device.name.toLowerCase()}',
        );
      });
    }
  });

  group('Screenshot Regression Tests', () {
    testGoldens('Recipe detail screen', (tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'Menemen',
        imageUrl: 'https://example.com/menemen.jpg',
        prepTime: 15,
        calories: 280,
        ingredients: [
          Ingredient(name: 'Yumurta', quantity: '4 adet'),
          Ingredient(name: 'Domates', quantity: '2 adet'),
          Ingredient(name: 'Biber', quantity: '1 adet'),
        ],
        instructions: [
          'Sebzeleri doğrayın',
          'Yağda kavurun',
          'Yumurtaları ekleyin',
        ],
      );

      await tester.pumpWidgetBuilder(
        RecipeDetailScreen(recipe: recipe),
        surfaceSize: Size(400, 800),
      );

      await screenMatchesGolden(tester, 'recipe_detail_screen');
    });

    testGoldens('Shopping list screen', (tester) async {
      await tester.pumpWidgetBuilder(
        ChangeNotifierProvider(
          create: (_) => ShoppingListProvider()
            ..addItem(name: 'Domates', quantity: '2 kg')
            ..addItem(name: 'Süt', quantity: '1 L'),
          child: ShoppingListScreen(),
        ),
        surfaceSize: Size(400, 800),
      );

      await screenMatchesGolden(tester, 'shopping_list_screen');
    });

    testGoldens('Profile screen with stats', (tester) async {
      await tester.pumpWidgetBuilder(
        ProfileScreen(
          userStats: UserStats(
            totalXP: 1250,
            currentLevel: 5,
            badges: ['foodie', 'analyzer', 'streaker'],
            totalRecipesViewed: 150,
            totalFavorites: 45,
            totalAnalyses: 89,
          ),
        ),
        surfaceSize: Size(400, 800),
      );

      await screenMatchesGolden(tester, 'profile_screen_with_stats');
    });
  });
}
```

### Running Golden Tests

```bash
# Generate golden files (first time)
flutter test --update-goldens

# Run golden tests
flutter test test/golden/

# Update specific golden
flutter test --update-goldens test/golden/recipe_card_golden_test.dart

# Compare and view diffs
# Golden files will be in: test/golden/goldens/
```

### CI/CD Integration for Visual Regression

```yaml
# .github/workflows/golden_tests.yml
name: Golden Tests

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  golden-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Run Golden Tests
        run: flutter test test/golden/
      
      - name: Upload Golden Failures
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: golden-failures
          path: test/golden/failures/
      
      - name: Comment on PR
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '⚠️ Golden tests failed! Please review the differences.'
            })
```


---

## 📋 FINAL CHECKLIST

### Pre-Launch Checklist

**Technical:**
- [ ] All unit tests passing (80%+ coverage)
- [ ] All integration tests passing
- [ ] Performance benchmarks met
- [ ] Crash-free rate >99%
- [ ] App size <50MB
- [ ] No memory leaks
- [ ] Offline mode works
- [ ] All API keys secured
- [ ] Analytics tracking active
- [ ] Push notifications working

**Legal:**
- [ ] Privacy Policy published
- [ ] Terms of Service published
- [ ] GDPR compliance
- [ ] Age rating set correctly
- [ ] All third-party licenses included

**Store Listing:**
- [ ] App icon (all sizes)
- [ ] Screenshots (5-8 per platform)
- [ ] App preview video
- [ ] Description localized
- [ ] Keywords optimized
- [ ] Content rating received

**Marketing:**
- [ ] Landing page live
- [ ] Social media accounts created
- [ ] Press kit prepared
- [ ] Influencer list ready
- [ ] Launch email campaign ready

### Post-Launch Checklist

**Week 1:**
- [ ] Monitor crash reports daily
- [ ] Respond to user reviews
- [ ] Track KPIs (DAU, retention, conversion)
- [ ] Fix critical bugs immediately

**Week 2-4:**
- [ ] Gather user feedback
- [ ] A/B test premium pricing
- [ ] Iterate on onboarding
- [ ] Start influencer outreach

**Month 2-3:**
- [ ] Release v1.1 with improvements
- [ ] Launch referral program
- [ ] Expand marketing budget
- [ ] Plan international expansion

---

## 🎓 BEST PRACTICES SUMMARY

### Code Quality
1. **Always use const constructors** when possible
2. **Prefer composition over inheritance**
3. **Keep widgets small** (<300 lines)
4. **Extract reusable widgets**
5. **Use meaningful variable names**
6. **Comment complex logic**
7. **Follow Effective Dart** style guide

### Architecture
1. **Separate business logic from UI**
2. **Use Provider/Riverpod** for state management
3. **Implement repository pattern** for data access
4. **Use services for business logic**
5. **Keep models immutable** (use Freezed)

### Performance
1. **Use const widgets** everywhere possible
2. **Implement lazy loading** for lists
3. **Cache images** with CachedNetworkImage
4. **Optimize images** before upload
5. **Use indexed Firestore queries**
6. **Implement pagination** for large datasets

### Security
1. **Never commit API keys**
2. **Validate all user inputs**
3. **Encrypt sensitive data**
4. **Use HTTPS only**
5. **Implement rate limiting**
6. **Keep dependencies updated**

### Testing
1. **Write tests first** (TDD when possible)
2. **Test business logic** thoroughly
3. **Mock external dependencies**
4. **Use golden tests** for UI
5. **Automate testing** in CI/CD
6. **Maintain 80%+ coverage**

---

## 📞 SUPPORT & RESOURCES

### Dokümantasyon Linkleri
- [Flutter Docs](https://docs.flutter.dev/)
- [Firebase Flutter](https://firebase.flutter.dev/)
- [RevenueCat Docs](https://docs.revenuecat.com/)
- [Google AdMob](https://developers.google.com/admob/flutter)
- [Sentry Flutter](https://docs.sentry.io/platforms/flutter/)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [r/FlutterDev](https://reddit.com/r/FlutterDev)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

### Design Resources
- [Material Design](https://material.io/)
- [Figma Community](https://www.figma.com/community)
- [Lottie Files](https://lottiefiles.com/)
- [Icons8](https://icons8.com/)

---