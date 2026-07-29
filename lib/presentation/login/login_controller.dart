import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/repositories/rider_repository.dart';
import '../widgets/water/purity_ripple.dart';

class LoginController extends GetxController {
  final RiderRepository _riderRepository = Get.find<RiderRepository>();
  final SessionStorage _sessionStorage = Get.find<SessionStorage>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  final companyController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxnString errorText = RxnString();
  /// Bumped on every failed attempt so the sheet's shake animation restarts.
  final RxInt shakeTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Prefill the company from the last successful login (kept across logout).
    companyController.text = _sessionStorage.company;
    // Dev convenience only — never active in a release build.
    if (kDebugMode) {
      if (companyController.text.isEmpty) companyController.text = 'demo';
      usernameController.text = 'test00';
      passwordController.text = 'test00';
    }
  }

  void toggleObscurePassword() => obscurePassword.value = !obscurePassword.value;

  Future<void> login(BuildContext context) async {
    final company = companyController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (company.isEmpty || username.isEmpty || password.isEmpty) {
      errorText.value = 'Please enter your company, username and password.';
      shakeTrigger.value++;
      return;
    }

    // Point the API client at this company's tenant before authenticating.
    _apiClient.setCompany(company);

    errorText.value = null;
    isLoading.value = true;
    try {
      final rider = await _riderRepository.login(username: username, password: password);
      await _sessionStorage.saveCompany(company);
      await _sessionStorage.saveRider(rider);
      if (context.mounted) {
        PurityRipple.showAtWidget(context, color: AppColors.aqua);
      }
      Get.offAllNamed(AppRoutes.home);
    } on ApiException catch (e) {
      errorText.value = e.message;
      shakeTrigger.value++;
    } catch (_) {
      errorText.value = 'Something went wrong. Please try again.';
      shakeTrigger.value++;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    companyController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
