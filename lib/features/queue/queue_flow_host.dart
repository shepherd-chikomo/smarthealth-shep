import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthealth_shep/features/queue/bloc/queue_bloc.dart';
import 'package:smarthealth_shep/features/queue/data/queue_repository.dart';
import 'package:smarthealth_shep/features/queue/screens/queue_join_screen.dart';

/// Hosts the join-queue flow [QueueBloc].
class QueueFlowHost extends StatelessWidget {
  const QueueFlowHost({
    super.key,
    required this.providerId,
    this.repository,
  });

  final String providerId;
  final QueueRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QueueBloc(
        providerId: providerId,
        repository: repository,
      ),
      child: const QueueJoinScreen(),
    );
  }
}
