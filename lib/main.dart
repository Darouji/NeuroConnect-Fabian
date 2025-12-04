// Importamos paquetes para Flutter.
import 'package:flutter/material.dart';
// Importamos Firebase Core.
import 'package:firebase_core/firebase_core.dart';
// Importo las opciones de configuración de Firebase.
import 'firebase_options.dart';
// Importamos la pantalla de bienvenida.
import 'screens/welcome_screen.dart';

// Función principal.
void main() async {
  // Aseguro que los widgets estén inicializados antes de Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializo Firebase usando la configuración generada.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Corro la aplicación principal.
  runApp(const NeuroconectaApp());
}

// Widget principal de la aplicación.
class NeuroconectaApp extends StatelessWidget {
  const NeuroconectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuración base de la app con Material Design.
    return MaterialApp(
      title: 'Neuroconecta',
      // Quitar el banner de debug.
      debugShowCheckedModeBanner: false,
      // Defino el tema general.
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Defino la pantalla inicial.
      home: const WelcomeScreen(),

      // Defino las rutas para la navegación.
      routes: const {
        // Rutas irán aquí.
      },
    );
  }
}
