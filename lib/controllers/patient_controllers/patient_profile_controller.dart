import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/patient_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../auth_controllers/auth_controller.dart';

class PatientProfileController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();
  final _box = GetStorage();
  static const _key = 'patient_notifications_enabled';

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Rx<PatientModel?> patient = Rx<PatientModel?>(null);
  Rx<UserModel?> user = Rx<UserModel?>(null);
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
      final uid = _authCtrl.user.value?.id ?? '';
      if (uid.isEmpty) return;
      user.value = _authCtrl.user.value;
      final data = await FirebaseService.getPatientById(uid);
      if (data != null) {
        patient.value = data;
      }
      final userData = await FirebaseService.getUserData(uid);
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

  Future<bool> saveProfile(UserModel updatedUser, PatientModel updatedPatient) async {
    try {
      await FirebaseService.updateUser(updatedUser);
      await FirebaseService.updatePatient(updatedPatient);
      user.value = updatedUser;
      patient.value = updatedPatient;
      _authCtrl.user.value = updatedUser;
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
        role: _authCtrl.user.value?.role ?? UserRole.patient,
        fcmToken: _authCtrl.user.value?.fcmToken,
        createdAt: _authCtrl.user.value?.createdAt,
        notificationsEnabled: value,
      ));
    }
  }

  bool get hasProfile => patient.value != null || user.value != null;
}
