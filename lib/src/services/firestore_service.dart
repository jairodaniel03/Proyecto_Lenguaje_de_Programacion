import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _tempUserId = "temp_user"; // ID de usuario temporal y fijo

  // Obtener la colección de libros de un usuario
  Stream<List<Book>> getBooks() {
    return _db
        .collection('users')
        .doc(_tempUserId)
        .collection('books')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromFirestore(doc))
            .toList());
  }

  // Añadir un libro a la colección del usuario
  Future<void> addBook(Book book) {
    return _db
        .collection('users')
        .doc(_tempUserId)
        .collection('books')
        .add(book.toMap());
  }

  // Actualizar un libro
  Future<void> updateBook(Book book) {
    return _db
        .collection('users')
        .doc(_tempUserId)
        .collection('books')
        .doc(book.id)
        .update(book.toMap());
  }

  // Borrar un libro
  Future<void> deleteBook(String bookId) {
    return _db
        .collection('users')
        .doc(_tempUserId)
        .collection('books')
        .doc(bookId)
        .delete();
  }
}
