import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final int? maxLength;
  final bool autoFocus;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.maxLength,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium(
            color: AppColors.textDark,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          autofocus: autoFocus,
          style: AppTextStyles.bodyLarge(color: AppColors.textDark),
          decoration: InputDecoration(
            counterText: '', // Hide default counter text for clean UI
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMedium(color: AppColors.textLight),
            prefixIcon: prefixIcon,
            prefix: prefix,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.primaryPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.red, width: 2),
            ),
            errorStyle: AppTextStyles.bodySmall(
              color: AppColors.red,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
