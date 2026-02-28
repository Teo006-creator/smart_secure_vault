import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/vault_entry_model.dart';

class DbServices {
  static final DbServices _instance = DbServices._internal();
  factory DbServices() => _instance;
  DbServices._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    String path = join(await getDatabasesPath(), 'vault_database.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, password TEXT, createdAt TEXT)',
        );
        await db.execute(
          'CREATE TABLE vault_entries(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, title TEXT, username TEXT, encryptedPassword TEXT, category TEXT, description TEXT, strengthScore REAL, isDeleted INTEGER DEFAULT 0)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN password TEXT');
        }
        if (oldVersion < 3) {
          await db.execute(
            'CREATE TABLE vault_entries(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, title TEXT, username TEXT, encryptedPassword TEXT, category TEXT, description TEXT, strengthScore REAL, isDeleted INTEGER DEFAULT 0)',
          );
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE vault_entries ADD COLUMN isDeleted INTEGER DEFAULT 0');
        }
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE users ADD COLUMN createdAt TEXT');
        }
      },
    );
  }

  // --- User Operations ---
  Future<int> insertUser(User user) async {
    final db = await database;
    
    // Auto-generate creation date if not present
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    final now = DateTime.now();
    final creationDate = user.createdAt ?? '${months[now.month - 1]} ${now.year}';
    
    final userData = user.toMap();
    userData['createdAt'] = creationDate;
    
    return await db.insert('users', userData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<User?> login(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    // Secure wipe: first delete all associated vault entries
    await db.delete('vault_entries', where: 'userId = ?', whereArgs: [id]);
    // Then delete the user
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // --- Vault Operations ---
  Future<int> insertVaultEntry(VaultEntry entry) async {
    final db = await database;
    return await db.insert('vault_entries', entry.toMap());
  }

  Future<List<VaultEntry>> getVaultEntries(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vault_entries',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => VaultEntry.fromMap(maps[i]));
  }

  Future<int> updateVaultEntry(VaultEntry entry) async {
    final db = await database;
    return await db.update(
      'vault_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteVaultEntry(int id) async {
    final db = await database;
    return await db.delete('vault_entries', where: 'id = ?', whereArgs: [id]);
  }
}
