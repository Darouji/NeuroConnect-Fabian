// Archivo: lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Navegación segura al login, reemplazando esta pantalla para que no se pueda volver atrás con "Back".
  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Uso un Center y un Column para alinear todo verticalmente en medio de la pantalla.
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Muestro mi logo principal. Uso 'contain' para que no se recorte.
                  SizedBox(
                    height: 250,
                    child: Image.asset(
                      'assets/images/neuro_conecta_logo2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título de la App usando el estilo definido en el tema.
                  Text(
                    'NeuroConecta',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtítulo explicativo.
                  Text(
                    'Tu plataforma de apoyo psicopedagógico',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),

              // Botón grande para iniciar.
              ElevatedButton(
                onPressed: () => _goToLogin(context),
                style: ElevatedButton.styleFrom(
                  // Tomo el color primario del tema actual.
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Comenzar',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
