// Archivo: lib/utils/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Estos son mis colores principales de marca.
  static const Color primaryBlue = Colors.blueAccent;
  static const Color secondaryGrey = Colors.blueGrey;

  // Defino los colores de fondo para modo claro y oscuro.
  static const Color backgroundLight = Color(0xFFFAFAFA); // Blanco humo
  static const Color backgroundDark = Color(0xFF121212); // Negro suave

  // Colores para las superficies (tarjetas, appbars).
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Colores para el texto según el fondo.
  static const Color textLight = Colors.black87;
  static const Color textDark = Colors.white;
  static const Color textSubtleLight = Colors.grey;
  static const Color textSubtleDark = Colors.white70;

  // Colores para los bordes de mis tarjetas.
  static const Color borderLight = Colors.black;
  static const Color borderDark = Colors.grey;

  // Aquí asigno un color específico a cada categoría para identificarlas visualmente.
  static const Color catTerapias = Colors.purple;
  static const Color catSaludMental = Colors.green;
  static const Color catContencion = Colors.blue;
  static const Color catAreaEspecial = Colors.orange;
  static const Color catMyFunner = Colors.teal;
  static const Color catGeneral = Colors.blueGrey;
}
