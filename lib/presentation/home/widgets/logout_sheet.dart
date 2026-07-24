import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// "Sign out?" confirmation — a bottom sheet, not a Material dialog, so it
/// matches the rest of the app's geometry (28px top radius). One tap away
/// from the header's logout icon; riders end shifts and hand phones over.
Future<void> showLogoutSheet(BuildContext context, {required VoidCallback onConfirm}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.snow,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.xl,
          AppSpacing.screenPadding,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Sign out?', style: AppTextStyles.h2()),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "You'll need your username and password to sign back in.",
              style: AppTextStyles.body(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body(color: AppColors.inkMuted).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: Text(
                      'Sign Out',
                      style: AppTextStyles.body(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
