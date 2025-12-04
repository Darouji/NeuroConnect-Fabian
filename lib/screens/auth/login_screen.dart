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
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Verificación segura del usuario al iniciar.
    // Usamos addPostFrameCallback para asegurar que la UI esté lista antes de navegar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCurrentUser();
    });
  }

  // Método seguro para verificar si ya hay sesión.
  void _checkCurrentUser() async {
    final user = _firebaseService.getCurrentUser();
    if (user != null) {
      if (mounted) {
        _navigateToHome();
      }
    }
  }

  // Método centralizado para navegar al Home y borrar historial.
  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false, // Elimina todas las rutas anteriores.
    );
  }

  // Lógica de inicio de sesión con Correo.
  void _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Si no hubo error, navegamos.
      if (mounted) {
        _navigateToHome();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error al iniciar sesión.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Usuario o contraseña incorrectos.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo no es válido.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
      }
    } finally {
      // Siempre detenemos el indicador de carga.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Lógica de inicio de sesión con Google.
  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _firebaseService.signInWithGoogle();

      if (userCredential != null) {
        if (mounted) {
          _navigateToHome();
        }
      } else {
        // El usuario cerró la ventana de Google sin seleccionar cuenta.
        print("Login cancelado por el usuario.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error con Google: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    // Si está cargando, bloqueamos la pantalla para evitar múltiples clics.
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Quita la flecha de volver atrás si vienes de Welcome.
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo
              SizedBox(
                height: 180,
                child: Image.asset(
                  'assets/images/neuro_conecta_logo.png', // Asegúrate que esta ruta es correcta en tu pubspec.
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido a NeuroConecta',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Formulario
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
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Introduce un correo válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Mínimo 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _signInWithEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('O', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // Botón Google
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
                  label: const Text(
                    'Continuar con Google',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                child: const Text('¿No tienes cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
