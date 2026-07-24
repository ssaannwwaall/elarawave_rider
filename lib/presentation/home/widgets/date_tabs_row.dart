import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/date_tab_chip.dart';

class DateTabsRow extends StatelessWidget {
  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DateTabsRow({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onSelected,
  });

  String _topLabel(int index, DateTime date) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tomorrow';
    return DateFormat('EEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final date = dates[index];
          return DateTabChip(
            topLabel: _topLabel(index, date),
            bottomLabel: DateFormat('d').format(date),
            selected: index == selectedIndex,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}
