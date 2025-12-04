// Archivo: lib/models/recurso_model.dart

// Clase que representa un Recurso dentro de Neuroconecta.
class RecursoModel {
  // El ID será opcional, ya que Firestore lo asigna al crear.
  final String? id;
  final String titulo;
  final String descripcion;
  final String autor;

  // Constructor de mi modelo.
  RecursoModel({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.autor,
  });

  // Método para convertir el objeto Dart a un mapa para guardarlo en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'autor': autor,
      'timestamp': DateTime.now()
          .toUtc()
          .toIso8601String(), // Registro de cuándo se guardó.
    };
  }

  // Constructor de fábrica para crear un objeto Dart a partir de un mapa de Firestore.
  factory RecursoModel.fromMap(Map<String, dynamic> map, String id) {
    return RecursoModel(
      id: id, // El ID se toma del DocumentSnapshot.
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      autor: map['autor'] ?? 'Desconocido',
    );
  }
}
