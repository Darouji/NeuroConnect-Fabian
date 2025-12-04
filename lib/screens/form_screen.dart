// Archivo: lib/screens/form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firebase_service.dart';
import '../models/recurso_model.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();

  final List<String> _categorias = [
    'Terapias Clínicas',
    'Salud Mental',
    'Contención Emocional',
    'Área Especial',
    'MyFunner',
    'General',
  ];
  String _selectedCategoria = 'Terapias Clínicas';

  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedVideo;
  File? _selectedFile;
  String? _selectedFileName;

  bool _isUploading = false;

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _selectedVideo = File(video.path));
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  void _saveRecurso() async {
    if (!_formKey.currentState!.validate()) return;

    // VALIDACIÓN CORREGIDA: Al menos UNO de los dos debe existir
    if (_selectedVideo == null && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes subir un Video O un Archivo para crear la cápsula.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? videoUrl;
      // Solo subimos video si existe
      if (_selectedVideo != null) {
        videoUrl = await _firebaseService.uploadVideo(_selectedVideo!);
      }

      String? fileUrl;
      // Solo subimos archivo si existe
      if (_selectedFile != null && _selectedFileName != null) {
        fileUrl = await _firebaseService.uploadFile(
          _selectedFile!,
          _selectedFileName!,
        );
      }

      final recurso = RecursoModel(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        autor: _autorController.text.trim(),
        categoria: _selectedCategoria,
        videoUrl: videoUrl, // Puede ser nulo
        archivoUrl: fileUrl, // Puede ser nulo
        archivoNombre: _selectedFileName,
      );

      await _firebaseService.saveRecurso(recurso);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Contenido guardado correctamente!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Subiendo contenido...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cápsula'),
        backgroundColor: Colors.black, // Banner negro (Requerimiento)
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Información General',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _selectedCategoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categorias
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategoria = val!),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 30),

              const Text(
                'Multimedia (Sube al menos uno)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // --- VIDEO ---
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Icon(
                  _selectedVideo == null
                      ? Icons.video_call
                      : Icons.check_circle,
                  color: _selectedVideo == null ? Colors.grey : Colors.green,
                ),
                title: Text(
                  _selectedVideo == null
                      ? 'Subir Video (Opcional)'
                      : 'Video Seleccionado',
                ),
                subtitle: _selectedVideo != null
                    ? Text(_selectedVideo!.path.split('/').last)
                    : null,
                trailing: _selectedVideo != null
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _selectedVideo = null),
                      )
                    : null,
                onTap: _pickVideo,
              ),
              const SizedBox(height: 15),

              // --- ARCHIVO ---
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Icon(
                  _selectedFile == null
                      ? Icons.attach_file
                      : Icons.check_circle,
                  color: _selectedFile == null ? Colors.grey : Colors.blue,
                ),
                title: Text(
                  _selectedFile == null
                      ? 'Adjuntar Archivo (Opcional)'
                      : 'Archivo Seleccionado',
                ),
                subtitle: _selectedFileName != null
                    ? Text(_selectedFileName!)
                    : null,
                trailing: _selectedFile != null
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() {
                          _selectedFile = null;
                          _selectedFileName = null;
                        }),
                      )
                    : null,
                onTap: _pickFile,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveRecurso,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('PUBLICAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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
