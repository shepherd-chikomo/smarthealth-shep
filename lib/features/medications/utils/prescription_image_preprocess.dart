import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Improves OCR accuracy by normalizing contrast and resolution before ML Kit.
abstract final class PrescriptionImagePreprocess {
  static const _minWidth = 1000;
  static const _maxWidth = 1800;

  /// Returns a temp JPEG path suitable for [InputImage.fromFilePath].
  static Future<String> prepareForOcr(String sourcePath) async {
    final bytes = await File(sourcePath).readAsBytes();
    final encoded = await compute(_processImageBytes, bytes);
    if (encoded == null) return sourcePath;

    final outPath =
        '${Directory.systemTemp.path}/rx_ocr_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(outPath).writeAsBytes(encoded, flush: true);
    return outPath;
  }
}

/// CPU-heavy work — must run off the UI isolate to avoid ANR.
Uint8List? _processImageBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  var image = img.grayscale(decoded);
  image = img.adjustColor(image, contrast: 1.2, brightness: 0.02);

  if (image.width < PrescriptionImagePreprocess._minWidth) {
    final scale = PrescriptionImagePreprocess._minWidth / image.width;
    image = img.copyResize(
      image,
      width: PrescriptionImagePreprocess._minWidth,
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  } else if (image.width > PrescriptionImagePreprocess._maxWidth) {
    final scale = PrescriptionImagePreprocess._maxWidth / image.width;
    image = img.copyResize(
      image,
      width: PrescriptionImagePreprocess._maxWidth,
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  }

  return Uint8List.fromList(img.encodeJpg(image, quality: 88));
}
