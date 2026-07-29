import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/entities/rider.dart';
import '../../domain/repositories/rider_repository.dart';

class ProfileController extends GetxController {
  final RiderRepository _riderRepository = Get.find<RiderRepository>();
  final SessionStorage _sessionStorage = Get.find<SessionStorage>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs; // initial profile fetch
  final RxBool isSaving = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxnString errorMessage = RxnString();

  final Rx<Rider?> rider = Rx<Rider?>(null);
  /// Local path of a newly-picked photo, not yet uploaded. Null means "keep
  /// the existing photo".
  final RxnString pickedPhotoPath = RxnString();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Seed from the cached session immediately so fields aren't blank while
    // the fresh copy loads.
    final cached = _sessionStorage.currentRider;
    if (cached != null) _applyRider(cached);
    _loadProfile();
  }

  void _applyRider(Rider r) {
    rider.value = r;
    nameController.text = r.name;
    emailController.text = r.email;
    usernameController.text = r.username;
  }

  Future<void> _loadProfile() async {
    final id = _sessionStorage.currentRider?.id;
    if (id == null) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final fresh = await _riderRepository.getProfile(riderId: id);
      _applyRider(fresh);
      await _sessionStorage.saveRider(fresh);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleObscurePassword() => obscurePassword.value = !obscurePassword.value;

  Future<void> pickPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file != null) pickedPhotoPath.value = file.path;
    } catch (_) {
      Get.snackbar('Photo', 'Could not open the gallery.');
    }
  }

  Future<void> save() async {
    final id = rider.value?.id ?? _sessionStorage.currentRider?.id;
    if (id == null) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || username.isEmpty) {
      errorMessage.value = 'Name, email and username are required.';
      return;
    }

    errorMessage.value = null;
    isSaving.value = true;
    try {
      final updated = await _riderRepository.updateProfile(
        riderId: id,
        name: name,
        email: email,
        username: username,
        password: password.isEmpty ? null : password,
        photoPath: pickedPhotoPath.value,
      );
      _applyRider(updated);
      await _sessionStorage.saveRider(updated);
      pickedPhotoPath.value = null;
      passwordController.clear();
      Get.snackbar('Profile', 'Your profile has been updated.');
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
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
