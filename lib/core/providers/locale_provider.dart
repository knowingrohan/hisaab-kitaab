import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hisaab_kitaab/core/repositories/config_repository.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._ref) : super(const Locale('en')) {
    _init();
  }

  final Ref _ref;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString('language');
    if (local != null) {
      state = Locale(local);
      return;
    }
    // Fallback: read from Supabase config.
    final config = await _ref.read(configRepositoryProvider).getConfig();
    if (config != null && config.language.isNotEmpty) {
      state = Locale(config.language);
    }
  }

  Future<void> setLocale(String langCode) async {
    state = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    await _ref.read(configRepositoryProvider).upsert({'language': langCode});
  }
}

final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});
