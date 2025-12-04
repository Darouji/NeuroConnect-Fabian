// Archivo: lib/services/firebase_service.dart

import 'dart:io'; // Para manejar archivos físicos (File).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Importo el modelo de datos actualizado.
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
      // Iniciamos el flujo de Google.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Si el usuario cancela el diálogo, retornamos null.
      if (googleUser == null) return null;

      // Obtenemos los detalles de autenticación de la solicitud.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Creamos una credencial nueva para Firebase.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Usamos esa credencial para iniciar sesión en Firebase.
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Propagamos el error para manejarlo en la pantalla de Login.
      rethrow;
    }
  }

  // Cerrar sesión (Actualizado para corregir el error de re-login).
  Future<void> signOut() async {
    try {
      // Intentamos desconectar completamente la cuenta de Google del dispositivo.
      // Esto limpia el caché nativo y evita errores al intentar volver a entrar.
      await _googleSignIn.disconnect();
    } catch (e) {
      // Si no había sesión de Google activa, esto puede fallar, pero no afecta el flujo.
      print(
        "Nota: No se pudo desconectar Google (posiblemente no había sesión): $e",
      );
    }

    // Finalmente cerramos la sesión en el plugin de Google y en Firebase Auth.
    await _googleSignIn.signOut();
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
      // Genero un nombre único usando la fecha actual en milisegundos.
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Creo la referencia (ruta) donde se guardará el archivo: videos_capsulas/nombre.mp4
      Reference ref = _storage.ref().child('$_storageFolderName/$fileName.mp4');

      // Inicio la tarea de subida.
      UploadTask uploadTask = ref.putFile(videoFile);

      // Espero a que la subida se complete.
      TaskSnapshot snapshot = await uploadTask;

      // Obtengo la URL pública para descargar/ver el video.
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

  // Eliminar un recurso por su ID.
  Future<void> deleteRecurso(String docId) async {
    await _db.collection(_collectionName).doc(docId).delete();
  }
}
