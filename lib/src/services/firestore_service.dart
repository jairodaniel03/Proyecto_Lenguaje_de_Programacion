import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Obtener la colección de libros de un usuario
  Stream<List<Book>> getBooks() {
    final userId = _userId;
    if (userId == null) {
      return Stream.value([]);
    }
    return _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromFirestore(doc))
            .toList());
  }

  // Añadir un libro a la colección del usuario
  Future<void> addBook(Book book) {
    final userId = _userId;
    if (userId == null) {
      return Future.error('Usuario no autenticado.');
    }
    return _db.collection('users').doc(userId).collection('books').add(book.toMap());
  }

  // Actualizar un libro
  Future<void> updateBook(Book book) {
    final userId = _userId;
    if (userId == null) {
      return Future.error('Usuario no autenticado.');
    }
    return _db
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(book.id)
        .update(book.toMap());
  }

  // Borrar un libro
  Future<void> deleteBook(String bookId) {
    final userId = _userId;
    if (userId == null) {
      return Future.error('Usuario no autenticado.');
    }
    return _db.collection('users').doc(userId).collection('books').doc(bookId).delete();
  }
}
