import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';

/// Stub only — see docs/PROJECT.md "Planned, not built yet". Exists so the
/// order card's tap target has somewhere real to go rather than being dead,
/// without building the full Order Detail flow this round.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = Get.parameters['id'];
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        title: Text('Order ${orderId != null ? '#$orderId' : ''}', style: AppTextStyles.h2()),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: EmptyState(
          icon: Icons.construction_outlined,
          title: 'Order detail is coming soon',
          subtitle: 'This screen is planned but not built yet.',
        ),
      ),
    );
  }
}
