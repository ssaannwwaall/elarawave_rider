import 'dart:async';
import 'package:get/get.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/rider_repository.dart';

class CustomerListController extends GetxController {
  final RiderRepository _riderRepository = Get.find<RiderRepository>();
  final SessionStorage _sessionStorage = Get.find<SessionStorage>();

  static const int _perPage = 50;

  final RxBool isLoading = false.obs; // first page load / reload
  final RxBool isLoadingMore = false.obs;
  final RxnString errorMessage = RxnString();

  final RxList<Customer> customers = <Customer>[].obs;
  final RxInt total = 0.obs;
  final RxInt _page = 1.obs;
  final RxBool _hasMore = false.obs;
  bool get hasMore => _hasMore.value;

  /// Allocated zones, used to power the zone filter chips.
  final RxList<Zone> zones = <Zone>[].obs;
  final RxnInt selectedZoneId = RxnInt();

  final RxString query = ''.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _loadZones();
    loadCustomers();
  }

  int? get _riderId => _sessionStorage.currentRider?.id;

  Future<void> _loadZones() async {
    final id = _riderId;
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
      // Zone filter is optional; ignore load failures silently.
    }
  }

  Future<void> loadCustomers() async {
    final id = _riderId;
    if (id == null) return;
    isLoading.value = true;
    errorMessage.value = null;
    _page.value = 1;
    try {
      final result = await _riderRepository.getCustomers(
        riderId: id,
        query: query.value,
        zoneId: selectedZoneId.value,
        page: 1,
        perPage: _perPage,
      );
      customers.assignAll(result.customers);
      total.value = result.total;
      _hasMore.value = result.hasMore;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    final id = _riderId;
    if (id == null || !_hasMore.value || isLoadingMore.value || isLoading.value) {
      return;
    }
    isLoadingMore.value = true;
    try {
      final next = _page.value + 1;
      final result = await _riderRepository.getCustomers(
        riderId: id,
        query: query.value,
        zoneId: selectedZoneId.value,
        page: next,
        perPage: _perPage,
      );
      customers.addAll(result.customers);
      total.value = result.total;
      _page.value = next;
      _hasMore.value = result.hasMore;
    } on ApiException catch (e) {
      Get.snackbar('Customers', e.message);
    } catch (_) {
      // Keep the already-loaded page; a transient paging error is non-fatal.
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshCustomers() => loadCustomers();

  void onSearchChanged(String value) {
    query.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), loadCustomers);
  }

  void selectZone(int? zoneId) {
    if (selectedZoneId.value == zoneId) return;
    selectedZoneId.value = zoneId;
    loadCustomers();
  }

  Future<void> openCreate() async {
    final created = await Get.toNamed(AppRoutes.customerCreate);
    if (created is Customer) {
      // Reload so the new customer appears in the correct sorted position.
      loadCustomers();
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
