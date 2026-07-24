import 'dart:async';
import 'package:get/get.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/entities/rider.dart';
import '../../domain/entities/todo_list.dart';
import '../../domain/entities/zone.dart';
import '../../domain/repositories/rider_repository.dart';

class HomeController extends GetxController {
  final RiderRepository _riderRepository = Get.find<RiderRepository>();
  final SessionStorage _sessionStorage = Get.find<SessionStorage>();

  Rider get rider => _sessionStorage.currentRider!;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  /// Today + tomorrow + next 3 calendar days = 5 tabs.
  late final List<DateTime> dates = List.generate(
    5,
    (i) => DateTime.now().add(Duration(days: i)),
  );

  final RxInt selectedDateIndex = 0.obs;
  final RxInt selectedZoneId = 0.obs; // 0 = all zones
  final RxString searchQuery = ''.obs;

  final RxList<Zone> zones = <Zone>[].obs;
  final Rx<ToDoList?> toDoList = Rx<ToDoList?>(null);
  /// Header stats are always *today's* totals regardless of the selected
  /// tab (brief: "today's three summary stats") — kept separate from
  /// [toDoList] so switching to a future tab doesn't blank them out.
  final Rx<ToDoSummary> todaySummary = Rx<ToDoSummary>(const ToDoSummary.empty());

  final RxBool isLoadingZones = false.obs;
  final RxBool isLoadingToDo = false.obs;
  final RxnString errorMessage = RxnString();

  /// True whenever a non-today tab is selected. The `todo_list` endpoint
  /// only documents `rider_id` today (docs/API.md "Known gap") — rather
  /// than silently showing today's orders under tomorrow's tab, other days
  /// show a clean "not published yet" state until the backend adds a date
  /// param. `fetchOrders`-equivalent logic below is structured so wiring
  /// that param through is a one-line change once confirmed.
  final RxBool scheduleNotPublished = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _loadZones();
    _loadToDoList();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _loadZones() async {
    isLoadingZones.value = true;
    try {
      final allocations = await _riderRepository.getAllocatedZones(riderId: rider.id);
      final seen = <int>{};
      final flattened = <Zone>[];
      for (final allocation in allocations) {
        for (final zone in allocation.zones) {
          if (seen.add(zone.id)) flattened.add(zone);
        }
      }
      zones.assignAll(flattened);
    } on ApiException {
      // Zone strip is secondary chrome; fail silently and leave it empty
      // rather than blocking the order list with an error banner.
    } finally {
      isLoadingZones.value = false;
    }
  }

  Future<void> _loadToDoList() async {
    if (selectedDateIndex.value != 0) {
      scheduleNotPublished.value = true;
      toDoList.value = null;
      errorMessage.value = null;
      isLoadingToDo.value = false;
      return;
    }
    scheduleNotPublished.value = false;
    isLoadingToDo.value = true;
    errorMessage.value = null;
    try {
      final selectedDate = dates[selectedDateIndex.value];
      final result = await _riderRepository.getToDoList(
        riderId: rider.id,
        date: selectedDate,
        zoneId: selectedZoneId.value == 0 ? null : selectedZoneId.value,
        query: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      toDoList.value = result;
      todaySummary.value = result.summary;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoadingToDo.value = false;
    }
  }

  void selectDate(int index) {
    if (index == selectedDateIndex.value) return;
    selectedDateIndex.value = index;
    _loadToDoList();
  }

  void selectZone(int zoneId) {
    if (zoneId == selectedZoneId.value) return;
    selectedZoneId.value = zoneId;
    _loadToDoList();
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchQuery.value = query;
      _loadToDoList();
    });
  }

  Future<void> refreshData() async {
    await Future.wait([_loadZones(), _loadToDoList()]);
  }

  /// Purely local — there is no logout/token-invalidation endpoint yet
  /// (docs/API.md "Pending"). Clears the session, then resets every
  /// non-permanent GetX controller so a fresh login never inherits stale
  /// zone/order state from the previous rider.
  Future<void> logout() async {
    await _sessionStorage.clear();
    Get.deleteAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
