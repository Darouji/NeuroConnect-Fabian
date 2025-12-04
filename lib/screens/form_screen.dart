// Archivo: lib/screens/form_screen.dart

import 'dart:io'; // Para manejar el archivo seleccionado.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Para abrir la galería.
import '../services/firebase_service.dart';
import '../models/recurso_model.dart';

class FormScreen extends StatefulWidget {
  // Recibir un objeto opcional para edición futura.
  // final RecursoModel? recursoToEdit;
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto.
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();

  // Servicio de Firebase.
  final FirebaseService _firebaseService = FirebaseService();

  // Variables para manejar el video y el estado de carga.
  File? _selectedVideo;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // Método para seleccionar video de la galería.
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
      });
    }
  }

  // Método principal para guardar todo.
  void _saveRecurso() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación extra: Exigir que se seleccione un video (opcional según requerimiento).
    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un video para la cápsula.'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? videoUrl;

      // 1. Si hay un video seleccionado, lo subimos primero a Storage.
      if (_selectedVideo != null) {
        videoUrl = await _firebaseService.uploadVideo(_selectedVideo!);
      }

      // 2. Creamos el modelo con los datos del formulario y la URL del video.
      final recurso = RecursoModel(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        autor: _autorController.text.trim(),
        videoUrl: videoUrl,
      );

      // 3. Guardamos los datos en Firestore.
      await _firebaseService.saveRecurso(recurso);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cápsula creada exitosamente!')),
        );
        Navigator.of(context).pop(); // Regresamos al Home.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _autorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si se está subiendo, mostramos una pantalla de carga bloqueante.
    if (_isUploading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Subiendo video y guardando datos...'),
              Text(
                'Esto puede tardar unos segundos.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cápsula'),
        backgroundColor:
            Colors.blueAccent, // Cambiaremos esto luego por colores neutros.
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Detalles de la Cápsula',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Campo Título.
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del Video',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.movie_creation_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 16),

              // Campo Descripción.
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Contenido',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 16),

              // Campo Autor.
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(
                  labelText: 'Autor / Especialista',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa el autor' : null,
              ),
              const SizedBox(height: 24),

              // Sección de Selección de Video.
              const Text(
                'Archivo de Video',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Tarjeta para seleccionar video.
              Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: InkWell(
                  onTap: _pickVideo,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Icon(
                          _selectedVideo != null
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          size: 40,
                          color: _selectedVideo != null
                              ? Colors.green
                              : Colors.blueGrey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _selectedVideo != null
                              ? 'Video seleccionado: ${_selectedVideo!.path.split('/').last}'
                              : 'Toca para seleccionar video de la galería',
                          style: TextStyle(
                            color: _selectedVideo != null
                                ? Colors.green
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón de Guardar.
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveRecurso,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Subir y Guardar',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
