import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/data/category_repository.dart';
import 'package:smarthealth_shep/shared/data/provider_repository.dart';
import 'package:smarthealth_shep/shared/widgets/category_chip.dart';
import 'package:smarthealth_shep/shared/widgets/provider_card.dart';
import 'package:smarthealth_shep/shared/widgets/section_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(_categoriesProvider);
    final providersAsync = ref.watch(_providersProvider(_selectedCategoryId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navHome)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.homeWelcome,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          SectionHeader(title: l10n.navSearch),
          categoriesAsync.when(
            data: (categories) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: categories.map((cat) {
                  final selected = _selectedCategoryId == cat.id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CategoryChip(
                      category: cat,
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategoryId =
                              selected ? null : cat.id;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
          providersAsync.when(
            data: (providers) => Column(
              children: providers
                  .map((p) => ProviderCard(provider: p))
                  .toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

final _categoriesProvider = FutureProvider((ref) {
  return ref.read(categoryRepositoryProvider).getCategories();
});

final _providersProvider = FutureProvider.family((ref, String? categoryId) {
  return ref.read(providerRepositoryProvider).getProviders(
        categoryId: categoryId,
      );
});
