import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// Platform detector for Huawei/HMS device detection
class PlatformDetector {
  static bool? _isHuawei;
  static String? _manufacturer;
  static String? _model;

  /// Check if current device is a Huawei/Honor device (HMS)
  static Future<bool> isHuaweiDevice() async {
    if (_isHuawei != null) return _isHuawei!;

    // Only Android devices can be Huawei
    if (!Platform.isAndroid) {
      _isHuawei = false;
      return false;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      _manufacturer = androidInfo.manufacturer.toLowerCase();
      _model = androidInfo.model;

      _isHuawei = _manufacturer!.contains('huawei') ||
          _manufacturer!.contains('honor');

      print('[Platform] Is Huawei: $_isHuawei');
      print('[Platform] Manufacturer: $_manufacturer');
      print('[Platform] Model: $_model');

      return _isHuawei!;
    } catch (e) {
      print('[Platform] Detection error: $e');
      _isHuawei = false;
      return false;
    }
  }

  /// Get device manufacturer
  static String get manufacturer => _manufacturer ?? 'Unknown';

  /// Get device model
  static String get model => _model ?? 'Unknown';

  /// Check if running in test mode (no Google Play Services)
  static bool get isTestMode => _isHuawei == true;
}
