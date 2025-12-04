// Archivo: lib/widgets/category_card.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color categoryColor;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Detecto si el modo oscuro está activo para ajustar bordes y transparencias.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? AppColors.borderDark
        : AppColors.borderLight;
    final textColor = Theme.of(context).textTheme.titleMedium?.color;
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 2.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, // Ejecuto la acción que me pasaron desde el Home.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Título de la categoría.
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Círculo con el icono. Ajusto la opacidad según el tema.
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(
                    alpha: isDarkMode ? 0.3 : 1.0,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode
                        ? categoryColor.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(icon, size: 35, color: Colors.white),
              ),

              // Descripción pequeña abajo.
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: subTextColor),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
