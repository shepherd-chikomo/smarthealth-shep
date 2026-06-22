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
      onPressed: () => _popToMoreMenu(context),
    ),
  );
}

void popToMoreMenu(BuildContext context) => _popToMoreMenu(context);

void _popToMoreMenu(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  final location = GoRouterState.of(context).uri.toString();
  if (location.startsWith('/more/')) {
    context.go('/more');
  } else {
    context.go('/dashboard');
  }
}
