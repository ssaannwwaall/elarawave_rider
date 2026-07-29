class Customer {
  final int id;
  final String partyCode;
  final String name;
  final String phoneCountryCode;
  final String phone;
  final String address;
  final String email;
  final double? latitude;
  final double? longitude;
  final int? zoneId;
  final String zoneName;
  final bool isActive;
  final double openingBalance;

  const Customer({
    required this.id,
    this.partyCode = '',
    required this.name,
    this.phoneCountryCode = '+92',
    this.phone = '',
    this.address = '',
    this.email = '',
    this.latitude,
    this.longitude,
    this.zoneId,
    this.zoneName = '',
    this.isActive = true,
    this.openingBalance = 0,
  });

  /// Full dialable number, or empty when no real phone is set. The API often
  /// returns just the country code (e.g. "+92") as a placeholder.
  String get fullPhone {
    final p = phone.trim();
    if (p.isEmpty) return '';
    return '${phoneCountryCode.trim()}$p';
  }

  bool get hasValidPhone => phone.trim().isNotEmpty;

  bool get hasLocation => latitude != null && longitude != null;
}

/// One page of a `customer_list` response, carrying pagination metadata
/// alongside the rows so the list screen can page through results.
class CustomerPage {
  final int page;
  final int perPage;
  final int total;
  final List<Customer> customers;

  const CustomerPage({
    this.page = 1,
    this.perPage = 50,
    this.total = 0,
    this.customers = const [],
  });

  bool get hasMore => page * perPage < total;
}
