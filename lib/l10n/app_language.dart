import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  static final ValueNotifier<String> notifier = ValueNotifier<String>('tr');

  static String get code => notifier.value;
  static bool get isEnglish => notifier.value == 'en';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('appLanguage');

    if (saved == 'tr' || saved == 'en') {
      notifier.value = saved!;
    }
  }

  static Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'tr' && languageCode != 'en') return;

    notifier.value = languageCode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLanguage', languageCode);
  }

  static Future<void> toggle() async {
    await setLanguage(isEnglish ? 'tr' : 'en');
  }
}
