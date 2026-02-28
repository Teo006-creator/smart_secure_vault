import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'HISTORIAL DE ALERTAS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white38),
            ),
            const SizedBox(height: 16),
            _buildNotificationItem(
              context,
              '¡ACCION REQUERIDA!',
              'Tu contraseña maestra debe ser renovada cada 3 meses. Hazlo ahora para mantener la máxima seguridad.',
              Icons.lock_reset_rounded,
              Colors.amberAccent,
            ),
            const SizedBox(height: 16),
            _buildNotificationItem(
              context,
              'Seguridad Crítica',
              'Se detectó un intento de acceso no autorizado desde una nueva ubicación (IP: 192.168.1.10).',
              Icons.gpp_maybe_rounded,
              Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      opacity: 0.05,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
