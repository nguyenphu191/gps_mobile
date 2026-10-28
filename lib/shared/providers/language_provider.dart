import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const supportedLocales = [
  Locale('en'),
  Locale('vi'),
  Locale('ja'),
  Locale('ko'),
  Locale('zh'),
  Locale('pt'),
  Locale('hi'),
  Locale('ar'),
];

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(_loadLocale());

  static Locale _loadLocale() {
    final box = Hive.box('settings');
    final code = box.get('language_code', defaultValue: 'en') as String;
    return Locale(code);
  }

  void setLanguage(String code) {
    final locale = Locale(code);
    if (!supportedLocales.contains(locale)) return;
    Hive.box('settings').put('language_code', code);
    state = locale;
  }

  void setLocale(Locale locale) => setLanguage(locale.languageCode);
}

final languageNotifierProvider =
    StateNotifierProvider<LanguageNotifier, Locale>(
      (ref) => LanguageNotifier(),
    );

final localeProvider = Provider<Locale>((ref) {
  return ref.watch(languageNotifierProvider);
});
