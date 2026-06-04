/// Medical specialty from catalog / search API.
class SpecialtyModel {
  const SpecialtyModel({
    required this.id,
    required this.name,
    required this.slug,
    this.category,
    this.description,
    this.icdCode,
  });

  final String id;
  final String name;
  final String slug;
  final String? category;
  final String? description;
  final String? icdCode;

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      icdCode: json['icdCode'] as String?,
    );
  }
}
