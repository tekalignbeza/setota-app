import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs)
      : super(Locale(_prefs.getString(AppConstants.localeKey) ?? 'en'));

  void setLocale(String languageCode) {
    state = Locale(languageCode);
    _prefs.setString(AppConstants.localeKey, languageCode);
  }

  void toggleLocale() {
    if (state.languageCode == 'en') {
      setLocale('am');
    } else {
      setLocale('en');
    }
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});
