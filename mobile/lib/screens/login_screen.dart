import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {

    // 🔥 VALIDACIÓN BÁSICA (IMPORTANTE)
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa usuario y contraseña')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await AuthService().login(
        _userController.text,
        _passController.text,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas'),
          ),
        );
      }

    } catch (e) {

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión con el servidor'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso SMAT')),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),

            const SizedBox(height: 30),

            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text('Iniciar Sesión'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}