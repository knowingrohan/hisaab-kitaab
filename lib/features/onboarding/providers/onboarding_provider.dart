import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hisaab_kitaab/core/repositories/config_repository.dart';
import 'package:hisaab_kitaab/core/repositories/society_repository.dart';

/// null = still loading, true = done, false = needs onboarding
final onboardingDoneProvider = Provider<bool?>((ref) {
  return ref.watch(appConfigProvider).whenOrNull(
    data: (config) => config != null && config.businessName.isNotEmpty,
  );
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._ref) : super(false);

  final Ref _ref;

  /// Claim owner_uid when user taps "Get Started" (step 0 → 1).
  Future<void> createInitialConfig() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await _ref.read(configRepositoryProvider).upsert({'owner_uid': user.id});
  }

  /// Save all onboarding data on the final step.
  Future<void> complete({
    required String businessName,
    required String ownerName,
    String? upiId,
    int thresholdAmount = 200,
  }) async {
    final updates = <String, dynamic>{
      'business_name': businessName,
      'owner_name': ownerName,
      'threshold_amount': thresholdAmount,
    };
    if (upiId != null && upiId.trim().isNotEmpty) {
      updates['upi_id'] = upiId.trim();
    }
    await _ref.read(configRepositoryProvider).upsert(updates);
    state = true;
    _ref.invalidate(appConfigProvider);
  }

  Future<void> saveSocieties(List<String> names) async {
    final repo = _ref.read(societyRepositoryProvider);
    for (final name in names) {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty) await repo.add(trimmed);
    }
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref);
});
