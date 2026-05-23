import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';

/// Six-digit OTP input scaffold (auth feature).
class OtpInput extends StatelessWidget {
  const OtpInput({
    super.key,
    required this.controllers,
    required this.onCompleted,
  });

  final List<TextEditingController> controllers;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'One-time password',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(controllers.length, (index) {
          return SizedBox(
            width: AppConstants.minTapTarget,
            height: AppConstants.minTapTarget,
            child: TextField(
              controller: controllers[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
              onChanged: (value) => _handleChange(index, value),
            ),
          );
        }),
      ),
    );
  }

  void _handleChange(int index, String value) {
    if (value.length == 1 && index < controllers.length - 1) {
      FocusManager.instance.primaryFocus?.nextFocus();
    }
    final code = controllers.map((c) => c.text).join();
    if (code.length == controllers.length) {
      onCompleted(code);
    }
  }
}
