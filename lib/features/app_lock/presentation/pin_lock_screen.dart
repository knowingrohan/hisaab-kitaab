import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/app_lock_provider.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  String _entered = '';
  String? _errorMsg;
  bool _hasBiometric = false;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAndPrompt();
  }

  Future<void> _checkBiometricAndPrompt() async {
    final can =
        await ref.read(appLockProvider.notifier).canUseBiometric();
    if (!mounted) return;
    setState(() => _hasBiometric = can);
    if (can) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final success =
        await ref.read(appLockProvider.notifier).authenticateWithBiometric();
    if (success && mounted) {
      ref.read(appLockProvider.notifier).unlockApp();
    }
  }

  void _onDigit(String d) {
    if (_entered.length >= 4 || _verifying) return;
    setState(() {
      _entered += d;
      _errorMsg = null;
    });
    if (_entered.length == 4) _verify();
  }

  void _onBackspace() {
    if (_entered.isEmpty || _verifying) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _verify() async {
    setState(() => _verifying = true);
    final ok =
        await ref.read(appLockProvider.notifier).verifyPin(_entered);
    if (!mounted) return;
    if (ok) {
      ref.read(appLockProvider.notifier).unlockApp();
    } else {
      setState(() {
        _entered = '';
        _errorMsg = 'Wrong PIN. Try again.';
        _verifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // App icon + title
              const Icon(Icons.iron_outlined,
                  size: 56, color: Colors.white70),
              const SizedBox(height: 12),
              Text(
                'Hisaab Kitaab',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter PIN to unlock',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white60,
                    ),
              ),
              const SizedBox(height: 40),
              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _entered.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? Colors.white
                          : Colors.white.withAlpha(60),
                      border: Border.all(
                          color: Colors.white54, width: 1.5),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Error message
              SizedBox(
                height: 20,
                child: _errorMsg != null
                    ? Text(
                        _errorMsg!,
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      )
                    : null,
              ),
              const Spacer(flex: 1),
              // Numpad
              _Numpad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                onBiometric: _hasBiometric ? _tryBiometric : null,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
  });

  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    const digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        for (final row in digits)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row
                  .map((d) => _NumButton(
                        label: d,
                        onTap: () => onDigit(d),
                      ))
                  .toList(),
            ),
          ),
        // Bottom row: biometric / 0 / backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NumButton(
              icon: onBiometric != null
                  ? Icons.fingerprint
                  : null,
              onTap: onBiometric,
            ),
            _NumButton(label: '0', onTap: () => onDigit('0')),
            _NumButton(
              icon: Icons.backspace_outlined,
              onTap: onBackspace,
              iconSize: 22,
            ),
          ],
        ),
      ],
    );
  }
}

class _NumButton extends StatelessWidget {
  const _NumButton({
    this.label,
    this.icon,
    this.iconSize = 28,
    this.onTap,
  });

  final String? label;
  final IconData? icon;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 76,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null
              ? Colors.white.withAlpha(30)
              : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: label != null
            ? Text(
                label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              )
            : icon != null
                ? Icon(icon, color: Colors.white70, size: iconSize)
                : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIN Setup Sheet — shown when enabling app lock or changing PIN.
// Returns the confirmed PIN, or null if cancelled.
// ─────────────────────────────────────────────────────────────────────────────

Future<String?> showPinSetupSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PinSetupSheet(),
  );
}

class _PinSetupSheet extends StatefulWidget {
  const _PinSetupSheet();

  @override
  State<_PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends State<_PinSetupSheet> {
  // step 0 = enter new PIN, step 1 = confirm PIN
  int _step = 0;
  String _firstPin = '';
  String _entered = '';
  String? _error;

  String get _title =>
      _step == 0 ? 'Set a 4-digit PIN' : 'Confirm your PIN';

  void _onDigit(String d) {
    if (_entered.length >= 4) return;
    setState(() {
      _entered += d;
      _error = null;
    });
    if (_entered.length == 4) _onComplete();
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() =>
        _entered = _entered.substring(0, _entered.length - 1));
  }

  void _onComplete() {
    if (_step == 0) {
      setState(() {
        _firstPin = _entered;
        _entered = '';
        _step = 1;
      });
    } else {
      if (_entered == _firstPin) {
        Navigator.of(context).pop(_entered);
      } else {
        setState(() {
          _entered = '';
          _error = 'PINs do not match. Start over.';
          _step = 0;
          _firstPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _entered.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? Colors.white
                      : Colors.white.withAlpha(60),
                  border:
                      Border.all(color: Colors.white54, width: 1.5),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 20,
            child: _error != null
                ? Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 20),
          _Numpad(onDigit: _onDigit, onBackspace: _onBackspace),
        ],
      ),
    );
  }
}
