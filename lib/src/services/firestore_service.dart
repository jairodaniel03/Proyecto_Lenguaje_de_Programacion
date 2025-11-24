import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

// --- MODO DE DESARROLLO OFFLINE CON PERSISTENCIA LOCAL ---

class FirestoreService {
  static const _localBooksKey = 'local_books_data';

  List<Book> _localBooks = [];
  final _booksController = StreamController<List<Book>>.broadcast();
  late final SharedPreferences _prefs;

  FirestoreService._();

  static Future<FirestoreService> create() async {
    final service = FirestoreService._();
    await service._init();
    return service;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadBooksFromLocal();
  }

  Future<void> _loadBooksFromLocal() async {
    final jsonString = _prefs.getString(_localBooksKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _localBooks = jsonList.map((json) => Book.fromJson(json)).toList();
        _booksController.add(_localBooks); // Notificar a los oyentes con los datos cargados
        debugPrint('Se cargaron ${_localBooks.length} libros del almacenamiento local.');
      } catch (e) {
        debugPrint('Error al cargar o decodificar libros locales: $e');
        _localBooks = [];
      }
    } else {
      // Si no hay datos, asegurarse de que la lista está vacía.
      _localBooks = [];
      _booksController.add(_localBooks);
    }
  }

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

  Stream<List<Book>> getBooks() => _booksController.stream;

  Future<void> addBook(Book book) async {
    // Corregido: Usar los campos del nuevo modelo Book
    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: book.title,
      author: book.author,
      pdfPath: book.pdfPath, // Usar pdfPath en lugar de imageUrl
      totalPages: book.totalPages,
      status: book.status,
      pagesRead: book.pagesRead,
      readingTimeInSeconds: book.readingTimeInSeconds,
    );

    _localBooks.add(newBook);
    _booksController.add(List<Book>.from(_localBooks));
    await _saveBooksToLocal();
  }

  Future<void> updateBook(Book bookToUpdate) async {
    final index = _localBooks.indexWhere((b) => b.id == bookToUpdate.id);
    if (index != -1) {
      _localBooks[index] = bookToUpdate;
      _booksController.add(List<Book>.from(_localBooks));
      await _saveBooksToLocal();
    }
  }
}