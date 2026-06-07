import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smarthealth_shep/core/utils/app_constants.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

/// Six-digit OTP input with OS autofill (SMS and email one-time codes).
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onCompleted;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  static const _length = 6;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCodeChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCodeChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  void _onCodeChanged() {
    final code = widget.controller.text;
    if (code.length == _length) {
      widget.onCompleted(code);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomeDashboardColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final digits = widget.controller.text.padRight(_length).split('');

    return AutofillGroup(
      child: Semantics(
        label: 'One-time password',
        child: GestureDetector(
          onTap: () => widget.focusNode.requestFocus(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_length, (index) {
                  final char = digits[index].trim();
                  final filled = char.isNotEmpty;
                  final focused = widget.focusNode.hasFocus &&
                      index == widget.controller.text.length.clamp(0, _length - 1);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: AppConstants.minTapTarget,
                    height: AppConstants.minTapTarget,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: focused
                            ? colors.primary
                            : scheme.outlineVariant,
                        width: focused ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      filled ? char : '',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  );
                }),
              ),
              Opacity(
                opacity: 0.01,
                child: SizedBox(
                  width: double.infinity,
                  height: AppConstants.minTapTarget,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    enableIMEPersonalizedLearning: false,
                    autocorrect: false,
                    enableSuggestions: false,
                    maxLength: _length,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
