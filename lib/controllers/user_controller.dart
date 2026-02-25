import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';
import '../services/db_services.dart';

class UserController with ChangeNotifier {
  List<User> _users = [];
  User? _currentUser;
  final DbServices _dbServices = DbServices();
  final LocalAuthentication _auth = LocalAuthentication();

  List<User> get users => _users;
  User? get currentUser => _currentUser;

  Future<void> loadUsers() async {
    _users = await _dbServices.getUsers();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final user = await _dbServices.login(email, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> loginWithBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      if (!canAuthenticateWithBiometrics || !isDeviceSupported) {
        return false;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Accede a tu bóveda de forma segura',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        await loadUsers();
        if (_users.isNotEmpty) {
          _currentUser = _users.first;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    await _dbServices.insertUser(user);
    await loadUsers();
  }

  Future<void> updateUser(User user) async {
    await _dbServices.updateUser(user);
    if (_currentUser?.id == user.id) {
      _currentUser = user;
    }
    await loadUsers();
  }

  Future<void> deleteUser(int id) async {
    await _dbServices.deleteUser(id);
    if (_currentUser?.id == id) {
      _currentUser = null;
    }
    await loadUsers();
  }
}
