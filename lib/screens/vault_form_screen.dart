import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../controllers/user_controller.dart';
import '../controllers/vault_controller.dart';
import '../services/security_service.dart';
import '../widgets/glass_card.dart';

class VaultFormScreen extends StatefulWidget {
  const VaultFormScreen({super.key});

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
        await Provider.of<VaultController>(context, listen: false).addEntry(
          userId: user.id!,
          title: _titleController.text,
          username: _usernameController.text,
          plainPassword: _passwordController.text,
          category: _selectedCategory,
          masterPassword: user.password,
        );
        if (mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Blindar Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Información del Servicio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      opacity: 0.05,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Nombre del Servicio', prefixIcon: Icon(Icons.apps_rounded)),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(labelText: 'Usuario o Correo', prefixIcon: Icon(Icons.person_pin_rounded)),
                            validator: (v) => v!.isEmpty ? 'Requerido' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('Protección AES-256', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
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
                              side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('Clasificación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['General', 'Finanzas', 'Social', 'Trabajo', 'Ocio'].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (v) => setState(() => _selectedCategory = cat),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          selectedColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('ENCRIPTAR Y GUARDAR'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
