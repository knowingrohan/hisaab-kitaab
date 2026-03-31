import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';

final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final val = await ref.watch(databaseProvider).getSetting('onboarding_done');
  return val == 'true';
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._ref) : super(false);

  final Ref _ref;

  Future<void> complete() async {
    await _ref.read(databaseProvider).setSetting('onboarding_done', 'true');
    state = true;
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref);
});
