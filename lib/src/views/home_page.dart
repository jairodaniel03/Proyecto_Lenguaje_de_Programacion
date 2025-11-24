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
  // El servicio ahora necesita ser inicializado, por lo que no puede ser final
  FirestoreService? _firestoreService;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Inicializar el servicio y suscribirse a los cambios
    _initializeService();
  }

  Future<void> _initializeService() async {
    final service = await FirestoreService.create();
    setState(() {
      _firestoreService = service;
    });
  }

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
        title: const Text('Reto de 12 Libros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _buildBookList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-book'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBookList() {
    // Mostrar un loader mientras el servicio se inicializa
    if (_firestoreService == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<Book>>(
      stream: _firestoreService!.getBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          // El stream está esperando datos iniciales
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar libros: ${snapshot.error}'));
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
              leading: (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                  ? Image.network(book.imageUrl!, width: 50, fit: BoxFit.cover)
                  : const Icon(Icons.book, size: 50), // Ícono de reemplazo
              onTap: () {
                // Próximamente: Navegar a la pantalla de seguimiento del libro
              },
            );
          },
        );
      },
    );
  }
}
