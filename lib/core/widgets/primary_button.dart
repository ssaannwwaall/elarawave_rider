import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Flat elaraBlue CTA. While loading, a real water animation
/// (assets/lottie/material_wave_loading.json) floods the button so it reads
/// as water rising in place — not a spinner, not a hand-drawn wave.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: disabled ? AppColors.inkFaint.withValues(alpha: 0.35) : AppColors.elaraBlue,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Stack(
          children: [
            if (isLoading)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  child: Lottie.asset(
                    'assets/lottie/material_wave_loading.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.button),
                onTap: disabled ? null : onPressed,
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.body(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
