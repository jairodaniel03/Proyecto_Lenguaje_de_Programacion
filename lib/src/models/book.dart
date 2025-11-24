import 'dart:convert';

class Book {
  final String? id;
  final String title;
  final String author;
  final String? pdfPath; // Ruta al archivo PDF local
  String status; // No es final para poder actualizarlo
  int totalPages; // No es final para poder asignarlo después
  int pagesRead;
  int readingTimeInSeconds; // Tiempo de lectura en segundos

  Book({
    this.id,
    required this.title,
    required this.author,
    this.pdfPath,
    this.status = 'Pendiente',
    this.totalPages = 0,
    this.pagesRead = 0,
    this.readingTimeInSeconds = 0,
  });

  // --- Métodos para Almacenamiento Local (JSON) ---

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String?,
      title: json['title'] as String,
      author: json['author'] as String,
      pdfPath: json['pdfPath'] as String?,
      status: json['status'] as String? ?? 'Pendiente',
      totalPages: json['totalPages'] as int? ?? 0,
      pagesRead: json['pagesRead'] as int? ?? 0,
      readingTimeInSeconds: json['readingTimeInSeconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'pdfPath': pdfPath,
      'status': status,
      'totalPages': totalPages,
      'pagesRead': pagesRead,
      'readingTimeInSeconds': readingTimeInSeconds,
    };
  }
}
