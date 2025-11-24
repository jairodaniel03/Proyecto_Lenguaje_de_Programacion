import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_lenguaje/src/models/book.dart';
import 'package:proyecto_lenguaje/src/services/firestore_service.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _totalPagesController = TextEditingController();

  // El servicio se inicializa de forma asíncrona
  FirestoreService? _firestoreService;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Usamos el factory constructor para obtener la instancia inicializada
    final service = await FirestoreService.create();
    setState(() {
      _firestoreService = service;
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _imageUrlController.dispose();
    _totalPagesController.dispose();
    super.dispose();
  }

  Future<void> _addBook() async {
    if (_formKey.currentState!.validate()) {
      // Asegurarse de que el servicio está inicializado antes de usarlo
      if (_firestoreService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El servicio aún no está listo. Intente de nuevo.')),
        );
        return;
      }

      final newBook = Book(
        title: _titleController.text,
        author: _authorController.text,
        imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
        totalPages: int.tryParse(_totalPagesController.text) ?? 0,
        status: 'Pendiente', // Estado inicial por defecto
        pagesRead: 0,
      );

      await _firestoreService!.addBook(newBook);

      if (mounted) {
        // Regresar a la página anterior después de añadir el libro
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar un loader mientras se inicializa el servicio
    if (_isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nuevo Libro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el autor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de la Portada (Opcional)'),
                // Sin validador para que sea opcional
              ),
              TextFormField(
                controller: _totalPagesController,
                decoration: const InputDecoration(labelText: 'Número de Páginas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el número de páginas';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addBook,
                child: const Text('Añadir Libro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
