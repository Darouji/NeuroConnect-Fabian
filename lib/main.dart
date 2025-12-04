// Archivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  // Me aseguro de que el motor de Flutter esté listo antes de llamar a código nativo.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializo la conexión con mi proyecto de Firebase usando la configuración generada.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Hago que la barra de estado (donde está la hora y batería) sea transparente para un look más moderno.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Bloqueo la app para que solo funcione en vertical, así no se rompe el diseño al girar el móvil.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const NeuroconectaApp());
}

class NeuroconectaApp extends StatelessWidget {
  const NeuroconectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroConecta',
      debugShowCheckedModeBanner:
          false, // Quito la etiqueta "Debug" de la esquina.
      // Aplico mis temas personalizados que definí en 'app_theme.dart'.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode
          .system, // Dejo que la app siga la configuración del sistema del usuario.
      // La primera pantalla que muestro es la de Bienvenida.
      home: const WelcomeScreen(),
    );
  }
}
