import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/elara_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../widgets/water/liquid_caustics_background.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.waterPale,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: screenHeight * 0.42,
                child: LiquidCausticsBackground(
                  colorDeep: AppColors.abyss,
                  colorLight: AppColors.marine,
                  intensity: 0.9,
                  child: SafeArea(
                    bottom: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const ElaraLogo(size: 64, showWordmark: false),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Rider Portal', style: AppTextStyles.h1(color: Colors.white)),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Sign in to start your route',
                            style: AppTextStyles.body(color: Colors.white.withValues(alpha: 0.75)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Obx(
                  () => _LoginSheet(
                    key: ValueKey(controller.shakeTrigger.value),
                    controller: controller,
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

class _LoginSheet extends StatelessWidget {
  final LoginController controller;

  const _LoginSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    Widget sheet = Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xxxl,
        AppSpacing.screenPadding,
        AppSpacing.xxxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Username',
            controller: controller.usernameController,
            hint: 'Enter your username',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: AppSpacing.lg),
          Obx(
            () => AppTextField(
              label: 'Password',
              controller: controller.passwordController,
              hint: 'Enter your password',
              obscureText: controller.obscurePassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.inkFaint,
                ),
                onPressed: controller.toggleObscurePassword,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Obx(() {
            if (controller.errorText.value == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.coral, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      controller.errorText.value!,
                      style: AppTextStyles.label(color: AppColors.coral),
                    ),
                  ),
                ],
              ),
            );
          }),
          Builder(
            builder: (buttonContext) => Obx(
              () => PrimaryButton(
                label: 'Sign In',
                isLoading: controller.isLoading.value,
                onPressed: () => controller.login(buttonContext),
              ),
            ),
          ),
        ],
      ),
    );

    // Only shake on a remount triggered by a failed attempt (shakeTrigger >
    // 0) — the very first mount (trigger == 0) should render calmly.
    if (controller.shakeTrigger.value > 0) {
      sheet = sheet.animate().shakeX(hz: 4, amount: 8, duration: 420.ms);
    }
    return sheet;
  }
}
