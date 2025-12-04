// Archivo: lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_screen.dart';
import '../../services/firebase_service.dart';
import 'package:neuro_conecta/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Verificamos si el usuario YA está logueado al abrir la pantalla.
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    // Damos un pequeño respiro para que Flutter termine de construir la UI.
    await Future.delayed(const Duration(milliseconds: 500));
    final user = _firebaseService.getCurrentUser();
    if (user != null && mounted) {
      print("Usuario ya logueado detectado: ${user.uid}. Redirigiendo...");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _firebaseService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // La redirección la maneja el listener de FirebaseAuth o el await exitoso.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error: ${e.message}';
      if (e.code == 'user-not-found')
        message = 'Usuario no encontrado.';
      else if (e.code == 'wrong-password')
        message = 'Contraseña incorrecta.';

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      print("Iniciando flujo de Google...");
      final userCredential = await _firebaseService.signInWithGoogle();

      if (userCredential != null) {
        print("Login exitoso. Usuario: ${userCredential.user?.uid}");
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        print("El usuario canceló el login de Google.");
      }
    } catch (e) {
      print("Error en Login Google: $e"); // Ver esto en la consola es clave
      if (mounted) {
        // Mostramos el error exacto para depurar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para adaptar el diseño si el teclado aparece
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de Sesión'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // --- BRANDING ---
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 250,
                ), // Evita desbordes
                width: double.infinity,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/neuro_conecta_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Bienvenido a NeuroConecta',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // --- FORMULARIO ---
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        isDense: true,
                      ),
                      validator: (value) =>
                          value == null || !value.contains('@')
                          ? 'Correo inválido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        isDense: true,
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _signInWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Ingresar',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'O',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // --- BOTÓN GOOGLE ---
              ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 35,
                  color: Colors.blue,
                ),
                label: const Text(
                  'Continuar con Google',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('¿No tienes cuenta? Regístrate aquí.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
