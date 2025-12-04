// Archivo: lib/screens/category_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/recurso_model.dart';
import 'detail_screen.dart';

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
        // CORRECCIÓN VISUAL: Banner Negro
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de color pequeña para indicar la categoría, debajo del banner negro
          Container(height: 6, width: double.infinity, color: categoryColor),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firebaseService.getRecursos(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text('Error al cargar'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) return _buildEmptyState();

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

  Widget _buildEmptyState() {
    return const Center(child: Text('No hay contenido en esta sección.'));
  }

  Widget _buildVideoListTile(BuildContext context, RecursoModel recurso) {
    // Detectar si hay archivo adjunto para mostrar un icono extra
    bool hasFile = recurso.archivoUrl != null && recurso.archivoUrl!.isNotEmpty;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailScreen(recurso: recurso),
            ),
          );
        },
      ),
    );
  }
}
