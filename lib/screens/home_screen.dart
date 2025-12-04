// Archivo: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/recurso_model.dart';
import 'form_screen.dart';
import 'detail_screen.dart';
import 'auth/login_screen.dart'; // Para redirigir al salir.

// Widget para la pantalla principal (Dashboard).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instancia del servicio para leer datos y cerrar sesión.
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      // Fondo de color neutro suave (blanco humo/gris muy claro) para bajo estímulo visual.
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Biblioteca NeuroConecta'),
        centerTitle: true,
        // Usamos un color sólido pero no chillón.
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          // Botón discreto para cerrar sesión.
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () async {
              await firebaseService.signOut();
              if (context.mounted) {
                // Redirigimos al Login y eliminamos el historial de navegación.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      // StreamBuilder escucha la base de datos en tiempo real.
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getRecursos(),
        builder: (context, snapshot) {
          // 1. Estado de carga.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Manejo de errores.
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar recursos.'));
          }

          // 3. Verificamos si hay datos.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No hay cápsulas disponibles aún.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 4. Mostramos la cuadrícula (Grid) de recursos.
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            // Definimos una cuadrícula fija de 2 columnas.
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio:
                  0.85, // Relación de aspecto para que sean "tarjetas" verticales.
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Obtenemos el documento individual.
              var doc = snapshot.data!.docs[index];
              // Lo convertimos a nuestro modelo seguro.
              RecursoModel recurso = RecursoModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              return _buildRecursoCard(context, recurso);
            },
          );
        },
      ),
      // Botón flotante para el Administrador (Subir contenido).
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const FormScreen()));
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget para construir cada tarjeta individual (Pictograma).
  Widget _buildRecursoCard(BuildContext context, RecursoModel recurso) {
    return Card(
      // Elevación baja para diseño plano y limpio ("cuadradito").
      elevation: 2,
      // Forma rectangular con bordes muy ligeramente redondeados.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      clipBehavior:
          Clip.antiAlias, // Asegura que el contenido respete los bordes.
      child: InkWell(
        // Al tocar, vamos a la pantalla de detalle pasando el objeto completo.
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailScreen(recurso: recurso),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Parte superior: Icono representativo o miniatura.
            Expanded(
              flex: 3, // Ocupa más espacio visual.
              child: Container(
                color: Colors.blue[50], // Color de fondo suave (pastel).
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill, // Icono de reproducción.
                    size: 50,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
            // Parte inferior: Título y Autor.
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recurso.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            recurso.autor,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
