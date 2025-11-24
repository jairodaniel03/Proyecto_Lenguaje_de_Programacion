import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // El usuario canceló el flujo de inicio de sesión
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crea una credencial de Firebase con el token de Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión en Firebase con la credencial
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      print('Error de FirebaseAuth: ${e.message}');
      return null;
    } catch (e) {
      print('Ocurrió un error durante el inicio de sesión con Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
