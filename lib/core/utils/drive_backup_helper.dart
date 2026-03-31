import 'dart:async';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../database/app_database.dart';

class DriveBackupHelper {
  DriveBackupHelper._();
  static final DriveBackupHelper instance = DriveBackupHelper._();

  static const _backupFileName = 'hisaab_kitaab.db';
  static const _driveScope = 'https://www.googleapis.com/auth/drive.appdata';

  final _googleSignIn = GoogleSignIn(scopes: [_driveScope]);

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<GoogleSignInAccount?> signIn() async {
    final silent = await _googleSignIn.signInSilently();
    if (silent != null) return silent;
    return _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  GoogleSignInAccount? currentUser() => _googleSignIn.currentUser;

  // ── Drive API ─────────────────────────────────────────────────────────────

  Future<drive.DriveApi> _getDriveApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('Not signed in to Google');
    return drive.DriveApi(client);
  }

  Future<drive.File?> _findBackupFile(drive.DriveApi api) async {
    final result = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName'",
      $fields: 'files(id, name, modifiedTime)',
      pageSize: 1,
    );
    return result.files?.firstOrNull;
  }

  // ── Backup ────────────────────────────────────────────────────────────────

  Future<void> backupDatabase(AppDatabase db, File dbFile) async {
    // Flush WAL into main DB file so the .db is self-contained.
    await db.checkpoint();

    final api = await _getDriveApi();
    final bytes = await dbFile.readAsBytes();
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: 'application/octet-stream',
    );

    final existing = await _findBackupFile(api);
    if (existing?.id != null) {
      await api.files.update(
        drive.File(),
        existing!.id!,
        uploadMedia: media,
      );
    } else {
      final metadata = drive.File()
        ..name = _backupFileName
        ..parents = ['appDataFolder'];
      await api.files.create(metadata, uploadMedia: media);
    }
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  /// Downloads the Drive backup and replaces the local DB file.
  /// IMPORTANT: closes the Drift connection — caller must prompt app restart.
  /// Returns true on success, false if no backup found or on error.
  Future<bool> restoreDatabase(AppDatabase db, File targetFile) async {
    final api = await _getDriveApi();
    final backupFile = await _findBackupFile(api);
    if (backupFile?.id == null) return false;

    final tempFile = File('${targetFile.path}_restore_tmp');

    // Download to temp file.
    final response = await api.files.get(
      backupFile!.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final sink = tempFile.openWrite();
    await response.stream.pipe(sink);
    await sink.close();

    // Close Drift before touching the file.
    await db.close();

    // Swap files.
    if (await targetFile.exists()) await targetFile.delete();
    final wal = File('${targetFile.path}-wal');
    final shm = File('${targetFile.path}-shm');
    if (await wal.exists()) await wal.delete();
    if (await shm.exists()) await shm.delete();

    await tempFile.rename(targetFile.path);
    return true;
  }

  // ── Metadata ──────────────────────────────────────────────────────────────

  Future<DateTime?> getLastBackupTime() async {
    try {
      final api = await _getDriveApi();
      final file = await _findBackupFile(api);
      return file?.modifiedTime;
    } catch (_) {
      return null;
    }
  }
}
