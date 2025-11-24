import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

// --- MODO DE DESARROLLO OFFLINE CON PERSISTENCIA LOCAL ---
// TODO: Revertir este archivo a la versión de Firebase una vez que el login esté arreglado.

class FirestoreService {
  static const _localBooksKey = 'local_books_data';

  List<Book> _localBooks = [];
  final _booksController = StreamController<List<Book>>.broadcast();
  late final SharedPreferences _prefs;

  // El constructor ahora es privado para controlar la inicialización asíncrona
  FirestoreService._();

  /// Método de fábrica estático para crear e inicializar la instancia del servicio
  static Future<FirestoreService> create() async {
    final service = FirestoreService._();
    await service._init();
    return service;
  }

  /// Inicializa el servicio cargando los libros desde el almacenamiento local
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadBooksFromLocal();
    // Emitir la lista inicial después de cargarla
    _booksController.add(List<Book>.from(_localBooks));
  }

  /// Carga la lista de libros desde SharedPreferences
  Future<void> _loadBooksFromLocal() async {
    final jsonString = _prefs.getString(_localBooksKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _localBooks = jsonList.map((json) => Book.fromJson(json)).toList();
        debugPrint('Se cargaron ${_localBooks.length} libros desde el almacenamiento local.');
      } catch (e) {
        debugPrint('Error al decodificar libros locales: $e');
        _localBooks = [];
      }
    } else {
      debugPrint('No se encontraron libros en el almacenamiento local.');
    }
  }

  /// Guarda la lista actual de libros en SharedPreferences
  Future<void> _saveBooksToLocal() async {
    try {
      final List<Map<String, dynamic>> jsonList = _localBooks.map((book) => book.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_localBooksKey, jsonString);
      debugPrint('Se guardaron ${_localBooks.length} libros en el almacenamiento local.');
    } catch (e) {
      debugPrint('Error al guardar libros locales: $e');
    }
  }

  /// Stream que emite la lista de libros cada vez que cambia.
  Stream<List<Book>> getBooks() => _booksController.stream;

  /// Añade un libro, lo guarda localmente y notifica a los oyentes.
  Future<void> addBook(Book book) async {
    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: book.title,
      author: book.author,
      imageUrl: book.imageUrl,
      totalPages: book.totalPages,
      status: book.status,
      pagesRead: book.pagesRead,
    );

    _localBooks.add(newBook);
    _booksController.add(List<Book>.from(_localBooks));
    await _saveBooksToLocal(); // Guardar cambios
  }

  /// Actualiza un libro, lo guarda localmente y notifica a los oyentes.
  Future<void> updateBook(Book book) async {
    final index = _localBooks.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _localBooks[index] = book;
      _booksController.add(List<Book>.from(_localBooks));
      await _saveBooksToLocal(); // Guardar cambios
    }
  }

  /// Borra un libro, lo guarda localmente y notifica a los oyentes.
  Future<void> deleteBook(String bookId) async {
    _localBooks.removeWhere((b) => b.id == bookId);
    _booksController.add(List<Book>.from(_localBooks));
    await _saveBooksToLocal(); // Guardar cambios
  }
}
