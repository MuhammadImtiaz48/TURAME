// ============================================================
// FILE: lib/services/user_storage_service.dart
// ============================================================

import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class UserStorageService {
  static final _box = GetStorage();
  static const _userKey = 'current_user';
  static const _phoneKey = 'pending_phone';

  static Future<void> saveUser(UserModel user) async {
    await _box.write(_userKey, jsonEncode(user.toJsonMap()));
  }

  static Future<UserModel?> loadUser() async {
    final json = _box.read<String>(_userKey);
    if (json != null) {
      return UserModel.fromMap(jsonDecode(json) as Map<String, dynamic>);
    }
    return null;
  }

  static Future<void> clear() async {
    await _box.remove(_userKey);
    await _box.remove(_phoneKey);
  }

  static Future<void> savePhone(String phone) async {
    await _box.write(_phoneKey, phone);
  }

  static Future<String?> loadPhone() async {
    return _box.read<String>(_phoneKey);
  }
}