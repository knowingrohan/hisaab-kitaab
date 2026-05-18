import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/core/auth/auth_provider.dart';
import 'package:hisaab_kitaab/core/providers/locale_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hisaab_kitaab/core/router/app_router.dart';
import 'package:hisaab_kitaab/core/theme/app_theme.dart';
import 'package:hisaab_kitaab/features/app_lock/presentation/pin_lock_screen.dart';
import 'package:hisaab_kitaab/features/app_lock/providers/app_lock_provider.dart';

class HisaabKitaabApp extends ConsumerStatefulWidget {
  const HisaabKitaabApp({super.key});

  @override
  ConsumerState<HisaabKitaabApp> createState() => _HisaabKitaabAppState();
}

class _HisaabKitaabAppState extends ConsumerState<HisaabKitaabApp>
    with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Build router after the ProviderScope is available in context.
    _router = buildAppRouter(ProviderScope.containerOf(context));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(appLockProvider.notifier).lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockProvider);
    final locale = ref.watch(localeNotifierProvider);

    // Auth loading splash — before router initializes
    final authState = ref.watch(authProvider);
    if (authState is HKAuthLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      title: 'Hisaab Kitaab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
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
        if (lockState.isLocked) return const PinLockScreen();
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
