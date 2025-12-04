// Archivo: lib/screens/form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firebase_service.dart';
import '../models/recurso_model.dart';

class FormScreen extends StatefulWidget {
  // Acepto un recurso opcional. Si llega null, es CREAR. Si llega dato, es EDITAR.
  final RecursoModel? recursoExistente;

  const FormScreen({super.key, this.recursoExistente});

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

  // Variables para archivos NUEVOS (que sube ahora)
  File? _selectedVideo;
  File? _selectedFile;
  String? _selectedFileName;

  // Variables para archivos YA EXISTENTES (en modo edición)
  String? _existingVideoUrl;
  String? _existingFileUrl;
  String? _existingFileName;

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Si estoy editando, relleno los campos con la info que viene de Firebase.
    if (widget.recursoExistente != null) {
      final r = widget.recursoExistente!;
      _tituloController.text = r.titulo;
      _descripcionController.text = r.descripcion;
      _autorController.text = r.autor;

      // Me aseguro de que la categoría exista en mi lista, si no pongo General.
      if (_categorias.contains(r.categoria)) {
        _selectedCategoria = r.categoria;
      } else {
        _selectedCategoria = 'General';
      }

      // Guardo las referencias a los archivos antiguos.
      _existingVideoUrl = r.videoUrl;
      _existingFileUrl = r.archivoUrl;
      _existingFileName = r.archivoNombre;
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        _existingVideoUrl = null; // Si elige uno nuevo, olvido el antiguo.
      });
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
        _existingFileUrl = null; // Si elige uno nuevo, olvido el antiguo.
        _existingFileName = null;
      });
    }
  }

  void _saveRecurso() async {
    if (!_formKey.currentState!.validate()) return;

    // Lógica compleja: Valido si tiene AL MENOS un video o archivo (nuevo o viejo).
    bool hasVideo =
        _selectedVideo != null ||
        (_existingVideoUrl != null && _existingVideoUrl!.isNotEmpty);
    bool hasFile =
        _selectedFile != null ||
        (_existingFileUrl != null && _existingFileUrl!.isNotEmpty);

    if (!hasVideo && !hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes tener un Video O un Archivo para la cápsula.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Determino qué URL de video guardar (la nueva o la vieja).
      String? videoUrl = _existingVideoUrl;
      if (_selectedVideo != null) {
        videoUrl = await _firebaseService.uploadVideo(_selectedVideo!);
      }

      // Determino qué URL de archivo guardar.
      String? fileUrl = _existingFileUrl;
      String? fileName = _existingFileName;
      if (_selectedFile != null && _selectedFileName != null) {
        fileUrl = await _firebaseService.uploadFile(
          _selectedFile!,
          _selectedFileName!,
        );
        fileName = _selectedFileName;
      }

      final recurso = RecursoModel(
        id: widget.recursoExistente?.id, // Importante: mantengo el ID si edito.
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        autor: _autorController.text.trim(),
        categoria: _selectedCategoria,
        videoUrl: videoUrl,
        archivoUrl: fileUrl,
        archivoNombre: fileName,
      );

      // Decido si llamo a ACTUALIZAR o CREAR.
      if (widget.recursoExistente != null) {
        await _firebaseService.updateRecurso(recurso);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Cápsula actualizada!')),
          );
        }
      } else {
        await _firebaseService.saveRecurso(recurso);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('¡Cápsula creada!')));
        }
      }

      if (mounted) Navigator.of(context).pop();
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
    bool isEditing = widget.recursoExistente != null;

    if (_isUploading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Guardando contenido...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Cambio el título dinámicamente.
        title: Text(isEditing ? 'Editar Cápsula' : 'Nueva Cápsula'),
        backgroundColor: Colors.black,
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
                'Multimedia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // UI Video: Muestra ícono verde si ya hay video (nuevo o viejo).
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Icon(
                  (_selectedVideo != null || _existingVideoUrl != null)
                      ? Icons.check_circle
                      : Icons.video_call,
                  color: (_selectedVideo != null || _existingVideoUrl != null)
                      ? Colors.green
                      : Colors.grey,
                ),
                title: Text(
                  _selectedVideo != null
                      ? 'Nuevo video seleccionado'
                      : (_existingVideoUrl != null
                            ? 'Video actual guardado'
                            : 'Subir Video'),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: _pickVideo,
                ),
                onTap: _pickVideo,
              ),
              const SizedBox(height: 15),

              // UI Archivo
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Icon(
                  (_selectedFile != null || _existingFileUrl != null)
                      ? Icons.check_circle
                      : Icons.attach_file,
                  color: (_selectedFile != null || _existingFileUrl != null)
                      ? Colors.blue
                      : Colors.grey,
                ),
                title: Text(
                  _selectedFile != null
                      ? 'Nuevo archivo seleccionado'
                      : (_existingFileName != null
                            ? '$_existingFileName (Actual)'
                            : 'Adjuntar Archivo'),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: _pickFile,
                ),
                onTap: _pickFile,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveRecurso,
                  // Cambio el icono y texto según si estoy editando o creando.
                  icon: Icon(isEditing ? Icons.save : Icons.cloud_upload),
                  label: Text(isEditing ? 'GUARDAR CAMBIOS' : 'PUBLICAR'),
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
