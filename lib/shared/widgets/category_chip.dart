import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/shared/models/category_model.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final CategoryModel category;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: category.name,
      child: FilterChip(
        label: Text(category.name),
        selected: selected,
        onSelected: onSelected,
        avatar: Icon(_iconFor(category.iconName), size: 20),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        labelStyle: const TextStyle(fontSize: 14),
        showCheckmark: false,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  IconData _iconFor(String name) {
    return switch (name) {
      'local_hospital' => Symbols.local_hospital,
      'medical_services' => Symbols.medical_services,
      'vaccines' => Symbols.vaccines,
      'emergency' => Symbols.emergency,
      _ => Symbols.medical_information,
    };
  }
}
