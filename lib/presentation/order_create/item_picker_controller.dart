import 'dart:async';
import 'package:get/get.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/rider_repository.dart';

class ItemPickerController extends GetxController {
  final RiderRepository _riderRepository = Get.find<RiderRepository>();
  final SessionStorage _sessionStorage = Get.find<SessionStorage>();

  static const int _perPage = 100;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString errorMessage = RxnString();

  final RxList<Item> items = <Item>[].obs;
  final RxInt _page = 1.obs;
  final RxBool _hasMore = false.obs;

  /// null = all types, else 'finished_good' / 'trade_item'.
  final RxnString itemType = RxnString();
  final RxString query = ''.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  int? get _riderId => _sessionStorage.currentRider?.id;

  Future<void> load() async {
    final id = _riderId;
    if (id == null) return;
    isLoading.value = true;
    errorMessage.value = null;
    _page.value = 1;
    try {
      final result = await _riderRepository.getItems(
        riderId: id,
        query: query.value,
        itemType: itemType.value,
        page: 1,
        perPage: _perPage,
      );
      items.assignAll(result.items);
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
      final result = await _riderRepository.getItems(
        riderId: id,
        query: query.value,
        itemType: itemType.value,
        page: next,
        perPage: _perPage,
      );
      items.addAll(result.items);
      _page.value = next;
      _hasMore.value = result.hasMore;
    } catch (_) {
      // Keep loaded items on a transient paging error.
    } finally {
      isLoadingMore.value = false;
    }
  }

  void onSearchChanged(String value) {
    query.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), load);
  }

  void selectType(String? type) {
    if (itemType.value == type) return;
    itemType.value = type;
    load();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
