// Archivo: lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Clase que maneja todas las interacciones con Firebase.
class FirebaseService {
  // Instancias de Firebase que necesito.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Instancia para el inicio de sesión con Google.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Colección donde se guardarán mis recursos en Firestore.
  final String _collectionName = 'recursos_neuroconecta';

  // --- Lógica de Autenticación por CORREO y CONTRASEÑA ---

  // Método 1: REGISTRAR nuevo usuario con correo y contraseña.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    // Uso el método de Firebase Auth para crear un usuario.
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Método 2: INICIAR SESIÓN con correo y contraseña.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    // Uso el método de Firebase Auth para iniciar sesión.
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // --- Lógica de Autenticación por GOOGLE (YA ESTABA) ---

  // Método para iniciar sesión con Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Método para cerrar la sesión actual.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Método para obtener el usuario actual.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // --- Lógica de CRUD (no se modifica) ---
  // ... (saveRecurso, getRecursos, deleteRecurso, etc.)
}
