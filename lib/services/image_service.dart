import 'dart:io';
import 'dart:typed_data';

/// Service for image compression and optimization.
class ImageService {
  /// Compress image file for general use.
  static Future<File> compressImage(File file, {int quality = 85}) async {
    // In production, use flutter_image_compress package
    // final result = await FlutterImageCompress.compressAndGetFile(
    //   file.absolute.path,
    //   outPath,
    //   quality: quality,
    //   minWidth: 1024,
    //   minHeight: 1024,
    // );
    // return File(result!.path);

    // For now, return original file
    print('[ImageService] Compress image: ${file.path}');
    return file;
  }

  /// Compress image for calorie analysis (ML Kit processing).
  static Future<File> compressForAnalysis(File file) async {
    // Optimize for ML Kit - smaller size, high quality
    print('[ImageService] Compress for analysis: ${file.path}');
    return file;
  }

  /// Compress image bytes.
  static Future<Uint8List> compressBytes(Uint8List bytes, {int quality = 85}) async {
    // In production, use flutter_image_compress package
    // return await FlutterImageCompress.compressWithList(
    //   bytes,
    //   quality: quality,
    // );

    print('[ImageService] Compress bytes: ${bytes.length} bytes');
    return bytes;
  }

  /// Get image size category.
  static String getSizeCategory(int bytes) {
    if (bytes < 100 * 1024) return 'small';
    if (bytes < 500 * 1024) return 'medium';
    if (bytes < 2 * 1024 * 1024) return 'large';
    return 'very_large';
  }

  /// Calculate compression ratio.
  static double getCompressionRatio(int original, int compressed) {
    if (original == 0) return 0;
    return 1 - (compressed / original);
  }

  /// Get thumbnail dimensions.
  static Map<String, int> getThumbnailDimensions(int width, int height, int maxSize) {
    if (width <= maxSize && height <= maxSize) {
      return {'width': width, 'height': height};
    }

    final ratio = width / height;
    if (width > height) {
      return {
        'width': maxSize,
        'height': (maxSize / ratio).round(),
      };
    } else {
      return {
        'width': (maxSize * ratio).round(),
        'height': maxSize,
      };
    }
  }

  /// Create placeholder color from image.
  static String extractDominantColor(Uint8List bytes) {
    // In production, analyze image pixels
    // For now, return default color
    return '#FF6347';
  }
}
