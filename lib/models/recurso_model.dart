// Archivo: lib/models/recurso_model.dart

class RecursoModel {
  final String?
  id; // El ID lo genera Firebase, por eso puede ser nulo al crearlo localmente.
  final String titulo;
  final String descripcion;
  final String autor;
  final String?
  videoUrl; // Es opcional, porque ahora permito subir solo archivos.
  final String categoria;

  // Agregué estos campos para soportar PDFs y documentos adjuntos.
  final String? archivoUrl;
  final String? archivoNombre;

  RecursoModel({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.autor,
    this.videoUrl,
    required this.categoria,
    this.archivoUrl,
    this.archivoNombre,
  });

  // Convierto mi objeto a un Mapa (JSON) para poder guardarlo en Firebase.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'autor': autor,
      'videoUrl': videoUrl,
      'categoria': categoria,
      'archivoUrl': archivoUrl,
      'archivoNombre': archivoNombre,
      // Guardo la fecha en formato UTC para evitar problemas de zonas horarias.
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
  }

  // Hago lo contrario: recibo datos de Firebase y los convierto en mi objeto RecursoModel.
  factory RecursoModel.fromMap(Map<String, dynamic> map, String id) {
    return RecursoModel(
      id: id,
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      autor: map['autor'] ?? 'Desconocido',
      videoUrl: map['videoUrl'],
      categoria: map['categoria'] ?? 'General',
      archivoUrl: map['archivoUrl'],
      archivoNombre: map['archivoNombre'],
    );
  }
}
