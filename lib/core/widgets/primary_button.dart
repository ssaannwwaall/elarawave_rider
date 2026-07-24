import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../presentation/widgets/water/wave_fill.dart';

/// Flat elaraBlue — the light "surface" zone stays clean and flat by
/// design; gradients are reserved for the water header. In the loading
/// state, a [WaveFill] sweeps left-to-right instead of a spinner.
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
                child: WaveFill(
                  progress: 1,
                  backColor: Colors.white.withValues(alpha: 0.12),
                  frontColor: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(AppRadius.button),
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
