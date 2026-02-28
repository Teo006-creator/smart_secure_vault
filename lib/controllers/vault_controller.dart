import 'package:flutter/material.dart';
import '../models/vault_entry_model.dart';
import '../services/db_services.dart';
import '../services/security_service.dart';

class VaultController with ChangeNotifier {
  List<VaultEntry> _entries = [];
  List<VaultEntry> _deletedEntries = [];
  String? _filterCategory;
  final DbServices _dbServices = DbServices();
  final SecurityService _securityService = SecurityService();
  
  List<VaultEntry> get entries {
    final active = _entries.where((e) => !e.isDeleted).toList();
    if (_filterCategory == null || _filterCategory == 'Todo') {
      return active;
    }
    return active.where((e) => e.category == _filterCategory).toList();
  }

  List<VaultEntry> get deletedEntries => _deletedEntries;

  double get vaultHealth {
    final active = _entries.where((e) => !e.isDeleted).toList();
    if (active.isEmpty) return 1.0;
    final total = active.fold(0.0, (sum, e) => sum + e.strengthScore);
    return total / active.length;
  }

  String? get filterCategory => _filterCategory;

  void setFilterCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  Future<void> loadEntries(int userId) async {
    final all = await _dbServices.getVaultEntries(userId);
    _entries = all.where((e) => !e.isDeleted).toList();
    _deletedEntries = all.where((e) => e.isDeleted).toList();
    notifyListeners();
  }

  Future<void> addEntry({
    required int userId,
    required String title,
    required String username,
    required String plainPassword,
    required String category,
    required String masterPassword,
    String? description,
  }) async {
    final encrypted = _securityService.encryptData(plainPassword, masterPassword);
    final strength = _securityService.calculateStrength(plainPassword);
    
    final entry = VaultEntry(
      userId: userId,
      title: title,
      username: username,
      encryptedPassword: encrypted,
      category: category,
      description: description,
      strengthScore: strength,
    );

    await _dbServices.insertVaultEntry(entry);
    await loadEntries(userId);
  }

  Future<void> updateEntry({
    required VaultEntry originalEntry,
    required String title,
    required String username,
    required String plainPassword,
    required String category,
    required String masterPassword,
    String? description,
  }) async {
    final encrypted = _securityService.encryptData(plainPassword, masterPassword);
    final strength = _securityService.calculateStrength(plainPassword);

    final updated = VaultEntry(
      id: originalEntry.id,
      userId: originalEntry.userId,
      title: title,
      username: username,
      encryptedPassword: encrypted,
      category: category,
      description: description,
      strengthScore: strength,
      isDeleted: originalEntry.isDeleted,
    );

    await _dbServices.updateVaultEntry(updated);
    await loadEntries(originalEntry.userId);
  }

  String decryptPassword(String encryptedBase64, String masterPassword) {
    return _securityService.decryptData(encryptedBase64, masterPassword);
  }

  Future<void> softDeleteEntry(VaultEntry entry) async {
    final updated = VaultEntry(
      id: entry.id,
      userId: entry.userId,
      title: entry.title,
      username: entry.username,
      encryptedPassword: entry.encryptedPassword,
      category: entry.category,
      description: entry.description,
      strengthScore: entry.strengthScore,
      isDeleted: true,
    );
    await _dbServices.updateVaultEntry(updated);
    await loadEntries(entry.userId);
  }

  Future<void> restoreEntry(VaultEntry entry) async {
    final updated = VaultEntry(
      id: entry.id,
      userId: entry.userId,
      title: entry.title,
      username: entry.username,
      encryptedPassword: entry.encryptedPassword,
      category: entry.category,
      description: entry.description,
      strengthScore: entry.strengthScore,
      isDeleted: false,
    );
    await _dbServices.updateVaultEntry(updated);
    await loadEntries(entry.userId);
  }

  Future<void> deletePermanently(int id, int userId) async {
    await _dbServices.deleteVaultEntry(id);
    await loadEntries(userId);
  }
}
