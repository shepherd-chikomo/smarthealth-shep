import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Improves OCR accuracy by normalizing contrast and resolution before ML Kit.
abstract final class PrescriptionImagePreprocess {
  static const _minWidth = 1200;
  static const _maxWidth = 2400;

  /// Returns a temp JPEG path suitable for [InputImage.fromFilePath].
  static Future<String> prepareForOcr(String sourcePath) async {
    final bytes = await File(sourcePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return sourcePath;

    var image = img.grayscale(decoded);
    image = img.adjustColor(image, contrast: 1.25, brightness: 0.03);
    image = img.gaussianBlur(image, radius: 1);

    if (image.width < _minWidth) {
      final scale = _minWidth / image.width;
      image = img.copyResize(
        image,
        width: _minWidth,
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.cubic,
      );
    } else if (image.width > _maxWidth) {
      final scale = _maxWidth / image.width;
      image = img.copyResize(
        image,
        width: _maxWidth,
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.cubic,
      );
    }

    final outPath =
        '${Directory.systemTemp.path}/rx_ocr_${DateTime.now().microsecondsSinceEpoch}.jpg';
    final encoded = Uint8List.fromList(img.encodeJpg(image, quality: 92));
    await File(outPath).writeAsBytes(encoded, flush: true);
    return outPath;
  }
}
