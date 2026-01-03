# 🍅 KitchaApp

**AI-Powered Recipe & Calorie Tracking App**

A comprehensive Flutter application for discovering recipes, tracking calories with AI, and engaging with a gamified cooking experience.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.2+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📱 Screenshots

| Home | Recipes | AI Camera | Profile |
|------|---------|-----------|---------|
| 🏠 | 📖 | 📸 | 👤 |

---

## ✨ Features

### 🔍 Recipe Discovery
- **15+ Turkish Recipes** - Authentic Turkish cuisine database
- **Smart Search** - Search by name, ingredients, or category
- **Categories** - Çorba, Ana Yemek, Tatlı, Kahvaltı, and more
- **Recipe Details** - Ingredients, instructions, nutrition info
- **Bilingual Support** - Turkish and English translations

### 📸 AI-Powered Features
- **Snap & Cook AI** - Take photos of ingredients, get recipe suggestions
- **Calorie Calculator** - AI-powered food analysis from photos
- **Ingredient Detection** - ML Kit integration for ingredient recognition
- **Translation Cache** - Cached translations to reduce API costs

### 🎮 Gamification
- **XP System** - Earn XP for recipes viewed, cooked, analyzed
- **Levels** - Progress through levels with increasing rewards
- **Badges** - 25+ badges including:
  - 🍳 İlk Tarif / 🔍 Tarif Kaşifi / 👨‍🍳 Tarif Ustası
  - 📊 İlk Analiz / 🥗 Beslenme Uzmanı
  - 🔥 İlk Seri / ⚡ Haftalık Savaşçı / 💪 Aylık Usta
  - 💎 Premium Üye / 👑 Lifetime Üye
- **Leaderboard** - Compete with other users
- **Weekly Challenges** - Complete challenges for bonus XP
- **Easter Eggs** - 12 hidden badges to discover!

### 🛒 Shopping List
- **Quick Add** - Add ingredients from recipes
- **Categories** - Auto-organized by food type
- **Sharing** - Share lists with family

### 📅 Meal Planning
- **Weekly Planner** - Plan meals for the week
- **Nutrition Goals** - Track daily calorie goals
- **Recommendations** - AI-powered meal suggestions

### 👥 Community
- **Comments & Ratings** - Rate and review recipes
- **Premium Badge** - ✓ Verified tick next to premium users
- **Public Profiles** - View other users' stats and badges
- **Activity Feed** - See what others are cooking
- **Follow System** - Follow favorite cooks

### 🎨 Premium Polish
- **Haptic Feedback** - Tactile responses throughout
- **Micro Animations** - Smooth, delightful transitions
- **Skeleton Loaders** - Beautiful loading states
- **AMOLED Dark Mode** - Pure black theme option
- **Seasonal Themes** - 7 holiday themes:
  - ❄️ Winter / 🎄 Christmas / 🎃 Halloween
  - 💕 Valentine's / 🌸 Spring / ☀️ Summer / 🍂 Autumn

### 🌍 Multilingual
- **14 Languages** - TR, EN, DE, FR, ES, AR, RU, IT, PT, NL, JA, KO, ZH, PL
- **RTL Support** - Arabic and Hebrew layouts
- **Translation Cache** - Cached translations (30-day expiry)

### 🔐 Security & Privacy
- **Data Encryption** - Secure local storage
- **GDPR Compliant** - Data export, deletion, backup
- **Privacy Settings** - Complete control over your data

### 📴 Offline Support
- **Offline Mode** - Browse cached recipes offline
- **Sync Queue** - Actions queued for sync when online
- **Connectivity Indicator** - Visual offline status

---

## 💎 Premium Features

| Feature | Free | Premium |
|---------|------|---------|
| Basic Recipes | ✅ | ✅ |
| Calorie Calculator | 1/day | ∞ |
| Ads | ✅ | ❌ |
| AI Features | ❌ | ✅ |
| Meal Planner | ❌ | ✅ |
| Shopping List Share | ❌ | ✅ |
| Premium Recipes | ❌ | ✅ |
| Verified Badge ✓ | ❌ | ✅ |

**Pricing:**
- Monthly: ₺39.99/month
- Lifetime: ₺299.99 (one-time)

---

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── kitcha_recipe.dart   # Recipe model
│   ├── gamification_models.dart
│   ├── recipe_comment.dart
│   └── ...
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── recipe_detail_screen.dart
│   ├── ai_kitchen_camera_screen.dart
│   ├── premium_screen.dart
│   └── ...
├── services/                 # Business logic
│   ├── recipe_repository.dart
│   ├── gamification_service.dart
│   ├── translation_cache_service.dart
│   ├── easter_egg_service.dart
│   └── ...
├── providers/                # State management
│   ├── subscription_provider.dart
│   └── ...
├── widgets/                  # Reusable widgets
│   ├── premium_badge.dart
│   ├── animated_widgets.dart
│   ├── comments_section.dart
│   └── ...
└── utils/                    # Utilities
    ├── action_guard.dart
    └── ...
```

---

## 🔧 Tech Stack

### Core
- **Flutter** 3.16+ / **Dart** 3.2+
- **Provider** - State management
- **Firebase** - Backend services

### Firebase Services
- **Authentication** - Email, Google, Apple Sign-In
- **Firestore** - NoSQL database
- **Storage** - Image storage
- **Analytics** - User analytics
- **Crashlytics** - Error tracking
- **Remote Config** - Feature flags
- **Cloud Messaging** - Push notifications

### AI/ML
- **Google ML Kit** - Image labeling, text recognition
- **Gemini API** - Recipe recommendations

### Monetization
- **RevenueCat** - Subscription management
- **Google AdMob** - Banner & interstitial ads

### Other Packages
- `cached_network_image` - Image caching
- `shared_preferences` - Local storage
- `flutter_secure_storage` - Encrypted storage
- `lottie` - Animations
- `image_picker` - Camera/gallery access

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.16+
- Dart 3.2+
- Firebase CLI
- Android Studio / Xcode

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/kitcha-app.git
cd kitcha-app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
```bash
flutterfire configure
```

4. **Set up environment variables**
Create `.env` file:
```env
REVENUECAT_API_KEY=your_key
GEMINI_API_KEY=your_key
ADMOB_APP_ID=your_id
```

5. **Run the app**
```bash
flutter run
```

---

## 📊 Project Stats

| Metric | Count |
|--------|-------|
| Total Files | 85+ |
| Models | 12 |
| Screens | 20 |
| Services | 35 |
| Widgets | 15 |
| Sample Recipes | 15 |
| Badges | 25+ |
| Easter Eggs | 12 |
| Languages | 14 |
| Seasonal Themes | 7 |

---

## 🐣 Easter Eggs

Hidden badges you can discover:
- 🎰 **Şanslı 7** - View 7th recipe at 7:07
- 🦉 **Gece Şefi** - Browse recipes after midnight
- 🐦 **Erken Kuş** - Open app before 5 AM
- 🎮 **Konami Ustası** - Enter the Konami code
- 📱 **Sallama Şefi** - Shake for random recipe
- 👆 **Tıklama Ustası** - Tap logo 10 times
- 💬 **İlk Söz** - First comment on a recipe
- 🏅 **Mükemmel Hafta** - Cook every day for a week
- 📚 **Tarif Koleksiyoncusu** - Favorite from all categories
- 🎉 **Bayram Şefi** - Browse on a holiday
- ⚡ **Hız Şefi** - Complete recipe in under 5 min
- 🔮 **Gizli Menü** - Find the secret recipe

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Kitcha Team**

- Website: [kitcha.app](https://kitcha.app)
- Email: developer@kitcha.app

---

## 🙏 Acknowledgments

- Turkish recipe inspiration from traditional cuisine
- Flutter & Firebase communities
- All contributors and testers

---

<p align="center">Made with ❤️ and 🍅</p>
