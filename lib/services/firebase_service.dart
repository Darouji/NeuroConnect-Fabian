// Archivo: lib/services/firebase_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/recurso_model.dart';

class FirebaseService {
  // Instancias principales de las herramientas de Firebase.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Defino aquí los nombres de mis colecciones y carpetas para no equivocarme al escribirlas.
  final String _collectionName = 'recursos_neuroconecta';
  final String _videoFolder = 'videos_capsulas';
  final String _filesFolder = 'material_complementario';

  // --- SECCIÓN DE AUTENTICACIÓN ---

  // Lógica para iniciar sesión con Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Inicia el flujo interactivo de Google.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // El usuario canceló.

      // 2. Obtiene los tokens de autenticación.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Crea una credencial para Firebase.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Inicia sesión en Firebase con esa credencial.
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error en Google Sign-In: $e");
      return null;
    }
  }

  // Inicio de sesión tradicional con correo y contraseña.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Registro de usuarios nuevos.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Cerrar sesión en ambos proveedores (Google y Firebase).
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Helper para saber quién está logueado actualmente.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // --- SECCIÓN DE STORAGE Y BASE DE DATOS ---

  // Subo el video y devuelvo la URL pública para guardarla después.
  Future<String?> uploadVideo(File videoFile) async {
    try {
      String fileName = 'vid_${DateTime.now().millisecondsSinceEpoch}.mp4';
      Reference ref = _storage.ref().child('$_videoFolder/$fileName');
      SettableMetadata metadata = SettableMetadata(contentType: 'video/mp4');
      UploadTask uploadTask = ref.putFile(videoFile, metadata);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error subiendo video: $e");
      return null;
    }
  }

  // Función similar para subir PDFs o Docs.
  Future<String?> uploadFile(File file, String originalName) async {
    try {
      String uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_$originalName';
      Reference ref = _storage.ref().child('$_filesFolder/$uniqueName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error subiendo archivo: $e");
      return null;
    }
  }

  // Crea un nuevo registro en Firestore.
  Future<void> saveRecurso(RecursoModel recurso) async {
    await _db.collection(_collectionName).add(recurso.toMap());
  }

  // Actualiza un registro existente (necesito el ID).
  Future<void> updateRecurso(RecursoModel recurso) async {
    if (recurso.id == null) return;
    await _db
        .collection(_collectionName)
        .doc(recurso.id)
        .update(recurso.toMap());
  }

  // Escucha en tiempo real los cambios en la colección para actualizar la lista automáticamente.
  Stream<QuerySnapshot> getRecursos() {
    return _db
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Guardo sugerencias de los usuarios en una colección aparte.
  Future<void> sendFeedback(String feedback, String? userEmail) async {
    await _db.collection('feedback_neuroconecta').add({
      'mensaje': feedback,
      'usuario': userEmail ?? 'Anónimo',
      'fecha': DateTime.now(),
    });
  }

  // Borra físicamente el documento de la base de datos.
  Future<void> deleteRecurso(String docId) async {
    await _db.collection(_collectionName).doc(docId).delete();
  }
}
