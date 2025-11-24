import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String? id;
  final String title;
  final String author;
  final String? imageUrl;
  final String status;
  final int totalPages;
  final int pagesRead;

  Book({
    this.id,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.status,
    required this.totalPages,
    required this.pagesRead,
  });

  // --- Métodos para Firestore ---

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      imageUrl: data['imageUrl'],
      status: data['status'] ?? 'Pendiente',
      totalPages: data['totalPages'] ?? 0,
      pagesRead: data['pagesRead'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'status': status,
      'totalPages': totalPages,
      'pagesRead': pagesRead,
    };
  }

  // --- Métodos para Almacenamiento Local (JSON) ---

  /// Crea un libro desde un mapa (usualmente de JSON)
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String?,
      title: json['title'] as String,
      author: json['author'] as String,
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String,
      totalPages: json['totalPages'] as int,
      pagesRead: json['pagesRead'] as int,
    );
  }

  /// Convierte el libro a un mapa (para luego convertirlo a JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'status': status,
      'totalPages': totalPages,
      'pagesRead': pagesRead,
    };
  }
}
