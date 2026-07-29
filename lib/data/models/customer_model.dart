import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    super.partyCode,
    required super.name,
    super.phoneCountryCode,
    super.phone,
    super.address,
    super.email,
    super.latitude,
    super.longitude,
    super.zoneId,
    super.zoneName,
    super.isActive,
    super.openingBalance,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    int? intOrNull(dynamic v) =>
        v == null ? null : (v is int ? v : int.tryParse('$v'));
    double? doubleOrNull(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

    return CustomerModel(
      id: intOrNull(json['id']) ?? 0,
      partyCode: json['party_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phoneCountryCode: json['phone_country_code']?.toString() ?? '+92',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      latitude: doubleOrNull(json['latitude']),
      longitude: doubleOrNull(json['longitude']),
      zoneId: intOrNull(json['zone_id']),
      zoneName: json['zone_name']?.toString() ?? '',
      isActive: intOrNull(json['is_active']) != 0,
      openingBalance: doubleOrNull(json['opening_balance']) ?? 0,
    );
  }
}

class CustomerPageModel extends CustomerPage {
  const CustomerPageModel({
    super.page,
    super.perPage,
    super.total,
    super.customers,
  });

  factory CustomerPageModel.fromJson(Map<String, dynamic> json) {
    int intOr(dynamic v, int fallback) =>
        v is int ? v : int.tryParse('$v') ?? fallback;

    final rows = json['customers'] as List<dynamic>? ?? [];
    return CustomerPageModel(
      page: intOr(json['page'], 1),
      perPage: intOr(json['per_page'], 50),
      total: intOr(json['total'], rows.length),
      customers: rows
          .whereType<Map<String, dynamic>>()
          .map((e) => CustomerModel.fromJson(e))
          .toList(),
    );
  }
}
