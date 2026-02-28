import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../controllers/user_controller.dart';
import '../controllers/vault_controller.dart';
import '../widgets/glass_card.dart';
import 'vault_form_screen.dart';
import 'vault_detail_screen.dart';
import 'login_screen.dart';

class VaultListScreen extends StatefulWidget {
  const VaultListScreen({super.key});

  @override
  State<VaultListScreen> createState() => _VaultListScreenState();
}

class _VaultListScreenState extends State<VaultListScreen> {
  final _searchController = TextEditingController();
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final user = Provider.of<UserController>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<VaultController>(context, listen: false).loadEntries(user.id!);
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserController>(context).currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bóveda Inteligente', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: Consumer<VaultController>(
        builder: (context, vault, child) {
          return SafeArea(
            child: Column(
              children: [
                _buildSecuritySummary(vault),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar en tu bóveda...',
                      prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white70 : Colors.black54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _searchController.clear()))
                        : null,
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                _buildCategoryFilter(vault),
                Expanded(
                  child: vault.entries.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: vault.entries.length,
                          itemBuilder: (context, index) {
                            final entry = vault.entries[index];
                            if (_searchController.text.isNotEmpty &&
                                !entry.title.toLowerCase().contains(_searchController.text.toLowerCase())) {
                              return const SizedBox.shrink();
                            }
                            if (user == null) return const SizedBox.shrink();
                            return _buildVaultEntryCard(entry, user.password);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const VaultFormScreen()));
        },
        icon: const Icon(Icons.add_moderator),
        label: const Text('PROTEGER CUENTA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSecuritySummary(VaultController vault) {
    final health = vault.vaultHealth;
    final healthPercent = (health * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        opacity: 0.05,
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: health,
                    strokeWidth: 6,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                ),
                Text('$healthPercent%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Salud de la Bóveda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Tu encriptación AES-256 está activa y monitoreando.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(VaultController vault) {
    final categories = ['General', 'Finanzas', 'Social', 'Trabajo', 'WiFi'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = vault.filterCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => vault.setFilterCategory(val ? cat : 'General'),
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text('Bóveda Vacía', style: TextStyle(color: Colors.white38, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Empieza a asegurar tus activos digitales', style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildVaultEntryCard(dynamic entry, String masterPassword) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        opacity: 0.05,
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VaultDetailScreen(entry: entry),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getCategoryIcon(entry.category), color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(entry.username, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getStrengthColor(entry.strengthScore),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(_getStrengthText(entry.strengthScore), style: TextStyle(color: _getStrengthColor(entry.strengthScore), fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.1)),
        ),
      ),
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
    if (score > 0.7) return 'FUERTE';
    if (score > 0.4) return 'MEDIA';
    return 'DÉBIL';
  }
}
