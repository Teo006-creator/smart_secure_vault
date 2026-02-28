import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/vault_entry_model.dart';
import '../controllers/vault_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/glass_card.dart';
import 'vault_form_screen.dart';

class VaultDetailScreen extends StatefulWidget {
  final VaultEntry entry;

  const VaultDetailScreen({super.key, required this.entry});

  @override
  State<VaultDetailScreen> createState() => _VaultDetailScreenState();
}

class _VaultDetailScreenState extends State<VaultDetailScreen> {
  bool _showPassword = false;
  String? _decryptedPassword;

  void _togglePassword(VaultEntry entry) {
    if (_decryptedPassword == null) {
      final user = Provider.of<UserController>(context, listen: false).currentUser;
      if (user != null) {
        final vault = Provider.of<VaultController>(context, listen: false);
        setState(() {
          _decryptedPassword = vault.decryptPassword(entry.encryptedPassword, user.password);
          _showPassword = true;
        });
      }
    } else {
      setState(() {
        _showPassword = !_showPassword;
      });
    }
  }

  void _copyPassword(VaultEntry entry) {
    final user = Provider.of<UserController>(context, listen: false).currentUser;
    if (user != null) {
      final vault = Provider.of<VaultController>(context, listen: false);
      final decrypted = vault.decryptPassword(entry.encryptedPassword, user.password);
      Clipboard.setData(ClipboardData(text: decrypted));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña copiada al portapapeles')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Seguridad', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VaultFormScreen(entry: widget.entry),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Eliminar cuenta?'),
                  content: const Text('Esta cuenta se enviará a la papelera.'),
                  actions: [
                    TextButton(child: const Text('CANCELAR'), onPressed: () => Navigator.pop(context, false)),
                    TextButton(
                      child: const Text('ELIMINAR', style: TextStyle(color: Colors.redAccent)),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                await Provider.of<VaultController>(context, listen: false).softDeleteEntry(widget.entry);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Consumer<VaultController>(
        builder: (context, vaultController, child) {
          // Find the updated entry in the controller
          final currentEntry = vaultController.entries.firstWhere(
            (e) => e.id == widget.entry.id,
            orElse: () => widget.entry,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(currentEntry.category),
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    currentEntry.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                _buildInfoCard(currentEntry, isDark, theme),
                const SizedBox(height: 24),
                _buildPasswordCard(currentEntry, isDark, theme),
                if (currentEntry.description != null && currentEntry.description!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildDescriptionCard(currentEntry.description!, isDark),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(VaultEntry entry, bool isDark, ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      opacity: 0.05,
      child: Column(
        children: [
          _buildDetailRow(
            Icons.person_outline_rounded,
            'Usuario',
            entry.username,
            isDark,
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildDetailRow(
            Icons.category_outlined,
            'Categoría',
            entry.category,
            isDark,
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildDetailRow(
            Icons.security_rounded,
            'Seguridad',
            _getStrengthText(entry.strengthScore),
            isDark,
            valueColor: _getStrengthColor(entry.strengthScore),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard(VaultEntry entry, bool isDark, ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      opacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contraseña Encriptada',
            style: TextStyle(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _showPassword && _decryptedPassword != null
                      ? _decryptedPassword!
                      : '••••••••••••••••',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                onPressed: () => _togglePassword(entry),
                color: theme.colorScheme.primary,
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => _copyPassword(entry),
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      opacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notas / Descripción',
            style: TextStyle(fontSize: 12, color: Colors.white38, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white38),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Finanzas': return Icons.account_balance_wallet_rounded;
      case 'Social': return Icons.public_rounded;
      case 'Trabajo': return Icons.business_center_rounded;
      case 'WiFi': return Icons.wifi_protected_setup_rounded;
      default: return Icons.apps_rounded;
    }
  }

  Color _getStrengthColor(double score) {
    if (score > 0.7) return const Color(0xFF10B981);
    if (score > 0.4) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getStrengthText(double score) {
    if (score > 0.7) return 'GRADO INDUSTRIAL';
    if (score > 0.4) return 'ACEPTABLE';
    return 'VULNERABLE';
  }
}
