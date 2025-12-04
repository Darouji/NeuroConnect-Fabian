// Archivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para controlar la barra de sistema (el borde gris).
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // <-- Agregado para App Check.
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';

void main() async {
  // Aseguramos que los widgets de Flutter estén inicializados antes de ejecutar código asíncrono.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos Firebase con la configuración generada automáticamente.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- ACTIVAR APP CHECK (SOLUCIÓN AL ERROR DE AUTH) ---
  // Esto evita el error "No AppCheckProvider installed" y detiene que Firebase bloquee tus requests.
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );

  // --- SOLUCIÓN DEL BANNER GRIS ---
  // Configuramos el estilo del sistema para que la barra de navegación (abajo)
  // y la barra de estado (arriba) sean transparentes o del color de la app.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // Barra de navegación inferior (botones Android): La ponemos blanca.
      systemNavigationBarColor: Colors.white,
      // Iconos de la barra inferior: Oscuros para que se vean sobre el blanco.
      systemNavigationBarIconBrightness: Brightness.dark,
      // Barra de estado superior (batería, hora): Transparente.
      statusBarColor: Colors.transparent,
      // Iconos de la barra superior: Oscuros.
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Bloqueamos la orientación para que la app solo funcione en vertical (opcional pero recomendado).
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
      // Título interno de la aplicación.
      title: 'NeuroConecta',

      // Quitamos la etiqueta roja de "DEBUG" de la esquina superior derecha.
      debugShowCheckedModeBanner: false,

      // Definimos el tema global con colores neutros y formas rectas.
      theme: ThemeData(
        // Color semilla para generar la paleta (Azul suave).
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        // Fondo por defecto de las pantallas.
        scaffoldBackgroundColor: Colors.white,
        // Estilo global de la AppBar.
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Pantalla inicial de la aplicación.
      home: const WelcomeScreen(),
    );
  }
}
