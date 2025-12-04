// Archivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'utils/app_theme.dart'; // Importamos el archivo de temas

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configuración de la barra de estado transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

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
      debugShowCheckedModeBanner: false,

      // --- CONFIGURACIÓN DE TEMAS ---
      theme: AppTheme.lightTheme, // Tema Claro
      darkTheme: AppTheme.darkTheme, // Tema Oscuro
      themeMode: ThemeMode.system, // Usa la configuración del sistema
      // ------------------------------
      home: const WelcomeScreen(),
    );
  }
}
