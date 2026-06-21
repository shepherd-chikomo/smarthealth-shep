import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smarthealth_shep/features/medications/utils/prescription_image_preprocess.dart';
import 'package:smarthealth_shep/features/medications/utils/prescription_label_parser.dart';

/// Outcome of a local prescription label scan.
class PrescriptionScanResult {
  const PrescriptionScanResult._({
    this.fields,
    this.errorMessage,
  });

  final PrescriptionLabelFields? fields;
  final String? errorMessage;

  bool get isSuccess => fields != null && fields!.hasAny;

  factory PrescriptionScanResult.success(PrescriptionLabelFields fields) {
    return PrescriptionScanResult._(fields: fields);
  }

  factory PrescriptionScanResult.failure(String message) {
    return PrescriptionScanResult._(errorMessage: message);
  }
}

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

  Future<PrescriptionScanResult> scanFromCamera() =>
      _scan(ImageSource.camera);

  Future<PrescriptionScanResult> scanFromGallery() =>
      _scan(ImageSource.gallery);

  Future<PrescriptionScanResult> _scan(ImageSource source) async {
    if (kIsWeb) {
      return PrescriptionScanResult.failure(
        'Prescription scanning is not available on web',
      );
    }

    final permission = await _ensurePermission(source);
    if (!permission.granted) {
      return PrescriptionScanResult.failure(permission.message);
    }

    final image = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 3000,
    );
    if (image == null) {
      return PrescriptionScanResult.failure('No image selected');
    }

    String? preprocessedPath;
    try {
      preprocessedPath = await PrescriptionImagePreprocess.prepareForOcr(
        image.path,
      );
      final input = InputImage.fromFilePath(preprocessedPath);
      final result = await _recognizer.processImage(input);
      final structured = _extractStructuredText(result);
      if (structured.trim().isEmpty) {
        return PrescriptionScanResult.failure(
          'No text found on the label — try better lighting and a flat photo',
        );
      }
      final parsed = _parser.parse(structured, rawText: result.text);
      if (!parsed.hasAny) {
        return PrescriptionScanResult.failure(
          'Could not read medication details — enter them manually or retake the photo',
        );
      }
      return PrescriptionScanResult.success(parsed);
    } catch (error) {
      return PrescriptionScanResult.failure(
        'Scan failed — check camera access and try again',
      );
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

  Future<({bool granted, String message})> _ensurePermission(
    ImageSource source,
  ) async {
    if (kIsWeb) {
      return (granted: false, message: 'Not available on web');
    }

    if (source == ImageSource.gallery) {
      // Android 13+ photo picker and iOS limited library do not need storage access.
      if (Platform.isIOS) {
        final photos = await Permission.photos.request();
        if (photos.isGranted || photos.isLimited) {
          return (granted: true, message: '');
        }
        return (
          granted: false,
          message: 'Photo library access is required to scan a prescription',
        );
      }
      return (granted: true, message: '');
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        return (granted: true, message: '');
      }
      return (
        granted: false,
        message: 'Camera access is required to scan a prescription',
      );
    }

    return (granted: true, message: '');
  }

  Future<void> dispose() => _recognizer.close();
}
