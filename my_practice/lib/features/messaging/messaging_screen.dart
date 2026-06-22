import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/core/auth/auth_state.dart';
import 'package:my_practice/data/remote/claims_api_client.dart';
import 'package:my_practice/data/repositories/repositories.dart';
import 'package:my_practice/design_system/tokens/practice_design_tokens.dart';
import 'package:my_practice/design_system/widgets/practice_design_widgets.dart';
import 'package:my_practice/features/facility/team_provider.dart';
import 'package:my_practice/features/practice_ops/practice_ops_providers.dart';
import 'package:my_practice/shared/widgets/practice_more_app_bar.dart';
import 'package:my_practice/shared/utils/patient_formatters.dart';
import 'package:smarthealth_core/smarthealth_core.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider);
    final auth = ref.watch(authStateProvider);
    final myId = auth.profile?.id;

    return Scaffold(
      appBar: practiceMoreAppBar(
        context,
        'Internal Messaging',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _composeMessage(context),
          ),
        ],
      ),
      body: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (messages) {
          if (messages.isEmpty) {
            return Column(
              children: [
                const Expanded(
                  child: PracticeEmptyState(
                    title: 'No messages',
                    message: 'Secure staff threads between clinical and admin staff.',
                    icon: Icons.chat_bubble_outline,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: () => _composeMessage(context),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('New message'),
                  ),
                ),
              ],
            );
          }

          final unread = messages.where((m) => m['read'] != true && m['recipientId'] == myId).length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(messagesProvider);
              await ref.read(messagesProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
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
                ...messages.map((m) => _MessageTile(message: m, myId: myId)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _composeMessage(BuildContext context) async {
    final team = await ref.read(teamListProvider.future);
    final auth = ref.read(authStateProvider);
    final myId = auth.profile?.id;
    final recipients = team.where((m) => m.id != myId).toList();
    if (!context.mounted) return;
    if (recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other staff members to message yet.')),
      );
      return;
    }

    final bodyCtrl = TextEditingController();
    String? recipientId = recipients.first.id;

    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New message'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: recipientId,
                decoration: const InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(),
                ),
                items: recipients
                    .map(
                      (r) => DropdownMenuItem(
                        value: r.id,
                        child: Text('${r.name} (${r.role ?? 'staff'})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => recipientId = v,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (sent != true || recipientId == null || bodyCtrl.text.trim().isEmpty) return;

    try {
      await ref.read(facilityRepositoryProvider).sendMessage(
            recipientId: recipientId!,
            body: bodyCtrl.text.trim(),
          );
      ref.invalidate(messagesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent')),
        );
      }
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractApiError(e) ?? 'Could not send message')),
        );
      }
    }
  }
}

class _MessageTile extends ConsumerWidget {
  const _MessageTile({required this.message, required this.myId});

  final Map<String, dynamic> message;
  final String? myId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senderId = message['senderId'] as String? ?? '';
    final isMine = senderId == myId;
    final name = isMine
        ? 'You → ${message['recipientName'] ?? 'Staff'}'
        : (message['senderName'] as String? ?? 'Staff');
    final body = message['body'] as String? ?? '';
    final sentAt = DateTime.tryParse(message['sentAt'] as String? ?? '') ?? DateTime.now();
    final read = message['read'] == true || isMine;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: PracticeDesignTokens.previewCardDecoration(context),
      child: ListTile(
        leading: PracticeAvatar(
          initials: name.isNotEmpty ? name[0].toUpperCase() : '?',
          size: 40,
        ),
        title: Text(name, style: PracticeDesignTokens.inter(weight: FontWeight.w600)),
        subtitle: Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              PatientFormatters.formatRelativeArrival(sentAt),
              style: PracticeDesignTokens.metadata(context),
            ),
            if (!read)
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
          final id = message['id'] as String?;
          if (!read && id != null && !isMine) {
            await ref.read(facilityRepositoryProvider).markMessageRead(id);
            ref.invalidate(messagesProvider);
          }
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
                    PatientFormatters.formatDate(sentAt),
                    style: PracticeDesignTokens.metadata(context),
                  ),
                  const SizedBox(height: 16),
                  Text(body, style: PracticeDesignTokens.clinicalNote(context)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
