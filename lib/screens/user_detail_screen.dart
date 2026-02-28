import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import '../widgets/glass_card.dart';
import 'user_form_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserFormScreen(user: user),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(user),
                const SizedBox(height: 40),
                _buildInfoSection(context, user, isDark),
                const SizedBox(height: 32),
                _buildSecuritySummary(user, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          user.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          'Protegido con Grado Militar',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, User user, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      opacity: 0.05,
      child: Column(
        children: [
          _buildInfoTile(Icons.email_outlined, 'Email', user.email, isDark),
          const Divider(color: Colors.white10, height: 1),
          _buildInfoTile(Icons.badge_outlined, 'ID Único', '#00${user.id}', isDark),
          const Divider(color: Colors.white10, height: 1),
          _buildInfoTile(Icons.calendar_today_outlined, 'Miembro desde', user.createdAt ?? 'Fecha no disponible', isDark),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B5CF6)),
      title: Text(label, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSecuritySummary(User user, bool isDark) {
    return Row(
      children: [
        _buildStatCard('Bio-Auth', 'ACTIVO', Icons.fingerprint_rounded, Colors.blueAccent),
        const SizedBox(width: 16),
        _buildStatCard('Encriptación', 'AES-256', Icons.enhanced_encryption_rounded, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        opacity: 0.05,
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Eliminar Bóveda Maestra', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esta acción es irreversible. Se perderán todos tus datos encriptados.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<UserController>(context, listen: false).deleteUser(user.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('ELIMINAR TODO'),
          ),
        ],
      ),
    );
  }
}
