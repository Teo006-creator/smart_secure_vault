import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
    ],
  );

  GoogleSignInAccount? _currentUser;

  Future<String?> login() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null ? null : "El usuario canceló el inicio de sesión";
    } catch (e) {
      print('Error en Google Sign-In: $e');
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  Future<String?> backupData() async {
    if (_currentUser == null) {
      String? loginError = await login();
      if (loginError != null) return loginError;
    }

    try {
      final httpClient = (await _googleSignIn.authenticatedClient())!;
      final driveApi = drive.DriveApi(httpClient);

      String dbPath = p.join(await getDatabasesPath(), 'vault_database.db');
      File dbFile = File(dbPath);
      if (!dbFile.existsSync()) return "Archivo de base de datos no encontrado";

      final fileList = await driveApi.files.list(
        q: "name = 'vault_database.db' and 'appDataFolder' in parents",
        spaces: 'appDataFolder',
      );

      final media = drive.Media(dbFile.openRead(), dbFile.lengthSync());
      final driveFile = drive.File();
      driveFile.name = 'vault_database.db';
      driveFile.parents = ['appDataFolder'];

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        await driveApi.files.update(driveFile, fileList.files!.first.id!, uploadMedia: media);
      } else {
        await driveApi.files.create(driveFile, uploadMedia: media);
      }
      return null;
    } catch (e) {
      print('Backup error: $e');
      return e.toString();
    }
  }

  Future<String?> restoreData() async {
    if (_currentUser == null) {
      String? loginError = await login();
      if (loginError != null) return loginError;
    }

    try {
      final httpClient = (await _googleSignIn.authenticatedClient())!;
      final driveApi = drive.DriveApi(httpClient);

      final fileList = await driveApi.files.list(
        q: "name = 'vault_database.db' and 'appDataFolder' in parents",
        spaces: 'appDataFolder',
      );

      if (fileList.files == null || fileList.files!.isEmpty) return "No se encontró respaldo en Drive";

      final fileId = fileList.files!.first.id!;
      final drive.Media downloadedMedia = await driveApi.files.get(
        fileId, 
        downloadOptions: drive.DownloadOptions.fullMedia
      ) as drive.Media;
      
      String dbPath = p.join(await getDatabasesPath(), 'vault_database.db');
      File dbFile = File(dbPath);
      
      final List<int> dataBuffer = [];
      await for (var data in downloadedMedia.stream) {
        dataBuffer.addAll(data);
      }
      
      await dbFile.writeAsBytes(dataBuffer);
      return null;
    } catch (e) {
      print('Restore error: $e');
      return e.toString();
    }
  }
}
