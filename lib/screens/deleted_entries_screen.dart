import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/vault_controller.dart';
import '../widgets/glass_card.dart';

class DeletedEntriesScreen extends StatelessWidget {
  const DeletedEntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bóveda de Reciclaje', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<VaultController>(
        builder: (context, vault, child) {
          final entries = vault.deletedEntries;

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 64, color: isDark ? Colors.white10 : Colors.black12),
                  const SizedBox(height: 16),
                  Text('No hay claves eliminadas', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
                ],
              ),
            );
          }

          return SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    opacity: 0.03,
                    child: ListTile(
                      title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(entry.username, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore_rounded, color: Colors.greenAccent),
                            onPressed: () => vault.restoreEntry(entry),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                            onPressed: () {
                              _confirmPermanentDelete(context, vault, entry);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmPermanentDelete(BuildContext context, VaultController vault, dynamic entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('¿Eliminar permanentemente?'),
        content: Text('Esta acción no se puede deshacer y la clave se perderá para siempre.', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              vault.deletePermanently(entry.id!, entry.userId);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
