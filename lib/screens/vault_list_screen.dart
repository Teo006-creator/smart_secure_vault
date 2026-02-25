import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../controllers/user_controller.dart';
import '../controllers/vault_controller.dart';
import '../widgets/glass_card.dart';
import 'vault_form_screen.dart';
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
    final vault = Provider.of<VaultController>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Bóveda Inteligente', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, size: 20),
            ),
            onPressed: () {
              Provider.of<UserController>(context, listen: false).logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF020617), Color(0xFF0F172A)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildSecuritySummary(vault),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar en tu bóveda...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _searchController.clear()))
                        : null,
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const VaultFormScreen()));
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add_moderator),
        label: const Text('PROTEGER CUENTA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSecuritySummary(VaultController vault) {
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
                    value: 0.85, // Mock value for overall health
                    strokeWidth: 6,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                ),
                const Text('85%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Salud de la Bóveda', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('Excelente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('Todas tus claves están protegidas.', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.white10),
          const SizedBox(height: 16),
          const Text('Tu bóveda está vacía', style: TextStyle(color: Colors.white38, fontSize: 18)),
          const Text('Comienza añadiendo tu primera clave', style: TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildVaultEntryCard(dynamic entry, String masterKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        opacity: 0.03,
        borderRadius: 20,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.lock_person_rounded, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.username, style: const TextStyle(color: Colors.white38)),
              const SizedBox(height: 12),
              _buildStrengthTag(entry.strengthScore),
            ],
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          onTap: () => _showEntryDetails(entry, masterKey),
        ),
      ),
    );
  }

  Widget _buildStrengthTag(double score) {
    Color color = Colors.redAccent;
    String label = 'DÉBIL';
    if (score > 0.4) { color = Colors.orangeAccent; label = 'MEDIA'; }
    if (score > 0.7) { color = const Color(0xFF10B981); label = 'FUERTE'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  void _showEntryDetails(dynamic entry, String masterKey) {
    final vault = Provider.of<VaultController>(context, listen: false);
    final decrypted = vault.decryptPassword(entry.encryptedPassword, masterKey);
    bool hidden = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              ClipOval(
                child: Image.asset(
                  'assets/app_logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(entry.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(entry.category.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 2)),
              const SizedBox(height: 32),
              _buildInfoTile('Usuario', entry.username, Icons.person_outline),
              const SizedBox(height: 16),
              _buildPasswordTile(decrypted, hidden, () => setModalState(() => hidden = !hidden)),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: decrypted));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiada al portapapeles'), behavior: SnackBarBehavior.floating));
                        Navigator.pop(context);
                      },
                      label: const Text('COPIAR'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () {
                        vault.deleteEntry(entry.id!, entry.userId);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white38),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTile(String password, bool hidden, VoidCallback toggle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 20, color: Colors.white38),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contraseña', style: TextStyle(color: Colors.white38, fontSize: 12)),
                Text(hidden ? '••••••••••••' : password, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
            onPressed: toggle,
          ),
        ],
      ),
    );
  }
}

