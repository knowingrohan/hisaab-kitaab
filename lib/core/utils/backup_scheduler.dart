import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import '../database/app_database.dart';
import 'drive_backup_helper.dart';

const _taskName = 'com.hisaab_kitaab.daily_backup';
const _taskUniqueName = 'daily_backup';

/// Called by WorkManager in the background — must be a top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != _taskName) return Future.value(true);

    try {
      final db = AppDatabase();
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'hisaab_kitaab.db'));

      final user = DriveBackupHelper.instance.currentUser();
      if (user == null) {
        await db.close();
        return Future.value(true); // not signed in — skip silently
      }

      await DriveBackupHelper.instance.backupDatabase(db, file);
      await db.close();
    } catch (e) {
      // Returning true prevents WorkManager from retrying immediately.
      return Future.value(true);
    }
    return Future.value(true);
  });
}

class BackupScheduler {
  BackupScheduler._();
  static final instance = BackupScheduler._();

  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  Future<void> scheduleDaily() async {
    await Workmanager().registerPeriodicTask(
      _taskUniqueName,
      _taskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_taskUniqueName);
  }
}
