import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final _box = GetStorage();
  static const _key = 'lang_code';

  // Current locale
  final _locale = const Locale('en', 'US').obs;
  Locale get locale => _locale.value;

  // Language options
  final languages = const [
    {'code': 'en', 'country': 'US', 'flag': '🇬🇧', 'name': 'English', 'native': 'English'},
    {'code': 'fr', 'country': 'FR', 'flag': '🇫🇷', 'name': 'Français', 'native': 'French'},
    {'code': 'rw', 'country': 'RW', 'flag': '🇷🇼', 'name': 'Kinyarwanda', 'native': 'Kinyarwanda'},
  ];

  String get currentCode => _locale.value.languageCode;

  String get logoAsset {
    final code = _locale.value.languageCode;
    switch (code) {
      case 'fr':
        return 'assets/francais.jpeg';
      case 'rw':
        return 'assets/Kinyarwanda.jpeg';
      default:
        return 'assets/english.jpeg';
    }
  }

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read<String>(_key);
    if (saved != null) _applyLocale(saved);
  }

  void changeLanguage(String code) {
    _box.write(_key, code);
    _applyLocale(code);
  }

  void _applyLocale(String code) {
    final lang = languages.firstWhere(
          (l) => l['code'] == code,
      orElse: () => languages[0],
    );
    final locale = Locale(lang['code']!, lang['country']!);
    _locale.value = locale;
    Get.updateLocale(locale);
  }
}