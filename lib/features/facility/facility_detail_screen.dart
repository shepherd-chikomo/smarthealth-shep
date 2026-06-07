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
import 'package:smarthealth_shep/shared/utils/facility_share.dart';
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
  final _shareBoundaryKey = GlobalKey();

  FacilityPublicProfile? _profile;
  List<FacilityAvailabilityDay> _availability = const [];
  bool _loading = true;
  bool _sharing = false;
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

    if (!profile.booking.enabled || !profile.booking.showSlots) return;

    final availability = await _profileRepository.fetchAvailability(widget.facilityId);
    if (!mounted) return;
    setState(() => _availability = availability);
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

  String _normalizeWebsiteUrl(String website) {
    final trimmed = website.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  Future<void> _shareProfile(FacilityPublicProfile profile) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await shareFacilityProfileScreenshot(
        boundaryKey: _shareBoundaryKey,
        profile: profile,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _showAllServices(List<FacilityServiceItem> services) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: services
              .map((s) => ListTile(title: Text(s.name), leading: Icon(Symbols.health_and_safety)))
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
      backgroundColor: HomeDashboardColors.of(context).background,
      appBar: AppBar(
        title: Text(profile?.facility.name ?? 'Facility'),
        backgroundColor: HomeDashboardColors.of(context).background,
        actions: [
          if (_sharing)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Symbols.ios_share),
              onPressed: profile == null ? null : () => _shareProfile(profile),
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

    return RepaintBoundary(
      key: _shareBoundaryKey,
      child: ListView(
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
          onWebsiteTap: facility.website != null
              ? () => _launchUri(Uri.parse(_normalizeWebsiteUrl(facility.website!)))
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
        FacilityVerificationSection(features: profile.smarthealthFeatures),
        ],
      ),
    );
  }
}
