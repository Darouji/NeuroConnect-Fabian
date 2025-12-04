// Archivo: lib/services/firebase_service.dart

import 'dart:io'; // Necesario para manejar archivos físicos del dispositivo.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/recurso_model.dart'; // Importo mi modelo de datos.

// Clase que maneja todas las interacciones con Firebase (Auth, Database, Storage).
class FirebaseService {
  // Instancias de Firebase.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Nombre de la colección en Firestore y la carpeta en Storage.
  final String _collectionName = 'recursos_neuroconecta';
  final String _storageFolderName = 'videos_capsulas';

  // --- Lógica de Autenticación (Existente) ---

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // --- Nueva Lógica de Almacenamiento (Storage) ---

  // Método para subir el archivo de video a Firebase Storage.
  // Retorna la URL de descarga pública del video.
  Future<String?> uploadVideo(File videoFile) async {
    try {
      // Creo un nombre único para el archivo basado en la fecha actual.
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Creo la referencia dentro de la carpeta 'videos_capsulas'.
      Reference ref = _storage.ref().child('$_storageFolderName/$fileName.mp4');

      // Subo el archivo.
      UploadTask uploadTask = ref.putFile(videoFile);

      // Espero a que termine la subida.
      TaskSnapshot snapshot = await uploadTask;

      // Obtengo la URL de descarga.
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Si falla, retorno null o podría lanzar una excepción.
      print('Error al subir video: $e');
      return null;
    }
  }

  // --- Lógica de Base de Datos (CRUD Firestore) ---

  // Método para guardar un nuevo recurso (con o sin video).
  Future<void> saveRecurso(RecursoModel recurso) async {
    // Añado el documento a la colección. Firestore genera el ID automáticamente.
    await _db.collection(_collectionName).add(recurso.toMap());
  }

  // Método para obtener el flujo de datos (Stream) de los recursos.
  // Esto permite que la app se actualice en tiempo real si hay cambios.
  Stream<QuerySnapshot> getRecursos() {
    // Ordeno por fecha de creación descendente (lo más nuevo primero).
    return _db
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Método para eliminar un recurso.
  Future<void> deleteRecurso(String docId) async {
    await _db.collection(_collectionName).doc(docId).delete();
  }
}
