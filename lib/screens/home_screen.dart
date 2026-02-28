import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/vault_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/glass_card.dart';
import 'vault_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('SMART VAULT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: theme.colorScheme.primary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<UserController>(
                builder: (context, userController, child) {
                  final userName = userController.currentUser?.name.split(' ').first ?? 'Usuario';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola de nuevo,', style: TextStyle(color: isDark ? Colors.white60 : Colors.black45, fontSize: 16)),
                      Text(userName, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildQuickStats(context),
              const SizedBox(height: 24),
              _buildStorageUsage(context),
              const SizedBox(height: 32),
              Text('Módulos de Seguridad', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildCategoryGrid(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VaultFormScreen())),
        child: const Icon(Icons.add_moderator),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<VaultController>(
      builder: (context, vault, child) {
        final health = vault.vaultHealth;
        final healthPercent = (health * 100).toInt();
        Color healthColor = Colors.redAccent;
        if (health > 0.4) healthColor = Colors.orangeAccent;
        if (health > 0.7) healthColor = const Color(0xFF10B981);

        return Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                opacity: 0.05,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_rounded, color: healthColor),
                    const SizedBox(height: 8),
                    const Text('Salud', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Text('$healthPercent%', style: TextStyle(color: healthColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                opacity: 0.05,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.key_rounded, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    const Text('Claves', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Text('${vault.entries.length}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStorageUsage(BuildContext context) {
    const int maxCapacity = 500; // Mock capacity limit

    return Consumer<VaultController>(
      builder: (context, vault, child) {
        final count = vault.entries.length;
        final progress = (count / maxCapacity).clamp(0.0, 1.0);
        
        return GlassCard(
          padding: const EdgeInsets.all(20),
          opacity: 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ocupación de la Bóveda', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  Text('$count / $maxCapacity claves', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress == 0 ? 0.02 : progress,
                  minHeight: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu espacio de encriptación está optimizado. SQLite permite almacenamiento expansivo.',
                style: TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      {'name': 'WiFi', 'icon': Icons.wifi_protected_setup_rounded, 'color': Colors.blueAccent},
      {'name': 'Social', 'icon': Icons.public_rounded, 'color': Colors.purpleAccent},
      {'name': 'Finanzas', 'icon': Icons.account_balance_wallet_rounded, 'color': Colors.greenAccent},
      {'name': 'Trabajo', 'icon': Icons.business_center_rounded, 'color': Colors.orangeAccent},
      {'name': 'General', 'icon': Icons.apps_rounded, 'color': Colors.blueGrey},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return GestureDetector(
          onTap: () {
            final vault = Provider.of<VaultController>(context, listen: false);
            final nav = Provider.of<NavigationController>(context, listen: false);
            
            vault.setFilterCategory(cat['name'] as String);
            nav.setIndex(1); // Go to Vault List
          },
          child: GlassCard(
            opacity: 0.05,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'] as IconData, size: 32, color: cat['color'] as Color),
                const SizedBox(height: 12),
                Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}
