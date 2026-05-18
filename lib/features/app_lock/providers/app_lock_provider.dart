import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  AppLockNotifier()
      : super(const AppLockState(isLocked: false, isEnabled: false)) {
    _init();
  }

  final _localAuth = LocalAuthentication();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> _init() async {
    final prefs = await _prefs;
    final enabled = prefs.getBool('app_lock_enabled') ?? false;
    final pin = prefs.getString('app_pin') ?? '';
    state = AppLockState(
      isEnabled: enabled,
      isLocked: enabled && pin.isNotEmpty,
    );
  }

  void lockApp() {
    if (state.isEnabled) state = state.copyWith(isLocked: true);
  }

  void unlockApp() => state = state.copyWith(isLocked: false);

  Future<bool> verifyPin(String entered) async {
    final stored = (await _prefs).getString('app_pin') ?? '';
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
    final prefs = await _prefs;
    await prefs.setString('app_pin', pin);
    await prefs.setBool('app_lock_enabled', true);
    state = const AppLockState(isEnabled: true, isLocked: false);
  }

  Future<void> changePin(String newPin) async {
    await (await _prefs).setString('app_pin', newPin);
  }

  Future<void> disableLock() async {
    final prefs = await _prefs;
    await prefs.setBool('app_lock_enabled', false);
    state = const AppLockState(isEnabled: false, isLocked: false);
  }
}

final appLockProvider =
    StateNotifierProvider<AppLockNotifier, AppLockState>((ref) {
  return AppLockNotifier();
});
