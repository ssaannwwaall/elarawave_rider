import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.h2()),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.rider.value == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.elaraBlue));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.lg,
            AppSpacing.screenPadding,
            AppSpacing.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AvatarPicker(),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                label: 'Name',
                controller: controller.nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Email',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Username',
                controller: controller.usernameController,
              ),
              // const SizedBox(height: AppSpacing.lg),
              // Obx(
              //   () => AppTextField(
              //     label: 'New password (optional)',
              //     hint: 'Leave blank to keep current',
              //     controller: controller.passwordController,
              //     obscureText: controller.obscurePassword.value,
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //         controller.obscurePassword.value
              //             ? Icons.visibility_off_outlined
              //             : Icons.visibility_outlined,
              //         color: AppColors.inkMuted,
              //       ),
              //       onPressed: controller.toggleObscurePassword,
              //     ),
              //   ),
              // ),
              const SizedBox(height: AppSpacing.lg),
              Obx(() {
                final error = controller.errorMessage.value;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(error, style: AppTextStyles.caption(color: AppColors.coral)),
                );
              }),
              Obx(
                () => PrimaryButton(
                  label: 'Save changes',
                  isLoading: controller.isSaving.value,
                  onPressed: controller.isSaving.value ? null : controller.save,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Center(
      child: Obx(() {
        final picked = controller.pickedPhotoPath.value;
        final rider = controller.rider.value;
        ImageProvider? image;
        if (picked != null) {
          image = FileImage(File(picked));
        } else if (rider != null && rider.hasPhoto) {
          image = NetworkImage(rider.photoUrl);
        }

        return Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.mist,
              backgroundImage: image,
              child: image == null
                  ? Text(
                      _initials(rider?.name ?? ''),
                      style: AppTextStyles.h1(color: AppColors.elaraBlue),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: AppColors.elaraBlue,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: controller.pickPhoto,
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }
}
