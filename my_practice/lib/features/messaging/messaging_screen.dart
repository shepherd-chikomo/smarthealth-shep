import 'package:flutter/material.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Internal Messaging')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Secure staff messaging keeps patient information within SmartHealth. '
            'Connect to production API to enable threads between clinical and admin staff.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
