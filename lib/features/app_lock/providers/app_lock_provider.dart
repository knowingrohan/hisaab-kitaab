import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/providers/database_provider.dart';

class AppLockState {
  const AppLockState({
    required this.isLocked,
    required this.isEnabled,
  });

  final bool isLocked;
  final bool isEnabled;

  AppLockState copyWith({bool? isLocked, bool? isEnabled}) => AppLockState(
        isLocked: isLocked ?? this.isLocked,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}

class AppLockNotifier extends StateNotifier<AppLockState> {
  AppLockNotifier(this._ref)
      : super(const AppLockState(isLocked: false, isEnabled: false)) {
    _init();
  }

  final Ref _ref;
  final _localAuth = LocalAuthentication();

  Future<void> _init() async {
    final db = _ref.read(databaseProvider);
    final enabled = await db.getSetting('app_lock_enabled') == 'true';
    final pin = await db.getSetting('app_pin') ?? '';
    state = AppLockState(
      isEnabled: enabled,
      isLocked: enabled && pin.isNotEmpty,
    );
  }

  /// Call when app resumes from background.
  void lockApp() {
    if (state.isEnabled) state = state.copyWith(isLocked: true);
  }

  void unlockApp() => state = state.copyWith(isLocked: false);

  Future<bool> verifyPin(String entered) async {
    final stored = await _ref.read(databaseProvider).getSetting('app_pin') ?? '';
    return entered == stored;
  }

  Future<bool> canUseBiometric() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      final can = await _localAuth.canCheckBiometrics;
      if (!can) return false;
      return await _localAuth.authenticate(
        localizedReason: 'Unlock Hisaab Kitaab',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> enableLock(String pin) async {
    final db = _ref.read(databaseProvider);
    await db.setSetting('app_pin', pin);
    await db.setSetting('app_lock_enabled', 'true');
    state = AppLockState(isEnabled: true, isLocked: false);
  }

  Future<void> changePin(String newPin) async {
    await _ref.read(databaseProvider).setSetting('app_pin', newPin);
  }

  Future<void> disableLock() async {
    final db = _ref.read(databaseProvider);
    await db.setSetting('app_lock_enabled', 'false');
    state = AppLockState(isEnabled: false, isLocked: false);
  }
}

final appLockProvider =
    StateNotifierProvider<AppLockNotifier, AppLockState>((ref) {
  return AppLockNotifier(ref);
});
