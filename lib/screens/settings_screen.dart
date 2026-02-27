import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';
import 'deleted_entries_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final userController = Provider.of<UserController>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionTitle('Personalización', isDark),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(8),
              opacity: 0.05,
              child: SegmentedButton<AppTheme>(
                segments: const [
                  ButtonSegment<AppTheme>(
                    value: AppTheme.indigo, 
                    label: Text('Azul', style: TextStyle(fontSize: 10)), 
                    icon: Icon(Icons.circle, color: Color(0xFF6366F1), size: 12),
                  ),
                  ButtonSegment<AppTheme>(
                    value: AppTheme.black, 
                    label: Text('Negro', style: TextStyle(fontSize: 10)), 
                    icon: Icon(Icons.circle, color: Colors.black, size: 12),
                  ),
                  ButtonSegment<AppTheme>(
                    value: AppTheme.light, 
                    label: Text('Claro', style: TextStyle(fontSize: 10)), 
                    icon: Icon(Icons.circle, color: Colors.white, size: 12),
                  ),
                  ButtonSegment<AppTheme>(
                    value: AppTheme.emerald, 
                    label: Text('Verde', style: TextStyle(fontSize: 10)), 
                    icon: Icon(Icons.circle, color: Color(0xFF10B981), size: 12),
                  ),
                ],
                selected: {themeController.currentTheme},
                onSelectionChanged: (Set<AppTheme> newSelection) {
                  themeController.setTheme(newSelection.first);
                },
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  selectedForegroundColor: theme.colorScheme.primary,
                  side: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Cuenta', isDark),
            const SizedBox(height: 16),
            GlassCard(
              opacity: 0.05,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: const Text('Perfil de Usuario'),
                    subtitle: Text(userController.currentUser?.email ?? 'No conectado', 
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      userController.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Seguridad', isDark),
            const SizedBox(height: 16),
            GlassCard(
              opacity: 0.05,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded),
                    title: const Text('Autenticación Biométrica'),
                    value: true,
                    onChanged: (v) {},
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded),
                    title: const Text('Contraseñas Eliminadas'),
                    subtitle: Text('Papelera de reciclaje', 
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DeletedEntriesScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
