// Archivo: lib/models/recurso_model.dart

// Clase que representa un Recurso dentro de Neuroconecta.
class RecursoModel {
  // El ID es opcional al crear localmente, pero Firestore lo asignará.
  final String? id;
  final String titulo;
  final String descripcion;
  final String autor;
  // Campo nuevo: URL del video almacenado en Firebase Storage.
  // Puede ser nulo si el recurso es solo texto/imagen.
  final String? videoUrl;

  // Constructor del modelo.
  RecursoModel({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.autor,
    this.videoUrl,
  });

  // Método para convertir el objeto Dart a un mapa (JSON) para Firestore.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'autor': autor,
      'videoUrl': videoUrl, // Guardamos el link del video.
      'timestamp': DateTime.now()
          .toUtc()
          .toIso8601String(), // Registro de cuándo se guardó.
    };
  }

  // Constructor de fábrica para crear un objeto Dart desde un documento de Firestore.
  factory RecursoModel.fromMap(Map<String, dynamic> map, String id) {
    return RecursoModel(
      id: id, // El ID viene del documento, no del mapa de datos.
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      autor: map['autor'] ?? 'Desconocido',
      videoUrl: map['videoUrl'], // Recuperamos el link del video si existe.
    );
  }
}
