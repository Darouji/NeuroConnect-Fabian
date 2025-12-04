// Archivo: lib/services/firebase_service.dart

import 'dart:io'; // Para manejar archivos físicos (File).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/recurso_model.dart';

class FirebaseService {
  // Instancias principales de los servicios de Firebase.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Constantes para nombres de carpetas y colecciones.
  final String _collectionName = 'recursos_neuroconecta';
  final String _storageFolderName = 'videos_capsulas';

  // --- MÉTODOS DE AUTENTICACIÓN ---

  // Registrar usuario con Email/Password.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Iniciar sesión con Email/Password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Iniciar sesión con Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Iniciamos el flujo interactivo de Google.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Si el usuario cancela el diálogo, retornamos null.
      if (googleUser == null) return null;

      // 2. Obtenemos los detalles de autenticación (tokens).
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Creamos una credencial nueva para Firebase con esos tokens.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciamos sesión en Firebase usando la credencial.
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Propagamos el error para manejarlo en la UI.
      rethrow;
    }
  }

  // Cerrar sesión (Corregido para evitar errores de re-login).
  Future<void> signOut() async {
    try {
      // Intentamos desconectar la cuenta de Google si existe una sesión activa.
      // El 'disconnect' es clave para que al volver a dar click, pida cuenta de nuevo.
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
    } catch (e) {
      // Si falla la desconexión de Google (ej: porque entró con email), seguimos.
      print("Nota: Error no crítico al desconectar Google: $e");
    }

    // Aseguramos cerrar la sesión en el plugin de GoogleSignIn.
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print("Error al hacer signOut de Google: $e");
    }

    // Finalmente cerramos la sesión principal de Firebase.
    await _auth.signOut();
  }

  // Obtener usuario actual.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // --- MÉTODOS DE ALMACENAMIENTO (STORAGE) ---

  // Sube un archivo de video y devuelve la URL de descarga.
  Future<String?> uploadVideo(File videoFile) async {
    try {
      // Genero un nombre único usando la fecha actual.
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Creo la referencia (ruta) donde se guardará el archivo.
      Reference ref = _storage.ref().child('$_storageFolderName/$fileName.mp4');

      // Configuro metadatos para asegurar que se trate como video mp4.
      SettableMetadata metadata = SettableMetadata(contentType: 'video/mp4');

      // Inicio la tarea de subida con los metadatos.
      UploadTask uploadTask = ref.putFile(videoFile, metadata);

      // Espero a que la subida se complete.
      TaskSnapshot snapshot = await uploadTask;

      // Obtengo la URL pública.
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error subiendo video: $e");
      return null;
    }
  }

  // --- MÉTODOS DE BASE DE DATOS (FIRESTORE CRUD) ---

  // Guardar un nuevo recurso en la base de datos.
  Future<void> saveRecurso(RecursoModel recurso) async {
    await _db.collection(_collectionName).add(recurso.toMap());
  }

  // Obtener la lista de recursos en tiempo real (Stream).
  Stream<QuerySnapshot> getRecursos() {
    // Ordenamos por fecha para ver los más recientes primero.
    return _db
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Eliminar un recurso por su ID (Solo admin debería usar esto, pero lo dejamos en el servicio).
  Future<void> deleteRecurso(String docId) async {
    await _db.collection(_collectionName).doc(docId).delete();
  }
}
