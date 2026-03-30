import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/providers/database_provider.dart';

/// Reactive stream of all app_settings as a key→value map.
final settingsProvider = StreamProvider<Map<String, String>>((ref) {
  return ref.watch(databaseProvider).watchSettings();
});

/// Derived provider: the alert threshold integer (defaults to 200).
final alertThresholdProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull ?? {};
  return int.tryParse(settings['alert_threshold'] ?? '200') ?? 200;
});
