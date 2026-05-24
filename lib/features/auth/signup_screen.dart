import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SmartHealth uses your mobile number for secure sign-in. '
              'No password required.',
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Continue with mobile number'),
            ),
          ],
        ),
      ),
    );
  }
}
