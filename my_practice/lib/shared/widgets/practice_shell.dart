import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_practice/shared/widgets/practice_responsive_shell.dart';

class PracticeShell extends StatelessWidget {
  const PracticeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return PracticeResponsiveShell(navigationShell: navigationShell);
  }
}
