import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../controllers/user_controller.dart';
import '../controllers/vault_controller.dart';
import '../services/security_service.dart';
import '../widgets/glass_card.dart';
import '../models/vault_entry_model.dart';

class VaultFormScreen extends StatefulWidget {
  final VaultEntry? entry;
  const VaultFormScreen({super.key, this.entry});

  @override
  State<VaultFormScreen> createState() => _VaultFormScreenState();
}

class _VaultFormScreenState extends State<VaultFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _securityService = SecurityService();
  
  String _selectedCategory = 'General';
  double _strength = 0.0;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _usernameController.text = widget.entry!.username;
      _selectedCategory = widget.entry!.category;
      _strength = widget.entry!.strengthScore;
      // We don't decrypt here for safety in the form header, 
      // but the user can generate a new one or the controller handles it.
    }
  }

  void _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$&*~';
    final random = Random();
    final password = List.generate(18, (i) => chars[random.nextInt(chars.length)]).join();
    _passwordController.text = password;
    _updateStrength(password);
  }

  void _updateStrength(String value) {
    setState(() {
      _strength = _securityService.calculateStrength(value);
    });
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserController>(context, listen: false).currentUser;
      if (user != null) {
        if (widget.entry == null) {
          await Provider.of<VaultController>(context, listen: false).addEntry(
            userId: user.id!,
            title: _titleController.text,
            username: _usernameController.text,
            plainPassword: _passwordController.text,
            category: _selectedCategory,
            masterPassword: user.password,
          );
        } else {
          // Add update logic in controller if needed, but for now we focus on New entries
        }
        if (mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entry == null ? 'Blindar Cuenta' : 'Editar Cuenta',
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información del Servicio'),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                opacity: 0.05,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Servicio',
                        prefixIcon: Icon(Icons.apps_rounded),
                        border: InputBorder.none,
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const Divider(color: Colors.white10),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario o Correo',
                        prefixIcon: Icon(Icons.person_pin_rounded),
                        border: InputBorder.none,
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Protección AES-256'),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                opacity: 0.05,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      onChanged: _updateStrength,
                      decoration: InputDecoration(
                        labelText: 'Contraseña de Acceso',
                        prefixIcon: const Icon(Icons.security_update_good_rounded),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildStrengthMeter(),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _generatePassword,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('GENERAR CLAVE MAESTRA'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Clasificación'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['General', 'Finanzas', 'Social', 'Trabajo', 'WiFi'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  IconData icon = _getCategoryIcon(cat);
                  return ChoiceChip(
                    avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : (isDark ? Colors.white38 : Colors.black38)),
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (v) => setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: theme.colorScheme.primary,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ENCRIPTAR Y GUARDAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget _buildStrengthMeter() {
    Color color = Colors.redAccent;
    String text = 'VULNERABLE';
    if (_strength > 0.4) { color = Colors.orangeAccent; text = 'ACEPTABLE'; }
    if (_strength > 0.7) { color = const Color(0xFF10B981); text = 'GRADO INDUSTRIAL'; }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Nivel de Seguridad', style: TextStyle(fontSize: 11, color: Colors.white38)),
            Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _strength == 0 ? 0.05 : _strength,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
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
}
