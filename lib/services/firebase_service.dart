import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recurso_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String _collectionName = 'recursos_neuroconecta';
  final String _storageFolderName = 'videos_capsulas';

  // --- AUTH (Solo Correo) ---
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

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // --- STORAGE & DATABASE ---
  Future<String?> uploadVideo(File videoFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('$_storageFolderName/$fileName.mp4');
      SettableMetadata metadata = SettableMetadata(contentType: 'video/mp4');
      UploadTask uploadTask = ref.putFile(videoFile, metadata);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error subiendo video: $e");
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

  Future<void> deleteRecurso(String docId) async {
    await _db.collection(_collectionName).doc(docId).delete();
  }
}
