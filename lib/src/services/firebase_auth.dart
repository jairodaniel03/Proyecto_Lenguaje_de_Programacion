import 'dart:async';

// El tipo 'User' de Firebase Auth. Lo mantenemos para compatibilidad de la API,
// pero no usaremos la implementación real.
// Si da problemas, se puede crear una clase `FakeUser {}`.
import 'package:firebase_auth/firebase_auth.dart' show User;

// --- MODO DE DESARROLLO 100% OFFLINE ---
// TODO: Revertir este archivo a la versión de Firebase cuando el login esté arreglado.

class AuthService {
  // No se crean instancias de servicios de Firebase, eliminando la causa del error.

  /// Devuelve siempre null porque no hay un usuario real en modo offline.
  User? getCurrentUser() {
    return null;
  }

  /// Devuelve un stream que emite un único valor nulo y luego se cierra.
  Stream<User?> get authStateChanges => Stream.value(null);

  /// Simula un inicio de sesión con email, esperando un momento antes de "resolver".
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    print('AuthService (Offline): Simulating email sign-in for $email.');
    await Future.delayed(const Duration(milliseconds: 200));
    return null; // La lógica de la UI no depende del objeto User devuelto.
  }

  /// Simula la creación de un usuario.
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    print('AuthService (Offline): Simulating user creation for $email.');
    await Future.delayed(const Duration(milliseconds: 200));
    return null;
  }

  /// Simula un inicio de sesión con Google.
  Future<User?> signInWithGoogle() async {
    print('AuthService (Offline): Simulating Google sign-in.');
    await Future.delayed(const Duration(milliseconds: 200));
    return null;
  }

  /// Simula el cierre de sesión.
  Future<void> signOut() async {
    print('AuthService (Offline): Simulating sign-out.');
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
