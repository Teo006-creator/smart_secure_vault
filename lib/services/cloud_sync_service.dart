import 'dart:io';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart'
    as gsis;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  // Client ID de tipo 'Desktop' para Linux
  static const String _clientId = "YOUR_CLIENT_ID";
  // Client Secret para Linux
  static const String _clientSecret = "YOUR_CLIENT_SECRET";

  late final gsis.GoogleSignIn _googleSignIn = gsis.GoogleSignIn(
    params: gsis.GoogleSignInParams(
      clientId: (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
          ? _clientId
          : null,
      clientSecret: (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
          ? _clientSecret
          : null,
      scopes: ['https://www.googleapis.com/auth/drive.appdata', 'email'],
    ),
  );

  gsis.GoogleSignInCredentials? _credentials;
  http.Client? _authenticatedClient;

  Future<String?> login() async {
    try {
      print('Iniciando sesión en Google (Cross-platform)...');
      final result = await _googleSignIn.signIn();

      if (result == null) {
        print('Inicio de sesión cancelado o falló.');
        return "El usuario canceló el inicio de sesión o falta configuración";
      }

      _credentials = result;
      print('Sesión iniciada correctamente.');

      // Obtener el cliente autenticado directamente del plugin
      _authenticatedClient = await _googleSignIn.authenticatedClient;

      if (_authenticatedClient == null) {
        return "No se pudo obtener el cliente HTTP autenticado.";
      }

      return null;
    } catch (e) {
      print('Error CRÍTICO en Google Sign-In: $e');
      return "Error de autenticación: $e";
    }
  }

  Future<void> logout() async {
    print('Cerrando sesión de Google...');
    await _googleSignIn.signOut();
    _credentials = null;
    _authenticatedClient?.close();
    _authenticatedClient = null;
  }

  Future<String?> backupData() async {
    if (_credentials == null) {
      print('Iniciando respaldo, solicitando login...');
      String? loginError = await login();
      if (loginError != null) return loginError;
    }

    try {
      print('Obteniendo cliente HTTP autenticado...');
      final httpClient = _authenticatedClient;
      if (httpClient == null) return "Error: Cliente HTTP no autenticado.";
      final driveApi = drive.DriveApi(httpClient);

      print('Localizando base de datos local...');
      String dbPath = p.join(await getDatabasesPath(), 'vault_database.db');
      File dbFile = File(dbPath);
      if (!dbFile.existsSync()) {
        print('ERROR: Base de datos no encontrada en $dbPath');
        return "Archivo de base de datos no encontrado";
      }

      print('Buscando archivos existentes en Drive...');
      final fileList = await driveApi.files.list(
        q: "name = 'vault_database.db' and 'appDataFolder' in parents",
        spaces: 'appDataFolder',
      );

      final media = drive.Media(dbFile.openRead(), dbFile.lengthSync());

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final driveFileToUpdate = drive.File();
        print(
          'Actualizando archivo existente en Drive (ID: ${fileList.files!.first.id})...',
        );
        await driveApi.files.update(
          driveFileToUpdate,
          fileList.files!.first.id!,
          uploadMedia: media,
        );
      } else {
        final driveFileToCreate = drive.File();
        driveFileToCreate.name = 'vault_database.db';
        driveFileToCreate.parents = ['appDataFolder'];
        print('Creando nuevo archivo de respaldo en Drive...');
        await driveApi.files.create(driveFileToCreate, uploadMedia: media);
      }
      print('Respaldo completado con éxito.');
      return null;
    } catch (e) {
      print('Error durante el Backup: $e');
      return "Fallo en el respaldo: $e";
    }
  }

  Future<String?> restoreData() async {
    if (_credentials == null) {
      print('Iniciando restauración, solicitando login...');
      String? loginError = await login();
      if (loginError != null) return loginError;
    }

    try {
      print('Obteniendo cliente HTTP autenticado...');
      final httpClient = _authenticatedClient;
      if (httpClient == null) return "Error: Cliente HTTP no autenticado.";
      final driveApi = drive.DriveApi(httpClient);

      print('Buscando respaldo en Drive (espacio appDataFolder)...');
      final fileList = await driveApi.files.list(
        q: "name = 'vault_database.db' and 'appDataFolder' in parents",
        spaces: 'appDataFolder',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        print('No se encontró ningún respaldo en Google Drive.');
        return "No se encontró respaldo en Drive";
      }

      final fileId = fileList.files!.first.id!;
      print('Descargando archivo (ID: $fileId)...');
      final drive.Media downloadedMedia =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      String dbPath = p.join(await getDatabasesPath(), 'vault_database.db');
      File dbFile = File(dbPath);

      final List<int> dataBuffer = [];
      await for (var data in downloadedMedia.stream) {
        dataBuffer.addAll(data);
      }

      print(
        'Escribiendo archivo de base de datos local (${dataBuffer.length} bytes)...',
      );
      await dbFile.writeAsBytes(dataBuffer);
      print('Restauración completada con éxito.');
      return null;
    } catch (e) {
      print('Error durante la Restauración: $e');
      return "Fallo en la restauración: $e";
    }
  }
}
