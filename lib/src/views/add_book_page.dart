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

  String _status = 'Pendiente';

  @override
  Widget build(BuildContext context) {
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
                validator: (value) => value!.isEmpty ? 'El título es obligatorio' : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (value) => value!.isEmpty ? 'El autor es obligatorio' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de la Portada'),
                validator: (value) => value!.isEmpty ? 'La URL de la portada es obligatoria' : null,
              ),
              TextFormField(
                controller: _totalPagesController,
                decoration: const InputDecoration(labelText: 'Páginas Totales'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'El número de páginas es obligatorio' : null,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: ['Pendiente', 'En progreso', 'Finalizado'].map((label) => DropdownMenuItem(
                  value: label,
                  child: Text(label),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addBook,
                child: const Text('Guardar Libro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addBook() async {
    if (_formKey.currentState!.validate()) {
      final newBook = Book(
        title: _titleController.text,
        author: _authorController.text,
        imageUrl: _imageUrlController.text,
        totalPages: int.parse(_totalPagesController.text),
        status: _status,
        pagesRead: 0, // Por defecto, al añadir un libro no se ha leído ninguna página
      );

      await FirestoreService().addBook(newBook);
      context.pop();
    }
  }
}
