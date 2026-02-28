import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import '../widgets/glass_card.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController(text: widget.user?.password ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.user == null ? 'Nueva Bóveda' : 'Editar Perfil', 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.shield_outlined, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  widget.user == null ? 'Protege tu Mundo Digital' : 'Actualiza tu Identidad',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tus datos se encriptan localmente con AES-256',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    opacity: 0.05,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nombre Completo',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => v!.isEmpty ? 'Ingresa tu nombre' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email de Recuperación',
                          icon: Icons.email_outlined,
                          validator: (v) => v!.isEmpty ? 'Ingresa tu email' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Contraseña Maestra',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          helper: 'Esta clave cifra toda tu bóveda.',
                          validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                          ),
                          child: Text(
                            widget.user == null ? 'CREAR MI BÓVEDA' : 'GUARDAR CAMBIOS',
                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? helper,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
        helperText: helper,
        helperStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: widget.user?.id,
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      final controller = Provider.of<UserController>(context, listen: false);
      if (widget.user == null) {
        controller.addUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Bóveda Maestra creada con éxito!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        controller.updateUser(user);
      }
      Navigator.pop(context);
    }
  }
}
