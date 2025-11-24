import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_lenguaje/src/services/firestore_service.dart';
import '../models/book.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirestoreService? _firestoreService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final service = await FirestoreService.create();
    if (mounted) {
      setState(() {
        _firestoreService = service;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Biblioteca'),
        // El botón de logout ya no es necesario en modo offline
      ),
      body: _buildBookList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-book'),
        tooltip: 'Añadir libro',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBookList() {
    if (_firestoreService == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<Book>>(
      stream: _firestoreService!.getBooks(),
      initialData: _firestoreService!.initialBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Aún no tienes libros.\n¡Añade uno para empezar a leer!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final books = snapshot.data!;

        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final progress = (book.totalPages > 0) ? (book.pagesRead / book.totalPages) : 0.0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                // --- Navegación al lector de libros ---
                onTap: () {
                  if (book.pdfPath != null && book.pdfPath!.isNotEmpty) {
                    context.go('/book-reader', extra: book);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Este libro no tiene un PDF asociado.')),
                    );
                  }
                },
                // --- Icono con color según estado ---
                leading: Icon(
                  Icons.book_outlined,
                  color: _getStatusColor(book.status),
                  size: 40,
                ),
                title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.author),
                    const SizedBox(height: 5),
                    // --- Barra de Progreso ---
                    if (book.status != 'Pendiente')
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(book.status)),
                      ),
                  ],
                ),
                trailing: Text('${(progress * 100).toStringAsFixed(0)}%'),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Leído':
        return Colors.green;
      case 'En progreso':
        return Colors.blue;
      default: // Pendiente
        return Colors.grey;
    }
  }
}
