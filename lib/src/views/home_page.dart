import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_lenguaje/src/services/firebase_auth.dart';
import 'package:proyecto_lenguaje/src/services/firestore_service.dart';
import '../models/book.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reto de Lectura'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          )
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: _firestoreService.getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aún no has añadido ningún libro.'));
          }

          final books = snapshot.data!;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                leading: book.imageUrl.isNotEmpty
                    ? Image.network(book.imageUrl, width: 50, fit: BoxFit.cover)
                    : const Icon(Icons.book, size: 50), // Imagen de placeholder
                onTap: () {
                  // Navegar a la pantalla de detalles/seguimiento del libro
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-book'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
