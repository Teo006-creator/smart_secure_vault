import 'package:flutter/material.dart';
import '../models/vault_entry_model.dart';
import '../services/db_services.dart';
import '../services/security_service.dart';

class VaultController with ChangeNotifier {
  List<VaultEntry> _entries = [];
  final DbServices _dbServices = DbServices();
  final SecurityService _securityService = SecurityService();
  
  List<VaultEntry> get entries => _entries;

  Future<void> loadEntries(int userId) async {
    _entries = await _dbServices.getVaultEntries(userId);
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

  String decryptPassword(String encryptedBase64, String masterPassword) {
    return _securityService.decryptData(encryptedBase64, masterPassword);
  }

  Future<void> deleteEntry(int id, int userId) async {
    await _dbServices.deleteVaultEntry(id);
    await loadEntries(userId);
  }
}
