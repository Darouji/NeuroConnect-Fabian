// Archivo: lib/models/recurso_model.dart

class RecursoModel {
  final String? id;
  final String titulo;
  final String descripcion;
  final String autor;
  final String? videoUrl;
  final String categoria;
  // NUEVOS CAMPOS PARA ARCHIVOS
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

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'autor': autor,
      'videoUrl': videoUrl,
      'categoria': categoria,
      'archivoUrl': archivoUrl,
      'archivoNombre': archivoNombre,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
  }

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
