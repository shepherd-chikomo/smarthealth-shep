import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/providers/app_providers.dart';
import 'package:my_practice/data/local/app_database.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class MessagingScreen extends ConsumerWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final facilityId = ref.watch(facilityIdProvider) ?? 'seed-facility-001';

    return Scaffold(
      appBar: AppBar(title: const Text('Internal Messaging')),
      body: StreamBuilder<List<InternalMessage>>(
        stream: (db.select(db.internalMessages)
              ..where((t) => t.facilityId.equals(facilityId))
              ..orderBy([(t) => OrderingTerm.desc(t.sentAt)]))
            .watch(),
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];
          if (messages.isEmpty) {
            return const PracticeEmptyState(
              title: 'No messages',
              message: 'Secure staff threads between clinical and admin staff.',
              icon: Icons.chat_bubble_outline,
            );
          }

          final unread = messages.where((m) => !m.read).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Staff Messages', style: PracticeDesignTokens.pageTitle(context)),
              Text(
                unread > 0 ? '$unread unread' : 'All caught up',
                style: PracticeDesignTokens.metadata(context),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.appColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline,
                        size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Patient information stays within SmartHealth.',
                        style: PracticeDesignTokens.inter(size: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...messages.map(
                (m) => _MessageTile(message: m, db: db),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageTile extends ConsumerWidget {
  const _MessageTile({required this.message, required this.db});

  final InternalMessage message;
  final AppDatabase db;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Practitioner?>(
      future: (db.select(db.practitioners)
            ..where((t) => t.id.equals(message.senderId)))
          .getSingleOrNull(),
      builder: (context, snap) {
        final sender = snap.data;
        final name = sender?.name ?? message.senderId.split('-').last;
        final initials = sender != null
            ? _initials(sender.name)
            : name.substring(0, 1).toUpperCase();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: PracticeDesignTokens.previewCardDecoration(context),
          child: ListTile(
            leading: PracticeAvatar(initials: initials, size: 40),
            title: Text(name, style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
            subtitle: Text(message.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  PatientFormatters.formatRelativeArrival(message.sentAt),
                  style: PracticeDesignTokens.metadata(context),
                ),
                if (!message.read)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            onTap: () async {
              await (db.update(db.internalMessages)
                    ..where((t) => t.id.equals(message.id)))
                  .write(const InternalMessagesCompanion(read: Value(true)));
              if (!context.mounted) return;
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: PracticeDesignTokens.sectionTitle(context)),
                      Text(
                        PatientFormatters.formatDate(message.sentAt),
                        style: PracticeDesignTokens.metadata(context),
                      ),
                      const SizedBox(height: 16),
                      Text(message.body, style: PracticeDesignTokens.clinicalNote(context)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
