import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:smarthealth_shep/features/facility/data/facility_public_profile_repository.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';
import 'package:smarthealth_shep/shared/models/facility_public_profile.dart';

class FacilityServicePickerScreen extends StatefulWidget {
  const FacilityServicePickerScreen({super.key, required this.facilityId});

  final String facilityId;

  @override
  State<FacilityServicePickerScreen> createState() =>
      _FacilityServicePickerScreenState();
}

class _FacilityServicePickerScreenState extends State<FacilityServicePickerScreen> {
  final _repository = FacilityPublicProfileRepository();
  FacilityPublicProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _repository.getPublicProfile(widget.facilityId);
      if (!mounted) return;
      setState(() {
        _profile = result.profile;
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

  Future<void> _onServiceSelected(FacilityServiceItem service) async {
    final specialists = await _repository.fetchSpecialists(
      widget.facilityId,
      serviceId: service.id,
      limit: 20,
    );

    if (!mounted) return;

    if (specialists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No providers available for this service yet.')),
      );
      return;
    }

    if (specialists.length == 1) {
      context.push(
        '/booking/${specialists.first.id}?serviceId=${Uri.encodeComponent(service.id)}&facilityId=${widget.facilityId}',
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose a specialist for ${service.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            ...specialists.map(
              (s) => ListTile(
                title: Text(s.name),
                subtitle: s.specialty != null ? Text(s.specialty!) : null,
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/booking/${s.id}?serviceId=${Uri.encodeComponent(service.id)}&facilityId=${widget.facilityId}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeDashboardColors.background,
      appBar: AppBar(
        title: Text(_profile?.facility.name ?? 'Book appointment'),
        backgroundColor: HomeDashboardColors.background,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _profile == null
                  ? const Center(child: Text('Facility not found'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'Select a service',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your appointment will be linked to the service you choose.',
                          style: TextStyle(color: HomeDashboardColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ..._profile!.services.map(
                          (service) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const Icon(Symbols.health_and_safety, color: HomeDashboardColors.primary),
                              title: Text(service.name),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _onServiceSelected(service),
                            ),
                          ),
                        ),
                        if (_profile!.services.isEmpty)
                          const Text('This facility has not configured services yet.'),
                      ],
                    ),
    );
  }
}
