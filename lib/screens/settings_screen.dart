import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';
import 'deleted_entries_screen.dart';
import 'user_detail_screen.dart';
import '../services/cloud_sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSyncing = false;
  final _cloudSync = CloudSyncService();

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
                    onTap: () {
                      if (userController.currentUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailScreen(user: userController.currentUser!),
                          ),
                        );
                      }
                    },
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
            const SizedBox(height: 32),
            _buildSectionTitle('Sincronización', isDark),
            const SizedBox(height: 16),
            GlassCard(
              opacity: 0.05,
              child: Column(
                children: [
                   ListTile(
                    leading: Icon(
                      _isSyncing ? Icons.sync : Icons.cloud_done_rounded, 
                      color: _isSyncing ? Colors.blueAccent : const Color(0xFF10B981)
                    ),
                    title: const Text('Respaldar en Google Drive'),
                    subtitle: Text(_isSyncing ? 'Sincronizando...' : 'Última copia: Hoy', 
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
                    trailing: _isSyncing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                    onTap: _isSyncing ? null : () => _handleBackup(context),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_download_rounded, color: Colors.orangeAccent),
                    title: const Text('Restaurar desde la Nube'),
                    onTap: _isSyncing ? null : () => _handleRestore(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Zona de Peligro', isDark),
            const SizedBox(height: 16),
            GlassCard(
              opacity: 0.05,
              child: ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                title: const Text('Eliminar Cuenta', style: TextStyle(color: Colors.redAccent)),
                subtitle: Text('Borrar todos los datos permanentemente', 
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
                onTap: () => _showDeleteAccountDialog(context, userController),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _handleBackup(BuildContext context) async {
    setState(() {
      _isSyncing = true;
    });
    try {
      String? error = await _cloudSync.backupData();
      if (context.mounted) {
        bool success = error == null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Respaldo completado con éxito' : 'Error: $error'),
            backgroundColor: success ? const Color(0xFF10B981) : Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _handleRestore(BuildContext context) async {
    setState(() {
      _isSyncing = true;
    });
    try {
      String? error = await _cloudSync.restoreData();
      if (context.mounted) {
        bool success = error == null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Restauración completada con éxito. Reinicia la app.' : 'Error: $error'),
            backgroundColor: success ? const Color(0xFF10B981) : Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context, UserController userController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('¿Eliminar Cuenta?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Esta acción borrará todas tus contraseñas y tu perfil de forma permanente. No podrás recuperar los datos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalConfirmation(context, userController);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.2)),
            child: const Text('SÍ, ESTOY SEGURO', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showFinalConfirmation(BuildContext context, UserController userController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Confirmación Final', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          '¿Realmente deseas destruir tu bóveda maestra ahora?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = userController.currentUser?.id;
              if (userId != null) {
                await userController.deleteUser(userId);
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('ELIMINAR MI CUENTA'),
          ),
        ],
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
