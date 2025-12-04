// Archivo: lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/home_screen.dart';
import '../../services/firebase_service.dart';
import 'package:neuro_conecta/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Clave global para validar mi formulario antes de enviar datos.
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar lo que el usuario escribe.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Apenas carga la pantalla, verifico si ya hay una sesión activa para saltar el login.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCurrentUser());
  }

  void _checkCurrentUser() {
    final user = _firebaseService.getCurrentUser();
    // Si el usuario ya existe, lo mando directo al Home.
    if (user != null && mounted) _navigateToHome();
  }

  // Función auxiliar para ir al Home y borrar el historial de navegación (para que no vuelvan al login con "atrás").
  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Lógica para login con Email y Contraseña.
  void _signInWithEmail() async {
    // Si el formulario no es válido (ej. campos vacíos), no hago nada.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Muestro el circulito de carga.

    try {
      await _firebaseService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) _navigateToHome();
    } on FirebaseAuthException catch (e) {
      _showError('Error: ${e.message}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lógica para login con Google.
  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await _firebaseService.signInWithGoogle();
      if (user != null && mounted) _navigateToHome();
    } catch (e) {
      _showError('Error iniciando con Google');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Muestro errores en una barrita inferior (SnackBar).
  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si está cargando, muestro solo el indicador de progreso.
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso NeuroConecta'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Muestro mi logo secundario.
              SizedBox(
                height: 250,
                child: Image.asset(
                  'assets/images/neuro_conecta_logo2.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, size: 80),
                ),
              ),
              const SizedBox(height: 30),

              // Formulario de entrada de datos.
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // Oculto la contraseña.
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón principal de Ingreso.
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _signInWithEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'INGRESAR',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divisor visual con la letra "O".
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("O"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // Botón de Google.
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 30,
                    color: Colors.red,
                  ),
                  label: Text(
                    'Continuar con Google',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Link para ir a registrarse si no tiene cuenta.
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                ),
                child: const Text('¿No tienes cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
