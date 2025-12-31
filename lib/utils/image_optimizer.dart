import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageOptimizer {
  /// Compress image and return the path to the compressed file
  static Future<String> compressImage(String imagePath) async {
    final imageFile = File(imagePath);
    final image = img.decodeImage(imageFile.readAsBytesSync());
    
    if (image == null) return imagePath;

    // Resize if too large (Max 1024 width/height)
    img.Image resized = image;
    if (image.width > 1024 || image.height > 1024) {
      resized = img.copyResize(image, width: 1024, height: 1024, interpolation: img.Interpolation.linear);
    }

    // Compress (Quality 80)
    final compressedBytes = img.encodeJpg(resized, quality: 80);
    
    // Save to temp directory
    final tempDir = await getTemporaryDirectory();
    final compressedPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    await File(compressedPath).writeAsBytes(compressedBytes);
    print('[ImageOptimizer] Compressed $imagePath to $compressedPath');
    
    return compressedPath;
  }
}
