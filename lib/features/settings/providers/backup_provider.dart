import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/utils/drive_backup_helper.dart';

class BackupState {
  const BackupState({
    this.account,
    this.lastBackupTime,
    this.isLoading = false,
    this.errorMessage,
    this.restoreComplete = false,
  });

  final GoogleSignInAccount? account;
  final DateTime? lastBackupTime;
  final bool isLoading;
  final String? errorMessage;
  final bool restoreComplete;

  BackupState copyWith({
    GoogleSignInAccount? account,
    bool clearAccount = false,
    DateTime? lastBackupTime,
    bool clearLastBackupTime = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? restoreComplete,
  }) {
    return BackupState(
      account: clearAccount ? null : (account ?? this.account),
      lastBackupTime: clearLastBackupTime
          ? null
          : (lastBackupTime ?? this.lastBackupTime),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      restoreComplete: restoreComplete ?? this.restoreComplete,
    );
  }
}

class BackupNotifier extends StateNotifier<BackupState> {
  BackupNotifier(this._ref) : super(const BackupState());

  final Ref _ref;

  Future<File> _dbFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'hisaab_kitaab.db'));
  }

  /// Called from initState — silent sign-in check + fetch last backup time.
  Future<void> initialize() async {
    final account = DriveBackupHelper.instance.currentUser();
    if (account == null) return;

    state = state.copyWith(account: account);
    final lastBackupTime =
        await DriveBackupHelper.instance.getLastBackupTime();
    state = state.copyWith(lastBackupTime: lastBackupTime);
  }

  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final account = await DriveBackupHelper.instance.signIn();
      if (account == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final lastBackupTime =
          await DriveBackupHelper.instance.getLastBackupTime();
      state = state.copyWith(
        account: account,
        lastBackupTime: lastBackupTime,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sign-in failed: $e',
      );
    }
  }

  Future<void> signOut() async {
    await DriveBackupHelper.instance.signOut();
    state = state.copyWith(
      clearAccount: true,
      clearLastBackupTime: true,
    );
  }

  Future<void> backup() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final db = _ref.read(databaseProvider);
      final file = await _dbFile();
      await DriveBackupHelper.instance.backupDatabase(db, file);
      final lastBackupTime =
          await DriveBackupHelper.instance.getLastBackupTime();
      state = state.copyWith(
        lastBackupTime: lastBackupTime,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Backup failed: $e',
      );
    }
  }

  Future<void> restore() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final db = _ref.read(databaseProvider);
      final file = await _dbFile();
      final success =
          await DriveBackupHelper.instance.restoreDatabase(db, file);
      if (success) {
        state = state.copyWith(isLoading: false, restoreComplete: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No backup found on Drive.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Restore failed: $e',
      );
    }
  }
}

final backupProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  return BackupNotifier(ref);
});
