# 📁 KitchaApp Required Assets

This document lists all images, icons, and animations you need to manually add to the app.

---

## 📂 Folder Structure

```
assets/
├── images/           # Static images
├── icons/            # App icons and small graphics
├── animations/       # Lottie JSON animations
└── config/           # Configuration files
```

> **Note:** You need to add `assets/animations/` to `pubspec.yaml` if not already there.

---

## 🖼️ Required Images

### `assets/images/`

| Filename | Size | Purpose |
|----------|------|---------|
| `logo.png` | 512x512 | App logo (high-res) |
| `logo_dark.png` | 512x512 | Logo for dark mode (optional) |
| `onboarding_1.png` | 400x400 | Onboarding - Welcome screen |
| `onboarding_2.png` | 400x400 | Onboarding - Features |
| `onboarding_3.png` | 400x400 | Onboarding - Get started |
| `placeholder_recipe.png` | 300x200 | Recipe image placeholder |
| `placeholder_avatar.png` | 150x150 | User avatar placeholder |
| `empty_favorites.png` | 200x200 | Empty favorites illustration |
| `empty_history.png` | 200x200 | Empty history illustration |
| `empty_search.png` | 200x200 | No search results illustration |
| `premium_banner.png` | 800x200 | Premium upgrade banner |
| `year_in_review_bg.png` | 1080x1920 | Year in Review background |

---

## 🎯 Required Icons

### `assets/icons/`

| Filename | Size | Purpose |
|----------|------|---------|
| `icon_calorie.png` | 64x64 | Calorie icon |
| `icon_timer.png` | 64x64 | Cook time icon |
| `icon_serving.png` | 64x64 | Serving size icon |
| `icon_difficulty.png` | 64x64 | Difficulty level icon |
| `google.png` | 48x48 | Google sign-in button |
| `apple.png` | 48x48 | Apple sign-in button (white) |

---

## 🎬 Required Lottie Animations

### `assets/animations/`

> Download from [LottieFiles.com](https://lottiefiles.com/) - search for these terms

| Filename | Search Term | Purpose |
|----------|-------------|---------|
| `loading.json` | "cooking loading" | General loading spinner |
| `success.json` | "success checkmark" | Success feedback |
| `confetti.json` | "confetti celebration" | Badge unlock, level up |
| `cooking.json` | "cooking pot" | Recipe cooking mode |
| `scanning.json` | "scan barcode" | AI ingredient scanning |
| `empty.json` | "empty box" | Empty state animation |

### Seasonal Animations (Optional but Recommended)

| Filename | Search Term | Season |
|----------|-------------|--------|
| `fireworks.json` | "fireworks" | New Year |
| `hearts.json` | "floating hearts" | Valentine's Day |
| `stars_moon.json` | "ramadan moon" | Ramazan |
| `flowers.json` | "spring flowers" | Spring/Nevruz |
| `sun.json` | "summer sun" | Summer |
| `bats.json` | "halloween bats" | Halloween |
| `snowflakes.json` | "winter snowflakes" | Winter/Christmas |

---

## 📱 App Icons (Platform-Specific)

### Android: `android/app/src/main/res/`

| Folder | Size | Filename |
|--------|------|----------|
| `mipmap-mdpi/` | 48x48 | `ic_launcher.png` |
| `mipmap-hdpi/` | 72x72 | `ic_launcher.png` |
| `mipmap-xhdpi/` | 96x96 | `ic_launcher.png` |
| `mipmap-xxhdpi/` | 144x144 | `ic_launcher.png` |
| `mipmap-xxxhdpi/` | 192x192 | `ic_launcher.png` |

**Foreground (for adaptive icons):**
- Same folders with `ic_launcher_foreground.png`
- Background: `ic_launcher_background.png` or solid color

### iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

| Size | Filename |
|------|----------|
| 20x20 | `Icon-App-20x20@1x.png` |
| 40x40 | `Icon-App-20x20@2x.png`, `Icon-App-40x40@1x.png` |
| 60x60 | `Icon-App-20x20@3x.png` |
| 58x58 | `Icon-App-29x29@2x.png` |
| 87x87 | `Icon-App-29x29@3x.png` |
| 80x80 | `Icon-App-40x40@2x.png` |
| 120x120 | `Icon-App-40x40@3x.png`, `Icon-App-60x60@2x.png` |
| 180x180 | `Icon-App-60x60@3x.png` |
| 76x76 | `Icon-App-76x76@1x.png` |
| 152x152 | `Icon-App-76x76@2x.png` |
| 167x167 | `Icon-App-83.5x83.5@2x.png` |
| 1024x1024 | `Icon-App-1024x1024@1x.png` |

> **Tip:** Use [AppIcon.co](https://appicon.co/) to generate all sizes from one 1024x1024 image.

---

## 🌊 Splash Screen

### Android Native Splash
Already configured in `pubspec.yaml` under `flutter_native_splash`.
Run after adding logo:
```bash
flutter pub run flutter_native_splash:create
```

### Custom Splash (Optional)
| Path | Size | Purpose |
|------|------|---------|
| `assets/images/splash_logo.png` | 300x300 | Center splash logo |

---

## 🎨 Design Recommendations

### Color Palette
- **Primary:** `#FF6347` (Tomato Red)
- **Secondary:** `#FF4500` (Orange Red)
- **Background Dark:** `#1E1E1E`
- **Background Light:** `#FFFFFF`

### Logo Guidelines
- Use tomato 🍅 as main element
- Include "Kitcha" text below or beside
- Transparent background for versatility
- Simple, recognizable at small sizes

### Badge Icons
Already using emojis in code, no image files needed:
- 🍳 🔍 👨‍🍳 🏆 📊 🔢 🥗 🔥 ⚡ 💪 🎖️ 💎 👑
- Easter eggs: 🎰 🦉 🐦 🎮 📱 👆 💬 🏅 📚 🎉 ⚡ 🔮

---

## ⚙️ Update pubspec.yaml

Add animations folder if missing:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/    # ADD THIS
    - assets/config/
    - .env
```

---

## 🔗 Free Asset Resources

| Resource | URL | Type |
|----------|-----|------|
| LottieFiles | lottiefiles.com | Animations |
| Undraw | undraw.co | Illustrations |
| Freepik | freepik.com | Images/Icons |
| Flaticon | flaticon.com | Icons |
| Icons8 | icons8.com | Icons/Illustrations |
| AppIcon.co | appicon.co | App icon generator |

---

## ✅ Checklist

- [ ] `assets/images/logo.png`
- [ ] `assets/images/placeholder_recipe.png`
- [ ] `assets/images/placeholder_avatar.png`
- [ ] `assets/animations/loading.json`
- [ ] `assets/animations/success.json`
- [ ] `assets/animations/confetti.json`
- [ ] Android app icons (all mipmap folders)
- [ ] iOS app icons (AppIcon.appiconset)
- [ ] Run `flutter pub run flutter_native_splash:create`

---

**Total Required: ~15 images + 6 animations (minimum)**
**Optional: ~7 seasonal animations + onboarding images**
