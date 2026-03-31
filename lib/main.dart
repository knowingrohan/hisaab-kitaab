import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisaab_kitaab/app.dart';
import 'package:hisaab_kitaab/core/utils/backup_scheduler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// DSN is injected at build time via --dart-define=SENTRY_DSN=https://...
// If not provided, Sentry runs in no-op mode (no events sent).
const _sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

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
