// Archivo: lib/screens/category_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/recurso_model.dart';
import 'detail_screen.dart';
import 'form_screen.dart'; // Importo esto para poder ir a la pantalla de edición.

class CategoryListScreen extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;

  const CategoryListScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        // Mantengo el banner negro para consistencia visual.
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Una pequeña barra de color debajo del banner para reforzar en qué categoría estoy.
          Container(height: 6, width: double.infinity, color: categoryColor),

          Expanded(
            // Uso StreamBuilder para que la lista se actualice sola si borro o edito algo.
            child: StreamBuilder<QuerySnapshot>(
              stream: firebaseService.getRecursos(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) return _buildEmptyState();

                // Filtro manualmente los documentos que coinciden con esta categoría.
                var docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['categoria'] == categoryName;
                }).toList();

                if (docs.isEmpty) return _buildEmptyState();

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    // Convierto el documento crudo de Firebase a mi objeto RecursoModel.
                    RecursoModel recurso = RecursoModel.fromMap(
                      docs[index].data() as Map<String, dynamic>,
                      docs[index].id,
                    );
                    return _buildVideoListTile(context, recurso);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar cuando no hay nada.
  Widget _buildEmptyState() {
    return const Center(child: Text('No hay contenido en esta sección.'));
  }

  // Aquí construyo la tarjeta de cada video/archivo.
  Widget _buildVideoListTile(BuildContext context, RecursoModel recurso) {
    bool hasFile = recurso.archivoUrl != null && recurso.archivoUrl!.isNotEmpty;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        // Icono izquierdo con el color de la categoría.
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.play_circle_fill, color: categoryColor, size: 30),
        ),
        title: Text(
          recurso.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recurso.autor,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            // Si tiene archivo adjunto, muestro un indicador pequeño.
            if (hasFile) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    "Material disponible",
                    style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                  ),
                ],
              ),
            ],
          ],
        ),
        // AQUI ESTÁ LA MAGIA: Agregué los botones de Editar y Eliminar a la derecha.
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: () {
                // Al pulsar editar, navego al FormScreen pero le paso el recurso actual.
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FormScreen(recursoExistente: recurso),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _confirmarEliminacion(context, recurso),
            ),
          ],
        ),
        onTap: () {
          // Si tocan la tarjeta en general, van al detalle para ver el video.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailScreen(recurso: recurso),
            ),
          );
        },
      ),
    );
  }

  // Diálogo de seguridad para evitar borrados accidentales.
  void _confirmarEliminacion(BuildContext context, RecursoModel recurso) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar cápsula?"),
        content: Text(
          "Estás a punto de borrar '${recurso.titulo}'. Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Cierro el diálogo primero
              try {
                await FirebaseService().deleteRecurso(recurso.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cápsula eliminada correctamente.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
