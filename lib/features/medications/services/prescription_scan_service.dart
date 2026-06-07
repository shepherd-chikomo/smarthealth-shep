import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smarthealth_shep/features/medications/utils/prescription_image_preprocess.dart';
import 'package:smarthealth_shep/features/medications/utils/prescription_label_parser.dart';

/// Device-local prescription label OCR — images never leave the device.
class PrescriptionScanService {
  PrescriptionScanService({
    ImagePicker? imagePicker,
    PrescriptionLabelParser? parser,
  })  : _picker = imagePicker ?? ImagePicker(),
        _parser = parser ?? PrescriptionLabelParser();

  final ImagePicker _picker;
  final PrescriptionLabelParser _parser;
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<PrescriptionLabelFields?> scanFromCamera() =>
      _scan(ImageSource.camera);

  Future<PrescriptionLabelFields?> scanFromGallery() =>
      _scan(ImageSource.gallery);

  Future<PrescriptionLabelFields?> _scan(ImageSource source) async {
    if (kIsWeb) return null;

    final granted = await _ensurePermission(source);
    if (!granted) return null;

    final image = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 3000,
    );
    if (image == null) return null;

    String? preprocessedPath;
    try {
      preprocessedPath = await PrescriptionImagePreprocess.prepareForOcr(
        image.path,
      );
      final input = InputImage.fromFilePath(preprocessedPath);
      final result = await _recognizer.processImage(input);
      final structured = _extractStructuredText(result);
      if (structured.trim().isEmpty) return null;
      return _parser.parse(structured, rawText: result.text);
    } finally {
      if (!kIsWeb) {
        for (final path in {image.path, preprocessedPath}) {
          if (path == null) continue;
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    }
  }

  /// Prefer line-ordered text from ML Kit blocks over flat [RecognizedText.text].
  String _extractStructuredText(RecognizedText result) {
    final lines = <String>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isNotEmpty) lines.add(text);
      }
    }
    if (lines.isEmpty) return result.text.trim();
    return lines.join('\n');
  }

  Future<bool> _ensurePermission(ImageSource source) async {
    if (kIsWeb) return false;
    if (Platform.isAndroid || Platform.isIOS) {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        return status.isGranted;
      }
      if (Platform.isAndroid) {
        final photos = await Permission.photos.request();
        if (photos.isGranted) return true;
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
      final photos = await Permission.photos.request();
      return photos.isGranted;
    }
    return true;
  }

  Future<void> dispose() => _recognizer.close();
}
