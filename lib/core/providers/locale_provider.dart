import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

/// Watches the `language` setting from DB and exposes it as a [Locale].
final localeProvider = StreamProvider<Locale>((ref) {
  return ref.watch(databaseProvider).watchSettings().map((settings) {
    final lang = settings['language'] ?? 'en';
    return Locale(lang);
  });
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._ref) : super(const Locale('en')) {
    _init();
  }

  final Ref _ref;

  Future<void> _init() async {
    final lang =
        await _ref.read(databaseProvider).getSetting('language') ?? 'en';
    state = Locale(lang);
  }

  Future<void> setLocale(String langCode) async {
    await _ref.read(databaseProvider).setSetting('language', langCode);
    state = Locale(langCode);
  }
}

final localeNotifierProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});
