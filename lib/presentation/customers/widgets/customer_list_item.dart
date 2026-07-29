import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../domain/entities/customer.dart';

final _moneyFormat = NumberFormat('#,##0');

/// Customer card for the Customers list. Mirrors the order card's layout —
/// avatar-initial, name, zone/code line, quick call action, and a balance
/// meta-chip — so the two lists feel like one system.
class CustomerListItem extends StatelessWidget {
  final Customer customer;
  final int index;

  const CustomerListItem({super.key, required this.customer, this.index = 0});

  String get _initials {
    final parts = customer.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  Future<void> _call() async {
    final number = customer.fullPhone;
    if (number.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: number);
    // Skip canLaunchUrl — on Android 11+ it can return false for tel: even
    // when a dialer exists; launching directly is more reliable.
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar('Call', 'No dialer app available.');
    }
  }

  Future<void> _navigate() async {
    if (!customer.hasLocation) return;
    final lat = customer.latitude!;
    final lng = customer.longitude!;
    // Prefer the native geo: intent (opens the user's default maps app with a
    // dropped pin); fall back to a Google Maps URL if no geo handler exists.
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(customer.name)})');
    final mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      Get.snackbar('Navigate', 'Could not open a maps app.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (customer.zoneName.trim().isNotEmpty) customer.zoneName.trim(),
      if (customer.partyCode.trim().isNotEmpty) customer.partyCode.trim(),
    ].join(' · ');
    final hasBalance = customer.openingBalance > 0;

    Widget card = AppCard(
      onTap: () => Get.toNamed(AppRoutes.orderCreate, arguments: customer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.foam,
                child: Text(
                  _initials,
                  style: AppTextStyles.label(color: AppColors.elaraBlue)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: AppTextStyles.title().copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!customer.isActive) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _Pill(
                            label: 'Inactive',
                            background: AppColors.mist,
                            color: AppColors.inkMuted,
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTextStyles.label()),
                    ],
                  ],
                ),
              ),
              if (customer.hasValidPhone) ...[
                const SizedBox(width: AppSpacing.sm),
                _IconAction(icon: Icons.call_outlined, onPressed: _call),
              ],
              if (customer.hasLocation) ...[
                const SizedBox(width: AppSpacing.sm),
                _IconAction(icon: Icons.navigation_outlined, onPressed: _navigate),
              ],
            ],
          ),
          if (customer.address.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.inkMuted),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    customer.address.trim(),
                    style: AppTextStyles.body(color: AppColors.inkMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (hasBalance) ...[
            const SizedBox(height: AppSpacing.md),
            _Pill(
              label: 'Balance PKR ${_moneyFormat.format(customer.openingBalance)}',
              background: AppColors.coral.withValues(alpha: 0.12),
              color: AppColors.coral,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            children: [
              const Icon(Icons.add_shopping_cart_outlined, size: 16, color: AppColors.elaraBlue),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'New order',
                style: AppTextStyles.label(color: AppColors.elaraBlue)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.inkFaint),
            ],
          ),
        ],
      ),
    );

    if (index < 8) {
      card = card
          .animate()
          .fadeIn(duration: 320.ms, delay: (index * 40).ms)
          .slideY(begin: 0.08, end: 0, duration: 320.ms, delay: (index * 40).ms, curve: Curves.easeOutCubic);
    }
    return card;
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color color;

  const _Pill({required this.label, required this.background, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(
        label,
        style: AppTextStyles.tabular(AppTextStyles.caption(color: color)).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _IconAction({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.foam,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: AppSpacing.minTapTarget,
          height: AppSpacing.minTapTarget,
          child: Icon(icon, size: 18, color: AppColors.elaraBlue),
        ),
      ),
    );
  }
}
