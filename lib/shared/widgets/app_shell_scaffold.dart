import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/theme/app_colors.dart';
import 'package:smarthealth_shep/core/theme/app_shadows.dart';

/// Constrains content to 480px on wide viewports (mirrors web `.app-shell`).
class AppShellBody extends StatelessWidget {
  const AppShellBody({super.key, required this.child});

  static const double maxContentWidth = 480;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxContentWidth) {
          return child;
        }

        final tokens = context.appColors;
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: maxContentWidth,
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            decoration: BoxDecoration(
              color: tokens.background,
              border: Border(
                left: BorderSide(color: tokens.border, width: 1),
                right: BorderSide(color: tokens.border, width: 1),
              ),
              boxShadow: AppShadows.appShellAmbient(tokens.border),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Scaffold wrapper using [AppShellBody] for the body.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? context.appColors.background,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: AppShellBody(child: body),
    );
  }
}
