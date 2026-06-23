import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App bar for screens opened from the More menu — back returns to the menu list.
PreferredSizeWidget practiceMoreAppBar(
  BuildContext context,
  String title, {
  PreferredSizeWidget? bottom,
  List<Widget>? actions,
}) {
  return AppBar(
    title: Text(title),
    bottom: bottom,
    actions: actions,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => popToMoreMenu(context),
    ),
  );
}

void popToMoreMenu(BuildContext context) {
  final location = GoRouterState.of(context).matchedLocation;
  if (location == '/more') {
    context.go('/dashboard');
    return;
  }
  if (location.startsWith('/more/')) {
    context.go('/more');
    return;
  }
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go('/dashboard');
}
