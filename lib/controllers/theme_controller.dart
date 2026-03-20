import 'package:flutter/material.dart';

enum AppTheme {
  indigo,
  black,
  light,
  emerald,
  matteRed,
  catppuccinMocha,
  tokyoNight,
  rosePine,
  dracula,
  nord,
  gruvbox,
}

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
      case AppTheme.matteRed:
        return _buildTheme(
          primary: const Color(0xFFE53935),
          scaffold: const Color(0xFF1A1A1A),
          card: const Color(0xFF2D2D2D),
          isDark: true,
        );
      case AppTheme.catppuccinMocha:
        return _buildTheme(
          primary: const Color(0xFFCBA6F7),
          scaffold: const Color(0xFF1E1E2E),
          card: const Color(0xFF313244),
          isDark: true,
        );
      case AppTheme.tokyoNight:
        return _buildTheme(
          primary: const Color(0xFF7AA2F7),
          scaffold: const Color(0xFF1A1B26),
          card: const Color(0xFF24283B),
          isDark: true,
        );
      case AppTheme.rosePine:
        return _buildTheme(
          primary: const Color(0xFFEBBCBA),
          scaffold: const Color(0xFF191724),
          card: const Color(0xFF26233A),
          isDark: true,
        );
      case AppTheme.dracula:
        return _buildTheme(
          primary: const Color(0xFFBD93F9),
          scaffold: const Color(0xFF282A36),
          card: const Color(0xFF383A59),
          isDark: true,
        );
      case AppTheme.nord:
        return _buildTheme(
          primary: const Color(0xFF81A1C1),
          scaffold: const Color(0xFF2E3440),
          card: const Color(0xFF3B4252),
          isDark: true,
        );
      case AppTheme.gruvbox:
        return _buildTheme(
          primary: const Color(0xFFFABD2F),
          scaffold: const Color(0xFF282828),
          card: const Color(0xFF3C3836),
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
      textTheme: base.textTheme
          .apply(
            bodyColor: isDark ? Colors.white : Colors.black87,
            displayColor: isDark ? Colors.white : Colors.black87,
            fontFamily: 'Roboto',
          )
          .copyWith(
            headlineLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              letterSpacing: 6,
              color: isDark ? Colors.white : Colors.black87,
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              letterSpacing: 4,
              color: isDark ? Colors.white : Colors.black87,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.25,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
    );
  }
}
