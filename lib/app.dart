import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/providers/locale_provider.dart';
import 'package:hisaab_kitaab/core/router/app_router.dart';
import 'package:hisaab_kitaab/core/theme/app_theme.dart';
import 'package:hisaab_kitaab/features/app_lock/presentation/pin_lock_screen.dart';
import 'package:hisaab_kitaab/features/app_lock/providers/app_lock_provider.dart';
import 'package:hisaab_kitaab/features/onboarding/presentation/onboarding_screen.dart';
import 'package:hisaab_kitaab/features/onboarding/providers/onboarding_provider.dart';

class HisaabKitaabApp extends ConsumerStatefulWidget {
  const HisaabKitaabApp({super.key});

  @override
  ConsumerState<HisaabKitaabApp> createState() => _HisaabKitaabAppState();
}

class _HisaabKitaabAppState extends ConsumerState<HisaabKitaabApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) {
      ref.read(appLockProvider.notifier).lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockProvider);
    final onboardingAsync = ref.watch(onboardingDoneProvider);
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp.router(
      title: 'Hisaab Kitaab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Onboarding takes priority — show on first ever launch.
        return onboardingAsync.when(
          loading: () => const _SplashBackground(),
          error: (err, st) => child ?? const SizedBox.shrink(),
          data: (done) {
            if (!done) return const OnboardingScreen();
            if (lockState.isLocked) return const PinLockScreen();
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
