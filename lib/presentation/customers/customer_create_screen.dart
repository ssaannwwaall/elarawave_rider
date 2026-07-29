import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'customer_create_controller.dart';

class CustomerCreateScreen extends GetView<CustomerCreateController> {
  const CustomerCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        title: Text('New customer', style: AppTextStyles.h2()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.lg,
          AppSpacing.screenPadding,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Name',
              hint: 'Customer name',
              controller: controller.nameController,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: AppSpacing.lg),
            _PhoneField(controller: controller),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Address (optional)',
              controller: controller.addressController,
              keyboardType: TextInputType.streetAddress,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Email (optional)',
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ZoneDropdown(controller: controller),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Opening balance (optional)',
              hint: '0',
              controller: controller.openingBalanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            _LocationField(controller: controller),
            const SizedBox(height: AppSpacing.xl),
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
                label: 'Create customer',
                isLoading: controller.isSaving.value,
                onPressed: controller.isSaving.value ? null : controller.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final CustomerCreateController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone (optional)', style: AppTextStyles.label(color: AppColors.ink)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(color: AppColors.line),
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.phoneCountryCode.value,
                    onChanged: controller.setCountryCode,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    style: AppTextStyles.body(),
                    items: [
                      for (final code in CustomerCreateController.countryCodes)
                        DropdownMenuItem(value: code, child: Text(code)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  hintText: '3001234567',
                  hintStyle: AppTextStyles.body(color: AppColors.inkFaint),
                  filled: true,
                  fillColor: AppColors.mist,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 14,
                  ),
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
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationField extends StatelessWidget {
  final CustomerCreateController controller;

  const _LocationField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Map location (optional)', style: AppTextStyles.label(color: AppColors.ink)),
        const SizedBox(height: AppSpacing.sm),
        Obx(() {
          final hasLocation = controller.hasLocation;
          return Material(
            color: AppColors.mist,
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.button),
              onTap: controller.pickLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasLocation ? Icons.location_on : Icons.add_location_alt_outlined,
                      color: AppColors.elaraBlue,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: hasLocation
                          ? Text(
                              '${controller.latitude.value!.toStringAsFixed(6)}, '
                              '${controller.longitude.value!.toStringAsFixed(6)}',
                              style: AppTextStyles.tabular(AppTextStyles.body()),
                            )
                          : Text(
                              'Pick location on map',
                              style: AppTextStyles.body(color: AppColors.inkMuted),
                            ),
                    ),
                    if (hasLocation)
                      GestureDetector(
                        onTap: controller.clearLocation,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 18, color: AppColors.inkMuted),
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right, color: AppColors.inkFaint),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ZoneDropdown extends StatelessWidget {
  final CustomerCreateController controller;

  const _ZoneDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final zones = controller.zones;
      if (zones.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zone (optional)', style: AppTextStyles.label(color: AppColors.ink)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: AppColors.line),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: controller.selectedZoneId.value,
                isExpanded: true,
                onChanged: controller.setZone,
                borderRadius: BorderRadius.circular(AppRadius.button),
                style: AppTextStyles.body(),
                hint: Text('Select a zone', style: AppTextStyles.body(color: AppColors.inkFaint)),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('No zone', style: AppTextStyles.body(color: AppColors.inkMuted)),
                  ),
                  for (final zone in zones)
                    DropdownMenuItem<int?>(value: zone.id, child: Text(zone.name)),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
