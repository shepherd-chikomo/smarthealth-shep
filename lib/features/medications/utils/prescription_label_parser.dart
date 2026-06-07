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

/// Regex-based parser tuned for Zimbabwe prescription labels.
class PrescriptionLabelParser {
  static final _dosagePattern = RegExp(
    r'\b(\d+(?:\.\d+)?\s*(?:mg|mcg|g|ml|iu|units?|tab(?:let)?s?))\b',
    caseSensitive: false,
  );

  static final _frequencyPattern = RegExp(
    r'\b(OD|BD|TDS|QID|PRN|once\s+daily|twice\s+daily|three\s+times|four\s+times|every\s+\d+\s+hours?|1x\s+daily|2x\s+daily)\b',
    caseSensitive: false,
  );

  static final _quantityPattern = RegExp(
    r'\b(?:qty|quantity|disp(?:ense)?\.?)\s*[:\.]?\s*(\d+)\b|\b(\d+)\s*(?:tabs?|tablets?|caps?|capsules?|pills?)\b',
    caseSensitive: false,
  );

  static final _skipLinePattern = RegExp(
    r'^(rx|prescription|pharmacy|chemist|doctor|dr\.|patient|date|exp|batch|ref|dispensed|repeat|keep|store|take|with|food|water|label|morning|evening|mornin|night|noon|bedtime|before|after|meals)\b',
    caseSensitive: false,
  );

  static final _noiseWordPattern = RegExp(
    r'^(morning|evening|mornin|night|noon|daily|weekly|tab|tabs|cap|caps|take|dose|sig|qty)$',
    caseSensitive: false,
  );

  /// Common generic/brand prefixes on ZW labels.
  static final _knownDrugHints = RegExp(
    r'\b(paracetamol|panadol|amoxicillin|metformin|aspirin|ibuprofen|'
    r'losartan|amlodipine|atenolol|hydrochlorothiazide|omeprazole|'
    r'ciprofloxacin|azithromycin|doxycycline|prednisolone|salbutamol|'
    r'morning[- ]?side|morningside|co[- ]?amoxiclav|augmentin)\b',
    caseSensitive: false,
  );

  PrescriptionLabelFields parse(String structuredText, {String rawText = ''}) {
    final normalized = structuredText.replaceAll('\r', '').trim();
    if (normalized.isEmpty) {
      return PrescriptionLabelFields(rawText: rawText);
    }

    final lines = normalized
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final dosageMatch = _dosagePattern.firstMatch(normalized);
    final frequencyMatch = _frequencyPattern.firstMatch(normalized);
    final quantityMatch = _quantityPattern.firstMatch(normalized);

    String? medicationName = _pickMedicationName(
      lines,
      dosageText: dosageMatch?.group(1),
    );

    if (medicationName == null && _knownDrugHints.hasMatch(normalized)) {
      medicationName = _knownDrugHints.firstMatch(normalized)!.group(0);
    }

    var name = medicationName;
    if (name != null && dosageMatch != null) {
      final dosageText = dosageMatch.group(1)!;
      if (name.toLowerCase().contains(dosageText.toLowerCase())) {
        name = name
            .replaceAll(
              RegExp(RegExp.escape(dosageText), caseSensitive: false),
              '',
            )
            .trim();
      }
      if (name.isEmpty) name = medicationName;
    }

    return PrescriptionLabelFields(
      medicationName: name != null ? _titleCaseDrug(name) : null,
      dosage: dosageMatch?.group(1)?.trim(),
      frequency: _normalizeFrequency(frequencyMatch?.group(1)),
      quantity: quantityMatch?.group(1)?.trim() ?? quantityMatch?.group(2)?.trim(),
      rawText: rawText.isNotEmpty ? rawText : normalized,
    );
  }

  static String? _pickMedicationName(List<String> lines, {String? dosageText}) {
    String? best;
    var bestScore = -1;

    for (final line in lines) {
      if (_skipLinePattern.hasMatch(line)) continue;
      if (_frequencyPattern.hasMatch(line) && !_knownDrugHints.hasMatch(line)) {
        continue;
      }

      final cleaned = _cleanToken(line);
      if (cleaned.length < 3) continue;
      if (_noiseWordPattern.hasMatch(cleaned)) continue;
      if (dosageText != null &&
          cleaned.toLowerCase() == dosageText.toLowerCase()) {
        continue;
      }

      var score = cleaned.length;
      if (_knownDrugHints.hasMatch(cleaned)) score += 40;
      if (RegExp(r'^[A-Z]').hasMatch(cleaned)) score += 5;
      if (_dosagePattern.hasMatch(cleaned)) score -= 10;

      if (score > bestScore) {
        bestScore = score;
        best = cleaned;
      }
    }
    return best;
  }

  static String? _normalizeFrequency(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final value = raw.trim().toLowerCase();
    if (value.contains('once') || value == 'od' || value.contains('1x')) {
      return 'OD';
    }
    if (value.contains('twice') || value == 'bd' || value.contains('2x')) {
      return 'BD';
    }
    if (value.contains('three') || value == 'tds') return 'TDS';
    if (value.contains('four') || value == 'qid') return 'QID';
    if (value == 'prn') return 'PRN';
    return raw.trim().toUpperCase();
  }

  static String _titleCaseDrug(String value) {
    if (value.length <= 3 && value.toUpperCase() == value) return value;
    return value
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;
          if (word.length <= 3 && word.toUpperCase() == word) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  static String _cleanToken(String value) {
    return value
        .replaceAll(RegExp(r'[^\w\s\-\./]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
