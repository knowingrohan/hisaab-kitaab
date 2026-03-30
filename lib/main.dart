import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisaab_kitaab/app.dart';
import 'package:hisaab_kitaab/core/database/app_database.dart';

late final AppDatabase database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();

  runApp(
    const ProviderScope(
      child: HisaabKitaabApp(),
    ),
  );
}
