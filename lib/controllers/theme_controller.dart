import 'package:flutter/material.dart';

enum AppTheme { indigo, black, light, emerald }

class ThemeController with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.indigo;

  AppTheme get currentTheme => _currentTheme;

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  ThemeData getThemeData() {
    switch (_currentTheme) {
      case AppTheme.black:
        return _buildTheme(
          primary: const Color(0xFF6366F1),
          scaffold: Colors.black,
          card: const Color(0xFF1E293B),
          isDark: true,
        );
      case AppTheme.light:
        return _buildTheme(
          primary: const Color(0xFF4F46E5),
          scaffold: const Color(0xFFF8FAFC),
          card: Colors.white,
          isDark: false,
        );
      case AppTheme.emerald:
        return _buildTheme(
          primary: const Color(0xFF10B981),
          scaffold: const Color(0xFF064E3B),
          card: const Color(0xFF065F46),
          isDark: true,
        );
      case AppTheme.indigo:
      default:
        return _buildTheme(
          primary: const Color(0xFF6366F1),
          scaffold: const Color(0xFF020617),
          card: const Color(0xFF0F172A),
          isDark: true,
        );
    }
  }

  ThemeData _buildTheme({
    required Color primary,
    required Color scaffold,
    required Color card,
    required bool isDark,
  }) {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: card,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: scaffold,
      cardColor: card,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: isDark ? Colors.white : Colors.black87,
        displayColor: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}
