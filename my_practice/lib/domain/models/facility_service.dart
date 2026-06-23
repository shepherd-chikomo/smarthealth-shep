import 'package:uuid/uuid.dart';

/// A service offered by a facility (catalog or custom).
class FacilityServiceEntry {
  const FacilityServiceEntry({
    required this.id,
    required this.name,
    required this.iconKey,
    this.key,
    this.isCustom = false,
  });

  final String id;
  final String? key;
  final String name;
  final String iconKey;
  final bool isCustom;

  static List<FacilityServiceEntry> parseList(List<dynamic>? raw) {
    if (raw == null) return [];
    return raw
        .whereType<Map>()
        .map((m) => FacilityServiceEntry.fromJson(Map<String, dynamic>.from(m)))
        .where((s) => s.name.isNotEmpty)
        .toList();
  }

  factory FacilityServiceEntry.fromJson(Map<String, dynamic> json) {
    return FacilityServiceEntry(
      id: json['id'] as String? ?? const Uuid().v4(),
      key: json['key'] as String?,
      name: json['name'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? 'custom',
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (key != null) 'key': key,
        'name': name,
        'iconKey': iconKey,
        'isCustom': isCustom,
      };

  FacilityServiceEntry copyWith({
    String? id,
    String? key,
    String? name,
    String? iconKey,
    bool? isCustom,
  }) {
    return FacilityServiceEntry(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

/// Item from GET /facility/services-catalog (admin-managed catalog).
class FacilityServiceCatalogItem {
  const FacilityServiceCatalogItem({
    required this.id,
    required this.label,
    required this.iconKey,
  });

  final String id;
  final String label;
  final String iconKey;

  factory FacilityServiceCatalogItem.fromJson(Map<String, dynamic> json) {
    return FacilityServiceCatalogItem(
      id: (json['id'] ?? json['slug'] ?? '') as String,
      label: (json['label'] ?? json['name'] ?? '') as String,
      iconKey: (json['iconKey'] ?? json['icon_key'] ?? 'custom') as String,
    );
  }
}
