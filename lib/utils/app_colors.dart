// Archivo: lib/utils/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // --- Colores de Marca ---
  static const Color primaryBlue = Colors.blueAccent;
  static const Color secondaryGrey = Colors.blueGrey;

  // --- Fondos Neutros ---
  static const Color backgroundLight = Color(0xFFFAFAFA); // Blanco humo
  static const Color backgroundDark = Color(0xFF121212); // Negro suave

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // --- Textos ---
  static const Color textLight = Colors.black87;
  static const Color textDark = Colors.white;
  static const Color textSubtleLight = Colors.grey;
  static const Color textSubtleDark = Colors.white70;

  // --- Bordes ---
  static const Color borderLight = Colors.black;
  static const Color borderDark = Colors.grey;

  // --- Colores de Categorías (Semánticos) ---
  // Centralizamos estos colores para usarlos en Home y en Listas
  static const Color catTerapias = Colors.purple;
  static const Color catSaludMental = Colors.green;
  static const Color catContencion = Colors.blue;
  static const Color catAreaEspecial = Colors.orange;
  static const Color catMyFunner = Colors.teal;
  static const Color catGeneral = Colors.blueGrey;
}
