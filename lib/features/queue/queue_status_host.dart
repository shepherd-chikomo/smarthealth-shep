import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_bloc.dart';
import 'package:smarthealth_shep/features/queue/data/queue_repository.dart';
import 'package:smarthealth_shep/features/queue/screens/queue_status_screen.dart';

/// Hosts live queue status tracking for an active session.
class QueueStatusHost extends StatelessWidget {
  const QueueStatusHost({
    super.key,
    required this.sessionId,
    this.repository,
  });

  final String sessionId;
  final QueueRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QueueBloc(
        sessionId: sessionId,
        repository: repository,
      ),
      child: const QueueStatusScreen(),
    );
  }
}
