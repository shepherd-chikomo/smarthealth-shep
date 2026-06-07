import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (image == null) return null;

    try {
      final input = InputImage.fromFilePath(image.path);
      final result = await _recognizer.processImage(input);
      final text = result.text.trim();
      if (text.isEmpty) return null;
      return _parser.parse(text);
    } finally {
      if (!kIsWeb) {
        final file = File(image.path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
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
