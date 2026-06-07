import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/config/app_config.dart';
import 'package:smarthealth_shep/core/location/search_origin_resolver.dart';
import 'package:smarthealth_shep/core/network/api_service.dart';
import 'package:smarthealth_shep/core/network/dio_factory.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/features/profile/models/selected_primary_provider.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/models/provider_model.dart';
import 'package:smarthealth_shep/shared/models/provider_search_filter.dart';

enum _PrimaryProviderSearchMode { doctors, facilities }

/// Searchable picker for a facility or doctor from the platform database.
class PrimaryProviderSelectionSheet extends StatefulWidget {
  const PrimaryProviderSelectionSheet({
    super.key,
    this.apiService,
    this.searchOrigin,
  });

  final ApiService? apiService;
  final SearchOriginResolver? searchOrigin;

  static Future<SelectedPrimaryProvider?> show(
    BuildContext context, {
    ApiService? apiService,
    SearchOriginResolver? searchOrigin,
  }) {
    return showModalBottomSheet<SelectedPrimaryProvider>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: PrimaryProviderSelectionSheet(
          apiService: apiService,
          searchOrigin: searchOrigin,
        ),
      ),
    );
  }

  @override
  State<PrimaryProviderSelectionSheet> createState() =>
      _PrimaryProviderSelectionSheetState();
}

class _PrimaryProviderSelectionSheetState
    extends State<PrimaryProviderSelectionSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  _PrimaryProviderSearchMode _mode = _PrimaryProviderSearchMode.doctors;
  bool _loading = true;
  String? _error;
  List<ProviderModel> _providers = const [];
  List<FacilityModel> _facilities = const [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _runSearch(immediate: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _runSearch();
  }

  void _runSearch({bool immediate = false}) {
    _debounce?.cancel();
    if (immediate) {
      unawaited(_fetchResults());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_fetchResults());
    });
  }

  Future<void> _fetchResults() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = widget.apiService ?? ApiService(createApiDio());

      double? lat;
      double? lon;
      if (widget.searchOrigin != null) {
        try {
          final origin =
              await widget.searchOrigin!.resolve(refreshGps: false);
          lat = origin.latitude;
          lon = origin.longitude;
        } catch (_) {
          // Search without geo bias when location is unavailable.
        }
      }

      final query = _searchController.text.trim();
      final filter = ProviderSearchFilter(
        query: query,
        latitude: lat,
        longitude: lon,
        radiusKm: AppConfig.defaultSearchRadiusKm,
      );

      if (_mode == _PrimaryProviderSearchMode.doctors) {
        final providers = await api.searchProviders(filter);
        if (!mounted) return;
        setState(() {
          _providers = providers;
          _loading = false;
        });
        return;
      }

      final facilities = await api.searchFacilities(filter);
      if (!mounted) return;
      setState(() {
        _facilities = facilities;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _switchMode(_PrimaryProviderSearchMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    _runSearch(immediate: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Select primary provider',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<_PrimaryProviderSearchMode>(
                segments: const [
                  ButtonSegment(
                    value: _PrimaryProviderSearchMode.doctors,
                    label: Text('Doctors'),
                    icon: Icon(Symbols.stethoscope),
                  ),
                  ButtonSegment(
                    value: _PrimaryProviderSearchMode.facilities,
                    label: Text('Facilities'),
                    icon: Icon(Symbols.local_hospital),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) =>
                    _switchMode(selection.first),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _mode == _PrimaryProviderSearchMode.doctors
                      ? 'Search doctors'
                      : 'Search facilities',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildResults(context, scrollController, colors)),
          ],
        );
      },
    );
  }

  Widget _buildResults(
    BuildContext context,
    ScrollController scrollController,
    HomeDashboardColors colors,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load providers.\n$_error',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }

    if (_mode == _PrimaryProviderSearchMode.doctors) {
      if (_providers.isEmpty) {
        return Center(
          child: Text(
            'No doctors found',
            style: TextStyle(color: colors.textSecondary),
          ),
        );
      }
      return ListView.separated(
        controller: scrollController,
        itemCount: _providers.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final provider = _providers[index];
          return ListTile(
            leading: const Icon(Symbols.person),
            title: Text(provider.name),
            subtitle: Text(
              [
                if (provider.facilityName != null) provider.facilityName!,
                if (provider.specialty != null) provider.specialty!,
              ].join(' · '),
            ),
            trailing: provider.isVerified
                ? Icon(Symbols.verified, color: colors.primary, size: 20)
                : null,
            onTap: () => Navigator.pop(
              context,
              SelectedPrimaryProvider.fromProvider(provider),
            ),
          );
        },
      );
    }

    if (_facilities.isEmpty) {
      return Center(
        child: Text(
          'No facilities found',
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      controller: scrollController,
      itemCount: _facilities.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final facility = _facilities[index];
        return ListTile(
          leading: const Icon(Symbols.local_hospital),
          title: Text(facility.name),
          subtitle: Text(
            [
              facility.city,
              if (facility.addressLine1 != null) facility.addressLine1!,
            ].join(' · '),
          ),
          trailing: facility.isVerified
              ? Icon(Symbols.verified, color: colors.primary, size: 20)
              : null,
          onTap: () => Navigator.pop(
            context,
            SelectedPrimaryProvider.fromFacility(facility),
          ),
        );
      },
    );
  }
}
