import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/zone_chip.dart';
import '../../../domain/entities/zone.dart';

class ZoneFilterRow extends StatelessWidget {
  final List<Zone> zones;
  final int selectedZoneId;
  final ValueChanged<int> onSelected;

  const ZoneFilterRow({
    super.key,
    required this.zones,
    required this.selectedZoneId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (zones.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        itemCount: zones.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ZoneChip(
              label: 'All zones',
              selected: selectedZoneId == 0,
              onTap: () => onSelected(0),
            );
          }
          final zone = zones[index - 1];
          return ZoneChip(
            label: zone.name,
            selected: selectedZoneId == zone.id,
            onTap: () => onSelected(zone.id),
          );
        },
      ),
    );
  }
}
