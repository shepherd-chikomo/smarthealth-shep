import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/data/facility_repository.dart';
import 'package:smarthealth_shep/shared/models/facility_model.dart';
import 'package:smarthealth_shep/shared/widgets/app_shell_scaffold.dart';
import 'package:smarthealth_shep/shared/widgets/design_system/verification_badge.dart';
import 'package:smarthealth_shep/shared/widgets/facility_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// Facility profile loaded from GET /facilities/:id.
class FacilityDetailScreen extends StatefulWidget {
  const FacilityDetailScreen({super.key, required this.facilityId});

  final String facilityId;

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> {
  final _repository = FacilityRepository.defaults();
  FacilityModel? _facility;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final facility = await _repository.getById(widget.facilityId);
      if (!mounted) return;
      setState(() {
        _facility = facility;
        _loading = false;
        if (facility == null) {
          _error = 'Facility not found';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        title: Text(_facility?.name ?? 'Facility'),
        backgroundColor: HomeDashboardColors.background,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(_facility!),
    );
  }

  Widget _buildBody(FacilityModel facility) {
    final address = [
      facility.addressLine1,
      facility.city,
      facility.province,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FacilityCard(facility: facility),
        if (facility.description != null && facility.description!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            facility.description!,
            style: const TextStyle(
              fontSize: 14,
              color: HomeDashboardColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
        if (facility.isVerified) ...[
          const SizedBox(height: 16),
          const VerificationBadge(),
        ],
        if (address.isNotEmpty) ...[
          const SizedBox(height: 20),
          _InfoRow(icon: Symbols.location_on, label: address),
        ],
        if (facility.phone != null && facility.phone!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoRow(
            icon: Symbols.call,
            label: facility.phone!,
            onTap: () => _launchUri(Uri.parse('tel:${facility.phone}')),
          ),
        ],
        if (facility.website != null && facility.website!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoRow(
            icon: Symbols.language,
            label: facility.website!,
            onTap: () => _launchUri(Uri.parse(facility.website!)),
          ),
        ],
      ],
    );
  }

  Future<void> _launchUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: HomeDashboardColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: HomeDashboardColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
