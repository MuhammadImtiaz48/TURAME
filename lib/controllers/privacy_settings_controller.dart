import 'package:get/get.dart';
import '../../models/privacy_setting_model.dart';
import '../../services/firebase_service.dart';
import 'auth_controllers/auth_controller.dart';

class PrivacySettingsController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();

  final Rx<PrivacySettingModel?> settings = Rx<PrivacySettingModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final uid = _authCtrl.user.value?.id ?? '';
      if (uid.isEmpty) return;

      final data = await FirebaseService.getPrivacySettings(uid);
      if (data != null) {
        settings.value = data;
      } else {
        settings.value = PrivacySettingModel(userId: uid);
        await FirebaseService.savePrivacySettings(settings.value!);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfileVisibility(PrivacyProfileVisibility visibility) async {
    try {
      final uid = _authCtrl.user.value?.id;
      if (uid == null || uid.isEmpty) return false;

      settings.value = settings.value?.copyWith(
        profileVisibility: visibility,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updatePrivacySetting(uid, {
        'profileVisibility': visibility.name,
      });

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateDataSharing(DataSharingLevel level) async {
    try {
      final uid = _authCtrl.user.value?.id;
      if (uid == null || uid.isEmpty) return false;

      settings.value = settings.value?.copyWith(
        dataSharing: level,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updatePrivacySetting(uid, {
        'dataSharing': level.name,
      });

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateAnalyticsEnabled(bool value) async {
    try {
      final uid = _authCtrl.user.value?.id;
      if (uid == null || uid.isEmpty) return false;

      settings.value = settings.value?.copyWith(
        analyticsEnabled: value,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updatePrivacySetting(uid, {
        'analyticsEnabled': value,
      });

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateMarketingEmails(bool value) async {
    try {
      final uid = _authCtrl.user.value?.id;
      if (uid == null || uid.isEmpty) return false;

      settings.value = settings.value?.copyWith(
        marketingEmails: value,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updatePrivacySetting(uid, {
        'marketingEmails': value,
      });

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateLocationSharing(bool value) async {
    try {
      final uid = _authCtrl.user.value?.id;
      if (uid == null || uid.isEmpty) return false;

      settings.value = settings.value?.copyWith(
        locationSharing: value,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updatePrivacySetting(uid, {
        'locationSharing': value,
      });

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateShowContactInfo(bool value) async {
    try {
      final uid = _authCtrl.user.value?.id;
      if (uid == null || uid.isEmpty) return false;

      settings.value = settings.value?.copyWith(
        showContactInfo: value,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updatePrivacySetting(uid, {
        'showContactInfo': value,
      });

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateSearchableByPhone(bool value) async {
    try {
      final uid = _authCtrl.user.value?.id;
      if (uid == null || uid.isEmpty) return false;

      settings.value = settings.value?.copyWith(
        searchableByPhone: value,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updatePrivacySetting(uid, {
        'searchableByPhone': value,
      });

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final uid = _authCtrl.user.value?.id;
      if (uid == null || uid.isEmpty) return;

      settings.value = PrivacySettingModel(userId: uid);
      await FirebaseService.savePrivacySettings(settings.value!);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }
}
