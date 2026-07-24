import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(color: AppColors.ink)),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body(color: AppColors.inkFaint),
            filled: true,
            fillColor: AppColors.mist,
            suffixIcon: suffixIcon,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              borderSide: const BorderSide(color: AppColors.elaraBlue, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              borderSide: const BorderSide(color: AppColors.coral),
            ),
          ),
        ),
      ],
    );
  }
}
