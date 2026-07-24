class Zone {
  final int id;
  final String name;

  const Zone({required this.id, required this.name});
}

class Allocation {
  final int allocationId;
  final List<int> weekdays;
  final List<String> weekdayLabels;
  final bool isToday;
  final List<Zone> zones;

  const Allocation({
    required this.allocationId,
    required this.weekdays,
    required this.weekdayLabels,
    required this.isToday,
    required this.zones,
  });
}
