// Archivo: lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/recurso_model.dart';

class DetailScreen extends StatefulWidget {
  // Recibimos el objeto completo en lugar de solo el ID.
  final RecursoModel recurso;

  const DetailScreen({required this.recurso, super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Controladores para el video.
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Estado de carga del video.
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Si el recurso tiene una URL de video, inicializamos el reproductor.
    if (widget.recurso.videoUrl != null &&
        widget.recurso.videoUrl!.isNotEmpty) {
      _initializePlayer();
    }
  }

  // Configuración asíncrona del reproductor de video.
  Future<void> _initializePlayer() async {
    try {
      // 1. Configuramos el controlador base con la URL de la red.
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.recurso.videoUrl!),
      );

      // 2. Inicializamos la conexión.
      await _videoPlayerController!.initialize();

      // 3. Configuramos Chewie (la interfaz gráfica con controles).
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, errorMessage) {
          return Center(child: Text('Error al cargar video: $errorMessage'));
        },
      );

      // 4. Actualizamos la interfaz para mostrar el video.
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      print('Error inicializando video: $e');
    }
  }

  @override
  void dispose() {
    // Es CRÍTICO liberar los recursos de video al salir de la pantalla.
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle de Cápsula'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN DE VIDEO ---
            Container(
              width: double.infinity,
              height: 250, // Altura fija para el área del video.
              color: Colors.black, // Fondo negro estilo cine.
              child: _isVideoInitialized && _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: Colors.white54,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Cargando video o video no disponible',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
            ),

            // --- SECCIÓN DE INFORMACIÓN ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título principal.
                  Text(
                    widget.recurso.titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Autor y Fecha (usamos un icono para decorar).
                  Row(
                    children: [
                      const Icon(Icons.person_pin, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Autor: ${widget.recurso.autor}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),

                  // Descripción.
                  const Text(
                    'Descripción de la actividad:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.recurso.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      height:
                          1.5, // Mayor altura de línea para mejor legibilidad.
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
