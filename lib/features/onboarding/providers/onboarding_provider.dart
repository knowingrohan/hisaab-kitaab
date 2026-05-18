import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hisaab_kitaab/core/repositories/config_repository.dart';

/// True once the owner has completed the first-run wizard (business_name is set).
final onboardingDoneProvider = FutureProvider<bool>((ref) {
  return ref.watch(configRepositoryProvider).isOnboardingDone();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._ref) : super(false);

  final Ref _ref;

  Future<void> complete({
    String businessName = '',
    String ownerName = '',
    String? phone,
    String? upiId,
  }) async {
    final updates = <String, dynamic>{};
    if (businessName.isNotEmpty) updates['business_name'] = businessName;
    if (ownerName.isNotEmpty) updates['owner_name'] = ownerName;
    if (phone != null) updates['phone'] = phone;
    if (upiId != null) updates['upi_id'] = upiId;
    await _ref.read(configRepositoryProvider).upsert(updates);
    state = true;
    _ref.invalidate(onboardingDoneProvider);
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref);
});
