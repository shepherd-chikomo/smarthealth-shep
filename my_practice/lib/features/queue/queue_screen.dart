import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueStream = ref.watch(queueRepositoryProvider).watchQueue();

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Queue')),
      body: StreamBuilder<List<QueueEntry>>(
        stream: queueStream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Queue is empty'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return AppTheme.themedCard(
                context: context,
                child: Row(
                  children: [
                    CircleAvatar(child: Text('${item.position}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patient ${item.patientId.split('-').last}'),
                          Text(
                            '${item.status} · ${item.triageStatus ?? 'routine'}',
                            style: AppTextStyles.sm(
                              color: context.appColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (status) => ref
                          .read(queueRepositoryProvider)
                          .updateStatus(item.id, status),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'waiting', child: Text('Waiting')),
                        PopupMenuItem(
                          value: 'in_progress',
                          child: Text('In Consultation'),
                        ),
                        PopupMenuItem(
                          value: 'investigations',
                          child: Text('Investigations'),
                        ),
                        PopupMenuItem(value: 'completed', child: Text('Complete')),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => context.push(
                        '/encounter/${item.patientId}?queueEntryId=${item.id}',
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
