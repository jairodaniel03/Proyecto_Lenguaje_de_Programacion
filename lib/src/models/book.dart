
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String? id;
  final String title;
  final String author;
  final String imageUrl;
  final String status;
  final int totalPages;
  final int pagesRead;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.status,
    required this.totalPages,
    required this.pagesRead,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
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
}
