import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../widgets/glass_card.dart';
import 'vault_list_screen.dart';
import 'user_form_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final success = await Provider.of<UserController>(context, listen: false)
        .login(_emailController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VaultListScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _loginWithBiometrics() async {
    final success = await Provider.of<UserController>(context, listen: false).loginWithBiometrics();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VaultListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient & Abstract Shapes
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E1B4B)],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/app_logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Smart Vault',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'SEGURIDAD NIVEL INDUSTRIAL',
                    style: TextStyle(
                      color: Color(0xFF818CF8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Correo Electrónico',
                            prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            hintText: 'Llave Maestra',
                            prefixIcon: Icon(Icons.key_rounded, size: 20),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),
                        _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              child: const Text('ACCEDER A LA BÓVEDA'),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 40, height: 1, color: Colors.white10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('O ACCESO RÁPIDO', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                      ),
                      Container(width: 40, height: 1, color: Colors.white10),
                    ],
                  ),
                  const SizedBox(height: 24),
                  IconButton(
                    onPressed: _loginWithBiometrics,
                    icon: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10),
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      child: const Icon(Icons.fingerprint_rounded, size: 40, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserFormScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: '¿Nuevo por aquí? ',
                        style: const TextStyle(color: Colors.white54),
                        children: [
                          TextSpan(
                            text: 'Crea tu Bóveda',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
