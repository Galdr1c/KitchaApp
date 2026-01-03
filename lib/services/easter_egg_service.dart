import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Service for managing easter eggs and hidden badges.
class EasterEggService {
  static final EasterEggService _instance = EasterEggService._internal();
  factory EasterEggService() => _instance;
  EasterEggService._internal();

  static const String _discoveredKey = 'discovered_easter_eggs';
  final Random _random = Random();

  /// All available easter eggs.
  static const List<EasterEgg> allEasterEggs = [
    // Hidden badges (unlocked by chance or specific actions)
    EasterEgg(
      id: 'lucky_seven',
      name: 'Şanslı 7',
      description: '7. tarifini tam 7:07\'de görüntüledin! 🍀',
      emoji: '🎰',
      xpReward: 77,
      rarity: EasterEggRarity.rare,
    ),
    EasterEgg(
      id: 'midnight_chef',
      name: 'Gece Şefi',
      description: 'Gece yarısından sonra tarif baktın! 🌙',
      emoji: '🦉',
      xpReward: 50,
      rarity: EasterEggRarity.uncommon,
    ),
    EasterEgg(
      id: 'early_bird',
      name: 'Erken Kuş',
      description: 'Sabah 5\'ten önce uygulamayı açtın! ☀️',
      emoji: '🐦',
      xpReward: 50,
      rarity: EasterEggRarity.uncommon,
    ),
    EasterEgg(
      id: 'konami_master',
      name: 'Konami Ustası',
      description: 'Gizli kodu buldun! ↑↑↓↓←→←→BA',
      emoji: '🎮',
      xpReward: 100,
      rarity: EasterEggRarity.legendary,
    ),
    EasterEgg(
      id: 'shake_it',
      name: 'Sallama Şefi',
      description: 'Telefonu salladın ve rastgele tarif buldun!',
      emoji: '📱',
      xpReward: 25,
      rarity: EasterEggRarity.common,
    ),
    EasterEgg(
      id: 'tap_tap_tap',
      name: 'Tıklama Ustası',
      description: 'Logoya 10 kez tıkladın!',
      emoji: '👆',
      xpReward: 30,
      rarity: EasterEggRarity.common,
    ),
    EasterEgg(
      id: 'first_comment_badge',
      name: 'İlk Söz',
      description: 'Bir tarifte ilk yorumu sen yaptın!',
      emoji: '💬',
      xpReward: 40,
      rarity: EasterEggRarity.uncommon,
    ),
    EasterEgg(
      id: 'perfect_week',
      name: 'Mükemmel Hafta',
      description: '7 gün boyunca her gün farklı tarif pişirdin!',
      emoji: '🏅',
      xpReward: 150,
      rarity: EasterEggRarity.epic,
    ),
    EasterEgg(
      id: 'recipe_collector',
      name: 'Tarif Koleksiyoncusu',
      description: 'Tüm kategorilerden en az 1 tarif favorilere ekledin!',
      emoji: '📚',
      xpReward: 100,
      rarity: EasterEggRarity.rare,
    ),
    EasterEgg(
      id: 'holiday_chef',
      name: 'Bayram Şefi',
      description: 'Bayram günü tarif baktın!',
      emoji: '🎉',
      xpReward: 50,
      rarity: EasterEggRarity.uncommon,
    ),
    EasterEgg(
      id: 'speed_cook',
      name: 'Hız Şefi',
      description: '5 dakikadan kısa sürede tarif tamamladın işaretledin!',
      emoji: '⚡',
      xpReward: 35,
      rarity: EasterEggRarity.common,
    ),
    EasterEgg(
      id: 'secret_menu',
      name: 'Gizli Menü',
      description: 'Gizli tarifi buldun!',
      emoji: '🔮',
      xpReward: 200,
      rarity: EasterEggRarity.legendary,
    ),
  ];

  /// Check and potentially unlock time-based easter eggs.
  Future<EasterEgg?> checkTimeBasedEasterEggs() async {
    final now = DateTime.now();
    
    // Lucky 7 (7:07)
    if (now.hour == 7 && now.minute == 7) {
      return await _tryUnlock('lucky_seven');
    }
    
    // Midnight chef (00:00 - 03:00)
    if (now.hour >= 0 && now.hour < 3) {
      return await _tryUnlock('midnight_chef');
    }
    
    // Early bird (04:00 - 05:00)
    if (now.hour >= 4 && now.hour < 5) {
      return await _tryUnlock('early_bird');
    }
    
    // Holiday chef (special dates)
    if (_isHoliday(now)) {
      return await _tryUnlock('holiday_chef');
    }
    
    return null;
  }

  /// Handle logo tap easter egg.
  int _logoTapCount = 0;
  Future<EasterEgg?> onLogoTapped() async {
    _logoTapCount++;
    if (_logoTapCount >= 10) {
      _logoTapCount = 0;
      return await _tryUnlock('tap_tap_tap');
    }
    return null;
  }

  /// Handle shake gesture.
  Future<EasterEgg?> onShake() async {
    return await _tryUnlock('shake_it');
  }

  /// Konami code detection.
  final List<String> _konamiBuffer = [];
  static const List<String> _konamiCode = ['up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a'];
  
  Future<EasterEgg?> onKonamiInput(String input) async {
    _konamiBuffer.add(input);
    if (_konamiBuffer.length > 10) {
      _konamiBuffer.removeAt(0);
    }
    
    if (_konamiBuffer.length == 10 && 
        _konamiBuffer.every((e) => _konamiCode[_konamiBuffer.indexOf(e)] == e)) {
      _konamiBuffer.clear();
      return await _tryUnlock('konami_master');
    }
    return null;
  }

  /// Random chance easter egg (1% chance).
  Future<EasterEgg?> checkRandomEasterEgg() async {
    if (_random.nextDouble() < 0.01) {
      final unlockedIds = await getDiscoveredIds();
      final available = allEasterEggs
          .where((e) => !unlockedIds.contains(e.id))
          .toList();
      
      if (available.isNotEmpty) {
        final random = available[_random.nextInt(available.length)];
        return await _tryUnlock(random.id);
      }
    }
    return null;
  }

  /// Try to unlock an easter egg if not already discovered.
  Future<EasterEgg?> _tryUnlock(String id) async {
    final discovered = await getDiscoveredIds();
    if (discovered.contains(id)) return null;
    
    final egg = allEasterEggs.firstWhere((e) => e.id == id, orElse: () => allEasterEggs.first);
    
    discovered.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_discoveredKey, discovered);
    
    LoggerService.info('Easter egg unlocked: ${egg.name}');
    return egg;
  }

  /// Get list of discovered easter egg IDs.
  Future<List<String>> getDiscoveredIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_discoveredKey) ?? [];
  }

  /// Get all discovered easter eggs.
  Future<List<EasterEgg>> getDiscoveredEasterEggs() async {
    final ids = await getDiscoveredIds();
    return allEasterEggs.where((e) => ids.contains(e.id)).toList();
  }

  /// Get discovery progress.
  Future<EasterEggProgress> getProgress() async {
    final discovered = await getDiscoveredIds();
    return EasterEggProgress(
      discovered: discovered.length,
      total: allEasterEggs.length,
    );
  }

  bool _isHoliday(DateTime date) {
    // Turkish holidays
    final holidays = [
      DateTime(date.year, 1, 1),   // New Year
      DateTime(date.year, 4, 23),  // Children's Day
      DateTime(date.year, 5, 1),   // Labor Day
      DateTime(date.year, 5, 19),  // Youth Day
      DateTime(date.year, 8, 30),  // Victory Day
      DateTime(date.year, 10, 29), // Republic Day
    ];
    
    return holidays.any((h) => h.day == date.day && h.month == date.month);
  }
}

/// Easter egg definition.
class EasterEgg {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int xpReward;
  final EasterEggRarity rarity;

  const EasterEgg({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.xpReward,
    required this.rarity,
  });
}

/// Easter egg rarity.
enum EasterEggRarity {
  common,     // Easy to find
  uncommon,   // Requires specific time/action
  rare,       // Harder to find
  epic,       // Very hard
  legendary,  // Super rare
}

/// Easter egg discovery progress.
class EasterEggProgress {
  final int discovered;
  final int total;

  EasterEggProgress({required this.discovered, required this.total});

  double get percentage => total > 0 ? discovered / total : 0;
  String get displayText => '$discovered / $total';
  bool get isComplete => discovered >= total;
}
