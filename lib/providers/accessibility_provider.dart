import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Color blindness filter modes.
enum ColorBlindMode {
  none,
  protanopia,   // Red weakness
  deuteranopia, // Green weakness
  tritanopia,   // Blue weakness
  grayscale,    // Full color blindness
}

/// Provider for accessibility features including color blindness filters.
class AccessibilityProvider extends ChangeNotifier {
  ColorBlindMode _currentMode = ColorBlindMode.none;
  double _textScaleFactor = 1.0;
  bool _reduceMotion = false;

  ColorBlindMode get currentMode => _currentMode;
  double get textScaleFactor => _textScaleFactor;
  bool get reduceMotion => _reduceMotion;

  /// Get the color filter for the current mode.
  ColorFilter? get colorFilter {
    switch (_currentMode) {
      case ColorBlindMode.protanopia:
        return const ColorFilter.matrix(_protanopiaMatrix);
      case ColorBlindMode.deuteranopia:
        return const ColorFilter.matrix(_deuteranopiaMatrix);
      case ColorBlindMode.tritanopia:
        return const ColorFilter.matrix(_tritanopiaMatrix);
      case ColorBlindMode.grayscale:
        return const ColorFilter.matrix(_grayscaleMatrix);
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

  /// Set the color blind mode and persist it.
  Future<void> setMode(ColorBlindMode mode) async {
    _currentMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('color_blind_mode', mode.toString());
    
    notifyListeners();
  }

  /// Set the text scale factor.
  Future<void> setTextScaleFactor(double factor) async {
    _textScaleFactor = factor.clamp(0.8, 2.0);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale_factor', _textScaleFactor);
    
    notifyListeners();
  }

  /// Set reduce motion preference.
  Future<void> setReduceMotion(bool reduce) async {
    _reduceMotion = reduce;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduce_motion', _reduceMotion);
    
    notifyListeners();
  }

  /// Load saved accessibility preferences.
  Future<void> loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load color blind mode
    final savedMode = prefs.getString('color_blind_mode');
    if (savedMode != null) {
      _currentMode = ColorBlindMode.values.firstWhere(
        (mode) => mode.toString() == savedMode,
        orElse: () => ColorBlindMode.none,
      );
    }
    
    // Load text scale factor
    _textScaleFactor = prefs.getDouble('text_scale_factor') ?? 1.0;
    
    // Load reduce motion
    _reduceMotion = prefs.getBool('reduce_motion') ?? false;
    
    notifyListeners();
  }

  /// Get display name for a color blind mode.
  String getModeName(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.none:
        return 'Normal Görünüm';
      case ColorBlindMode.protanopia:
        return 'Protanopi';
      case ColorBlindMode.deuteranopia:
        return 'Deuteranopi';
      case ColorBlindMode.tritanopia:
        return 'Tritanopi';
      case ColorBlindMode.grayscale:
        return 'Gri Tonlama';
    }
  }

  /// Get description for a color blind mode.
  String getModeDescription(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.none:
        return 'Filtre yok';
      case ColorBlindMode.protanopia:
        return 'Kırmızı renk zayıflığı';
      case ColorBlindMode.deuteranopia:
        return 'Yeşil renk zayıflığı';
      case ColorBlindMode.tritanopia:
        return 'Mavi renk zayıflığı';
      case ColorBlindMode.grayscale:
        return 'Tam renk körlüğü';
    }
  }
}
