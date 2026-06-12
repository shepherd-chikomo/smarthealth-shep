import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/repositories.dart';

class PatientSearchScreen extends ConsumerStatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  ConsumerState<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends ConsumerState<PatientSearchScreen> {
  final _queryCtrl = TextEditingController();
  List<Patient> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    final results =
        await ref.read(patientRepositoryProvider).search(_queryCtrl.text);
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Name, ID, phone, SmartHealth ID',
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(onPressed: _search, icon: const Icon(Icons.search)),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final p = _results[i];
                return ListTile(
                  title: Text('${p.firstName} ${p.lastName}'),
                  subtitle: Text(
                    [
                      if (p.smarthealthPatientId != null) p.smarthealthPatientId,
                      if (p.phone != null) p.phone,
                    ].join(' · '),
                  ),
                  onTap: () => context.push('/patients/${p.id}/chart'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
