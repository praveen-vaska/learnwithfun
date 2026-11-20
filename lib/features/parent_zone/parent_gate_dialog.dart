import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class ParentGateDialog extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const ParentGateDialog({super.key, required this.onAuthenticated});

  @override
  State<ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<ParentGateDialog> {
  late int num1;
  late int num2;
  late int correctAnswer;
  final TextEditingController _answerController = TextEditingController();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final random = Random();
    num1 = 6 + random.nextInt(9);
    num2 = 7 + random.nextInt(9);
    correctAnswer = num1 + num2;
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _verify() {
    final input = int.tryParse(_answerController.text.trim());
    if (input == correctAnswer) {
      Navigator.of(context).pop();
      widget.onAuthenticated();
    } else {
      setState(() {
        _hasError = true;
        _answerController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.softPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: AppColors.primaryPurple,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text('Parent Zone Gate', style: AppTextStyles.heading2()),
          const SizedBox(height: 8),
          Text(
            'Please solve this simple arithmetic problem to verify you are a parent:',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(color: AppColors.textMedium),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hasError ? AppColors.red : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: Text(
              '$num1 + $num2 = ?',
              style: AppTextStyles.heading1().copyWith(fontSize: 26),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _answerController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2(),
            decoration: InputDecoration(
              hintText: 'Enter answer',
              errorText: _hasError ? 'Incorrect, try again' : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Unlock',
                  variant: AppButtonVariant.primary,
                  onPressed: _verify,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
