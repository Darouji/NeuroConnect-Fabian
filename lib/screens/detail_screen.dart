// Archivo: lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recurso_model.dart';

class DetailScreen extends StatefulWidget {
  final RecursoModel recurso;

  const DetailScreen({required this.recurso, super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Solo inicializamos si HAY URL de video
    if (widget.recurso.videoUrl != null &&
        widget.recurso.videoUrl!.isNotEmpty) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.recurso.videoUrl!),
      );
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      );
      setState(() => _isVideoInitialized = true);
    } catch (e) {
      debugPrint('Error video: $e');
    }
  }

  Future<void> _openFile() async {
    final String? url = widget.recurso.archivoUrl;
    if (url != null) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el archivo')),
          );
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasVideo =
        widget.recurso.videoUrl != null && widget.recurso.videoUrl!.isNotEmpty;
    bool hasFile =
        widget.recurso.archivoUrl != null &&
        widget.recurso.archivoUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Recurso'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN VIDEO (Solo se muestra si hay video)
            if (hasVideo)
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.black,
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
                            Text(
                              'Cargando video...',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
              )
            else
              // Header alternativo si no hay video (para que no se vea vacío arriba)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                color: Colors.grey[200],
                child: const Icon(Icons.article, size: 80, color: Colors.grey),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recurso.titulo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        'Autor: ${widget.recurso.autor}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  const Text(
                    'Descripción:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.recurso.descripcion,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 30),

                  // BOTÓN DESCARGA
                  if (hasFile)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _openFile,
                        icon: const Icon(
                          Icons.download,
                          color: Colors.blueAccent,
                        ),
                        label: Text(
                          'Descargar Material: ${widget.recurso.archivoNombre ?? "Documento"}',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.blueAccent,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
