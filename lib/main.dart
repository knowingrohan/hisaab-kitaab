import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisaab_kitaab/app.dart';
import 'package:hisaab_kitaab/core/utils/backup_scheduler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqlite3/open.dart';

// DSN is injected at build time via --dart-define=SENTRY_DSN=https://...
// If not provided, Sentry runs in no-op mode (no events sent).
const _sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tell sqlite3 to load libsqlcipher.so on Android instead of the default
  // libsqlite3.so. sqlcipher_flutter_libs bundles libsqlcipher.so — without
  // this override the app crashes with "library libsqlite3.so not found".
  if (Platform.isAndroid) {
    open.overrideFor(
      OperatingSystem.android,
      () => DynamicLibrary.open('libsqlcipher.so'),
    );
  }

  // Fonts are fetched from the network on first launch and cached locally.
  // Set to false only when font TTF files are bundled under assets/google_fonts/.
  GoogleFonts.config.allowRuntimeFetching = true;

  await BackupScheduler.instance.initialize();

  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: HisaabKitaabApp(),
      ),
    ),
  );
}
