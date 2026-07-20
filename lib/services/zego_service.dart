import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// Holds Zego Cloud credentials and ensures mic/camera permissions.
/// Call UI uses [ZegoUIKitPrebuiltCall] with a shared [roomId] from chat bubbles.
class ZegoService extends GetxService {
  static const int appId = 39170864;
  static const String appSign =
      'd8310a579d821fec5c7487e95883b02bcf8ac20ab9f0dbebc487fc7bb112cbd8';

  bool _isInitialized = false;
  final RxString currentUserID = ''.obs;
  final RxString currentUserName = ''.obs;

  bool get isInitialized => _isInitialized;
  String get userID => currentUserID.value;
  String get userName => currentUserName.value;

  Future<void> init({
    required String userID,
    required String userName,
  }) async {
    currentUserID.value = userID;
    currentUserName.value = userName;
    _isInitialized = true;
  }

  Future<void> updateUser(String userID, String userName) async {
    currentUserID.value = userID;
    currentUserName.value = userName;
  }

  Future<bool> ensureCallPermissions({required bool video}) async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      debugPrint('Microphone permission denied');
      return false;
    }
    if (video) {
      final cam = await Permission.camera.request();
      if (!cam.isGranted) {
        debugPrint('Camera permission denied');
        return false;
      }
    }
    return true;
  }

  Future<void> logout() async {
    _isInitialized = false;
    currentUserID.value = '';
    currentUserName.value = '';
  }

  @override
  void onClose() {
    logout();
    super.onClose();
  }
}
