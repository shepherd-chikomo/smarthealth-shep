/// Parsed fields from OCR text on a prescription label.
class PrescriptionLabelFields {
  const PrescriptionLabelFields({
    this.medicationName,
    this.dosage,
    this.frequency,
    this.quantity,
    this.rawText = '',
  });

  final String? medicationName;
  final String? dosage;
  final String? frequency;
  final String? quantity;
  final String rawText;

  bool get hasAny =>
      (medicationName?.isNotEmpty ?? false) ||
      (dosage?.isNotEmpty ?? false) ||
      (frequency?.isNotEmpty ?? false);

  PrescriptionLabelFields copyWith({
    String? medicationName,
    String? dosage,
    String? frequency,
    String? quantity,
    String? rawText,
  }) {
    return PrescriptionLabelFields(
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      quantity: quantity ?? this.quantity,
      rawText: rawText ?? this.rawText,
    );
  }
}

/// Basic regex-based parser for prescription label OCR output.
class PrescriptionLabelParser {
  static final _dosagePattern = RegExp(
    r'\b(\d+(?:\.\d+)?\s*(?:mg|mcg|g|ml|iu|units?))\b',
    caseSensitive: false,
  );

  static final _frequencyPattern = RegExp(
    r'\b(OD|BD|TDS|QID|PRN|once\s+daily|twice\s+daily|three\s+times|four\s+times|every\s+\d+\s+hours?)\b',
    caseSensitive: false,
  );

  static final _quantityPattern = RegExp(
    r'\b(\d+)\s*(?:tabs?|tablets?|caps?|capsules?|pills?)\b',
    caseSensitive: false,
  );

  static final _skipLinePattern = RegExp(
    r'^(rx|prescription|pharmacy|doctor|dr\.|patient|date|exp|batch|ref)\b',
    caseSensitive: false,
  );

  PrescriptionLabelFields parse(String rawText) {
    final normalized = rawText.replaceAll('\r', '').trim();
    if (normalized.isEmpty) {
      return const PrescriptionLabelFields();
    }

    final lines = normalized
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String? medicationName;
    for (final line in lines) {
      if (_skipLinePattern.hasMatch(line)) continue;
      if (_dosagePattern.hasMatch(line) || _frequencyPattern.hasMatch(line)) {
        continue;
      }
      if (line.length >= 3) {
        medicationName = _cleanToken(line);
        break;
      }
    }

    final dosageMatch = _dosagePattern.firstMatch(normalized);
    final frequencyMatch = _frequencyPattern.firstMatch(normalized);
    final quantityMatch = _quantityPattern.firstMatch(normalized);

    var name = medicationName;
    if (name != null && dosageMatch != null) {
      final dosageText = dosageMatch.group(1)!;
      if (name.toLowerCase().contains(dosageText.toLowerCase())) {
        name = name
            .replaceAll(RegExp(RegExp.escape(dosageText), caseSensitive: false), '')
            .trim();
      }
      if (name.isEmpty) name = medicationName;
    }

    return PrescriptionLabelFields(
      medicationName: name,
      dosage: dosageMatch?.group(1)?.trim(),
      frequency: frequencyMatch?.group(1)?.trim().toUpperCase(),
      quantity: quantityMatch?.group(1)?.trim(),
      rawText: normalized,
    );
  }

  static String _cleanToken(String value) {
    return value
        .replaceAll(RegExp(r'[^\w\s\-\./]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
