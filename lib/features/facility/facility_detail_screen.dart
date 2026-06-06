import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/core/location/forward_geocoder.dart';
import 'package:smarthealth_shep/features/facility/data/facility_public_profile_repository.dart';
import 'package:smarthealth_shep/features/facility/widgets/facility_profile_widgets.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/l10n/app_localizations.dart';
import 'package:smarthealth_shep/shared/data/facility_repository.dart';
import 'package:smarthealth_shep/shared/models/facility_public_profile.dart';
import 'package:smarthealth_shep/shared/utils/maps_launcher.dart';
import 'package:smarthealth_shep/shared/widgets/app_bottom_navigation_bar.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class FacilityDetailScreen extends StatefulWidget {
  const FacilityDetailScreen({
    super.key,
    required this.facilityId,
    this.parentTabIndex = 0,
    this.distanceKm,
  });

  final String facilityId;
  final int parentTabIndex;
  final double? distanceKm;

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> {
  final _profileRepository = FacilityPublicProfileRepository();
  final _facilityRepository = FacilityRepository.defaults();
  final _geocoder = const ForwardGeocoder();

  FacilityPublicProfile? _profile;
  List<FacilitySpecialistSummary> _specialists = const [];
  List<FacilityAvailabilityDay> _availability = const [];
  bool _loading = true;
  bool _isOffline = false;
  bool _isStale = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _profileRepository.getPublicProfile(
        widget.facilityId,
        distanceKm: widget.distanceKm,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _profile = result.profile;
        _isOffline = result.isOffline;
        _isStale = result.isStale;
        _loading = false;
      });
      _loadLazySections();
      if (!result.isOffline) {
        _profileRepository.getPublicProfile(
          widget.facilityId,
          distanceKm: widget.distanceKm,
          forceRefresh: true,
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _loadLazySections() async {
    final profile = _profile;
    if (profile == null) return;

    final specialistsFuture = _profileRepository.fetchSpecialists(widget.facilityId);
    final availabilityFuture = profile.booking.enabled && profile.booking.showSlots
        ? _profileRepository.fetchAvailability(widget.facilityId)
        : Future.value(<FacilityAvailabilityDay>[]);

    final results = await Future.wait([specialistsFuture, availabilityFuture]);
    if (!mounted) return;
    setState(() {
      _specialists = results[0] as List<FacilitySpecialistSummary>;
      _availability = results[1] as List<FacilityAvailabilityDay>;
    });
  }

  Future<void> _openMaps(FacilityPublicProfile profile) async {
    final query = profile.facility.mapsQuery;
    if (query == null) return;

    final opened = await openInMaps(query);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).facilityMapsOpenFailed)),
      );
      return;
    }

    final facility = profile.facility;
    if (facility.latitude != null && facility.longitude != null) return;

    final coords = await _geocoder.geocodeAddress(query);
    if (coords == null) return;

    await _facilityRepository.rememberCoordinates(
      facility.id,
      coords.lat,
      coords.lon,
    );
  }

  Future<void> _launchUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openWhatsApp(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    _launchUri(Uri.parse('https://wa.me/$digits'));
  }

  void _showAllServices(List<FacilityServiceItem> services) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: services
              .map((s) => ListTile(title: Text(s.name), leading: const Icon(Symbols.health_and_safety)))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabIndex = widget.parentTabIndex.clamp(0, mainTabRoutes.length - 1);
    final profile = _profile;

    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        title: Text(profile?.facility.name ?? 'Facility'),
        backgroundColor: HomeDashboardColors.background,
        actions: [
          IconButton(icon: const Icon(Symbols.favorite_border), onPressed: () {}),
          IconButton(
            icon: const Icon(Symbols.ios_share),
            onPressed: profile == null
                ? null
                : () => _launchUri(Uri.parse('https://myhealth.smarthealth.co.zw/facility/${profile.facility.id}')),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: tabIndex,
        onSelected: (index) => goToMainTab(context, index),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : profile == null
                  ? const Center(child: Text('Facility not found'))
                  : _buildBody(profile, l10n),
    );
  }

  Widget _buildBody(FacilityPublicProfile profile, AppLocalizations l10n) {
    final facility = profile.facility;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_isOffline || _isStale)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Text(
              'Some information may be outdated.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        FacilityProfileHeader(profile: profile),
        const SizedBox(height: 16),
        FacilityPrimaryActions(
          profile: profile,
          onBook: profile.booking.enabled
              ? () => context.push('/facility/${widget.facilityId}/book')
              : null,
          onCall: facility.phone != null
              ? () => _launchUri(Uri.parse('tel:${facility.phone}'))
              : null,
          onWhatsApp: facility.whatsappPhone != null
              ? () => _openWhatsApp(facility.whatsappPhone!)
              : null,
          onDirections: facility.mapsQuery != null ? () => _openMaps(profile) : null,
        ),
        const SizedBox(height: 16),
        FacilityCompactContactCard(
          profile: profile,
          onAddressTap: facility.mapsQuery != null ? () => _openMaps(profile) : null,
          onPhoneTap: facility.phone != null
              ? () => _launchUri(Uri.parse('tel:${facility.phone}'))
              : null,
          onWebsiteTap: facility.website != null
              ? () => _launchUri(Uri.parse(facility.website!))
              : null,
        ),
        const SizedBox(height: 20),
        FacilityServicesGrid(
          services: profile.services,
          onViewAll: profile.services.length > 9
              ? () => _showAllServices(profile.services)
              : null,
        ),
        if (profile.services.isNotEmpty) const SizedBox(height: 20),
        FacilityOperatingHoursSection(profile: profile),
        if (profile.operatingHours.isNotEmpty) const SizedBox(height: 20),
        FacilityMedicalAidSection(
          medicalAids: profile.medicalAids,
          onViewAll: profile.medicalAids.length > 6
              ? () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (context) => SafeArea(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: profile.medicalAids
                            .map((m) => ListTile(title: Text(m.name)))
                            .toList(),
                      ),
                    ),
                  );
                }
              : null,
        ),
        if (profile.medicalAids.isNotEmpty) const SizedBox(height: 20),
        FacilityInfoStatusRow(info: profile.facilityInfo),
        if (profile.facilityInfo.hasAny) const SizedBox(height: 20),
        FacilityAppointmentSlotsSection(
          days: _availability,
          onSlotTap: (slot) {
            final params = {
              if (slot.serviceId != null) 'serviceId': slot.serviceId!,
              'scheduledAt': slot.scheduledAt,
            };
            final qs = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
            context.push('/booking/${slot.providerId}?$qs');
          },
          onViewCalendar: profile.booking.enabled
              ? () => context.push('/facility/${widget.facilityId}/book')
              : null,
        ),
        if (_availability.isNotEmpty) const SizedBox(height: 20),
        FacilitySpecialistsSection(
          specialists: _specialists,
          onBook: (s) => context.push('/booking/${s.id}'),
        ),
        if (_specialists.isNotEmpty) const SizedBox(height: 20),
        FacilityAccessibilitySection(accessibility: profile.accessibility),
        if (profile.accessibility.hasAny) const SizedBox(height: 20),
        FacilityVerificationSection(features: profile.smarthealthFeatures),
      ],
    );
  }
}
