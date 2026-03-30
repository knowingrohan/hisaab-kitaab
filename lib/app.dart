import 'package:flutter/material.dart';
import 'package:hisaab_kitaab/core/router/app_router.dart';
import 'package:hisaab_kitaab/core/theme/app_theme.dart';

class HisaabKitaabApp extends StatelessWidget {
  const HisaabKitaabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hisaab Kitaab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
