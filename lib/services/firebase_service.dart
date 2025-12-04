// Archivo: lib/services/firebase_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/recurso_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final String _collectionName = 'recursos_neuroconecta';
  final String _videoFolder = 'videos_capsulas';
  final String _filesFolder = 'material_complementario'; // Nueva carpeta

  // --- AUTH ---
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error en Google Sign-In: $e");
      return null;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // --- STORAGE & DATABASE ---

  // Subir Video
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

  // NUEVO: Subir Archivo (Word, PDF, etc.)
  Future<String?> uploadFile(File file, String originalName) async {
    try {
      // Usamos el nombre original pero con un timestamp para evitar duplicados
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

  Future<void> saveRecurso(RecursoModel recurso) async {
    await _db.collection(_collectionName).add(recurso.toMap());
  }

  Stream<QuerySnapshot> getRecursos() {
    return _db
        .collection(_collectionName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendFeedback(String feedback, String? userEmail) async {
    await _db.collection('feedback_neuroconecta').add({
      'mensaje': feedback,
      'usuario': userEmail ?? 'Anónimo',
      'fecha': DateTime.now(),
    });
  }

  Future<void> deleteRecurso(String docId) async {
    await _db.collection(_collectionName).doc(docId).delete();
  }
}
