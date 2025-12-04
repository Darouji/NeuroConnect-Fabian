import 'package:flutter/material.dart';
// Importo la pantalla de Login para poder navegar a ella.
import 'auth/login_screen.dart';

// Esta pantalla es un StatelessWidget porque su contenido no cambia internamente.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Método para manejar la navegación hacia el Login.
  void _goToLogin(BuildContext context) {
    // Uso pushReplacement para que el usuario no pueda volver a esta pantalla
    // con el botón de "atrás" una vez que haya iniciado.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold proporciona la estructura visual básica (AppBar, cuerpo, etc.).
    return Scaffold(
      body: Center(
        // Utilizo un Column para organizar los widgets verticalmente.
        child: Column(
          // Distribuyo los elementos para que ocupen el espacio disponible.
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Widget para el logo (simulado con un icono grande por ahora).
            Column(
              children: const <Widget>[
                // Icono grande para simular el Logo de Neuroconecta.
                Icon(Icons.psychology_alt, size: 100, color: Colors.blueAccent),
                SizedBox(height: 16),
                // Nombre de la aplicación.
                Text(
                  'Neuroconecta',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tu plataforma de apoyo psicopedagógico',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),

            // Botón de Inicio para pasar a la siguiente pantalla.
            ElevatedButton(
              // Llama a la función de navegación cuando se presiona.
              onPressed: () => _goToLogin(context),
              style: ElevatedButton.styleFrom(
                // Establezco el color del botón.
                backgroundColor: Colors.blueAccent,
                // Defino el tamaño del botón.
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                // Defino la forma del botón.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                'Comenzar',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
