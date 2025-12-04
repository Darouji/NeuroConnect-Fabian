// Archivo: lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

// Esta pantalla es un StatelessWidget porque su contenido no cambia internamente.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Método para manejar la navegación hacia el Login.
  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo limpio para que resalte el logo.
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Bloque superior: Logo y Texto.
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // --- LOGO OFICIAL ---
                  // Reemplazo el icono por la imagen del asset.
                  SizedBox(
                    height: 250, // Tamaño grande y visible.
                    child: Image.asset(
                      'assets/images/neuro_conecta_logo1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre de la aplicación.
                  const Text(
                    'Neuroconecta',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tu plataforma de apoyo psicopedagógico',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ],
              ),

              // Botón de Inicio para pasar a la siguiente pantalla.
              ElevatedButton(
                onPressed: () => _goToLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5, // Sombra para darle relevancia.
                ),
                child: const Text(
                  'Comenzar',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
