import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Crear Bóveda Maestra' : 'Editar Perfil'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.shield_outlined, size: 64, color: Color(0xFF8B5CF6)),
              const SizedBox(height: 16),
              Text(
                widget.user == null ? 'Configura tu cuenta' : 'Actualiza tus datos',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) => value!.isEmpty ? 'Ingrese un email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña Maestra',
                        prefixIcon: Icon(Icons.lock_open_outlined),
                        helperText: 'Esta clave se usará para cifrar tus datos.',
                      ),
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final user = User(
                            id: widget.user?.id,
                            name: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          if (widget.user == null) {
                            Provider.of<UserController>(context, listen: false).addUser(user);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bóveda creada. ¡Inicia sesión!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            Provider.of<UserController>(context, listen: false).updateUser(user);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(widget.user == null ? 'REGISTRARME' : 'ACTUALIZAR'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
