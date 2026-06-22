import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_practice/shared/widgets/more_menu_content.dart';
import 'package:my_practice/shared/widgets/practice_more_app_bar.dart';

/// More hub — all secondary navigation lives here (single source of truth).
class FacilityScreen extends ConsumerWidget {
  const FacilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: practiceMoreAppBar(context, 'More'),
      body: const MoreMenuContent(),
    );
  }
}
