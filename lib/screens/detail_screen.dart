import 'package:flutter/material.dart';

// Es un StatelessWidget porque solo muestra datos que recibe.
class DetailScreen extends StatelessWidget {
  // Recibo el ID del elemento para saber qué datos buscar en Firebase.
  final String itemId;

  // Constructor.
  const DetailScreen({required this.itemId, super.key});

  // Función simulada para cargar los detalles del recurso.
  // En la aplicación real, usaría el itemId para obtener los datos de Firebase.
  Map<String, String> _fetchItemDetails(String id) {
    // Datos de ejemplo para simular el recurso de Neuroconecta.
    return {
      'titulo': 'Técnicas de Respiración para la Ansiedad',
      'descripcion':
          'Guía paso a paso sobre ejercicios de respiración diafragmática y 4-7-8 para reducir el estrés y la ansiedad en niños y adultos.',
      'autor': 'Lic. Psic. Ana María Torres',
      'fecha': '2025-10-20',
      'contenido':
          'El ejercicio 4-7-8: Inhala suavemente por la nariz contando hasta 4. Mantén la respiración contando hasta 7. Exhala completamente por la boca contando hasta 8. Repite el ciclo 4 veces.',
    };
  }

  @override
  Widget build(BuildContext context) {
    // Cargo los datos simulados.
    final details = _fetchItemDetails(itemId);

    return Scaffold(
      appBar: AppBar(
        title: Text(details['titulo']!),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // Uso un ListView para que el contenido sea desplazable.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Título principal.
          Text(
            details['titulo']!,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Autor y fecha.
          Text(
            'Por ${details['autor']} | Publicado el ${details['fecha']}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Divider(height: 24),

          // Descripción general.
          const Text(
            'Descripción:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(details['descripcion']!, style: const TextStyle(fontSize: 16)),
          const Divider(height: 24),

          // Contenido detallado.
          const Text(
            'Contenido:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            details['contenido']!,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),

          // Botón de acción adicional (ejemplo: Descargar PDF).
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Descargando recurso...')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Descargar Guía'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}
