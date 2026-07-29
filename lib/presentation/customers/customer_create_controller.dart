import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/rider_repository.dart';
import '../location_picker/location_picker_screen.dart';

class CustomerCreateController extends GetxController {
  final RiderRepository _riderRepository = Get.find<RiderRepository>();
  final SessionStorage _sessionStorage = Get.find<SessionStorage>();

  /// Allowed dialing codes per the customer_create spec.
  static const List<String> countryCodes = ['+92', '+971', '+966', '+1', '+44'];

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final openingBalanceController = TextEditingController();

  final RxString phoneCountryCode = countryCodes.first.obs;
  final RxnInt selectedZoneId = RxnInt();

  /// Coordinates picked on the map, if any.
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();
  bool get hasLocation => latitude.value != null && longitude.value != null;

  final RxList<Zone> zones = <Zone>[].obs;
  final RxBool isSaving = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadZones();
  }

  Future<void> _loadZones() async {
    final id = _sessionStorage.currentRider?.id;
    if (id == null) return;
    try {
      final allocations = await _riderRepository.getAllocatedZones(riderId: id);
      final map = <int, Zone>{};
      for (final a in allocations) {
        for (final z in a.zones) {
          map[z.id] = z;
        }
      }
      zones.assignAll(map.values);
    } catch (_) {
      // Zone selection is optional; ignore load failures.
    }
  }

  void setCountryCode(String? code) {
    if (code != null) phoneCountryCode.value = code;
  }

  void setZone(int? zoneId) => selectedZoneId.value = zoneId;

  Future<void> pickLocation() async {
    final result = await Get.to<PickedLocation>(
      () => LocationPickerScreen(
        initialLatitude: latitude.value,
        initialLongitude: longitude.value,
      ),
    );
    if (result != null) {
      latitude.value = result.latitude;
      longitude.value = result.longitude;
      // Auto-fill the address, but only if the user hasn't typed one already.
      if (result.address.isNotEmpty && addressController.text.trim().isEmpty) {
        addressController.text = result.address;
      }
    }
  }

  void clearLocation() {
    latitude.value = null;
    longitude.value = null;
  }

  Future<void> save() async {
    final id = _sessionStorage.currentRider?.id;
    if (id == null) return;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      errorMessage.value = 'Customer name is required.';
      return;
    }

    final balanceText = openingBalanceController.text.trim();

    errorMessage.value = null;
    isSaving.value = true;
    try {
      final created = await _riderRepository.createCustomer(
        riderId: id,
        name: name,
        phone: phoneController.text.trim(),
        phoneCountryCode: phoneCountryCode.value,
        address: addressController.text.trim(),
        email: emailController.text.trim(),
        zoneId: selectedZoneId.value,
        latitude: latitude.value,
        longitude: longitude.value,
        openingBalance: balanceText.isEmpty ? null : double.tryParse(balanceText),
      );
      Get.back<Customer>(result: created);
      Get.snackbar('Customer', 'Customer created.');
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    openingBalanceController.dispose();
    super.onClose();
  }
}
