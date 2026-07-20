// ============================================================
// FILE: lib/controllers/provider_profile_controller.dart
// ============================================================

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/provider_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../auth_controllers/auth_controller.dart';

class ProviderProfileController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();
  final _box = GetStorage();
  static const _key = 'provider_notifications_enabled';

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Rx<ProviderModel?> profile = Rx<ProviderModel?>(null);
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    notificationsEnabled.value = _box.read(_key) ?? true;
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final providerId = _authCtrl.user.value?.id ?? '';
      if (providerId.isEmpty) return;
      final data = await FirebaseService.getProviderById(providerId);
      if (data != null) {
        profile.value = data;
      }
      final userData = await FirebaseService.getUserData(providerId);
      if (userData != null) {
        notificationsEnabled.value = userData.notificationsEnabled;
        _box.write(_key, userData.notificationsEnabled);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveProfile(ProviderModel updated) async {
    try {
      await FirebaseService.updateProvider(updated);
      profile.value = updated;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    await _box.write(_key, value);
    final uid = _authCtrl.user.value?.id;
    if (uid != null && uid.isNotEmpty) {
      await FirebaseService.updateUser(UserModel(
        id: uid,
        name: _authCtrl.user.value?.name ?? '',
        email: _authCtrl.user.value?.email ?? '',
        phone: _authCtrl.user.value?.phone ?? '',
        role: _authCtrl.user.value?.role ?? UserRole.provider,
        fcmToken: _authCtrl.user.value?.fcmToken,
        createdAt: _authCtrl.user.value?.createdAt,
        notificationsEnabled: value,
      ));
    }
  }

  bool get hasProfile => profile.value != null;
}
