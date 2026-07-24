import '../../domain/entities/zone.dart';

class ZoneModel extends Zone {
  const ZoneModel({required super.id, required super.name});

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class AllocationModel extends Allocation {
  const AllocationModel({
    required super.allocationId,
    required super.weekdays,
    required super.weekdayLabels,
    required super.isToday,
    required super.zones,
  });

  factory AllocationModel.fromJson(Map<String, dynamic> json) {
    return AllocationModel(
      allocationId: json['allocation_id'] is int
          ? json['allocation_id'] as int
          : int.tryParse('${json['allocation_id']}') ?? 0,
      weekdays: (json['weekdays'] as List<dynamic>? ?? [])
          .map((e) => e is int ? e : int.tryParse('$e') ?? 0)
          .toList(),
      weekdayLabels: (json['weekday_labels'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isToday: json['is_today'] == true,
      zones: (json['zones'] as List<dynamic>? ?? [])
          .map((e) => ZoneModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
