import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
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

  // Para manejar el archivo seleccionado
  String? _pickedFilePath;
  String? _pickedFileName;

  FirestoreService? _firestoreService;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
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
    super.dispose();
  }

  Future<void> _pickPdf() async {
    // Usamos el paquete file_picker para seleccionar solo archivos PDF
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pickedFilePath = result.files.single.path;
        _pickedFileName = result.files.single.name;
      });
    } else {
      // El usuario canceló la selección
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ningún archivo.')),
      );
    }
  }

  Future<void> _addBook() async {
    // Validar el formulario y que se haya seleccionado un archivo
    if (_formKey.currentState!.validate()) {
      if (_pickedFilePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleccione un archivo PDF.')),
        );
        return;
      }

      if (_firestoreService == null) return; // Salir si el servicio no está listo

      final newBook = Book(
          title: _titleController.text,
          author: _authorController.text,
          pdfPath: _pickedFilePath,
          status: 'Pendiente',
          pagesRead: 0,
          totalPages: 0,
          readingTimeInSeconds: 0
          // totalPages se calculará cuando se abra el libro por primera vez
          );

      await _firestoreService!.addBook(newBook);

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: const InputDecoration(labelText: 'Título del Libro'),
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese un título' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Autor del Libro'),
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese un autor' : null,
              ),
              const SizedBox(height: 30),
              
              // --- Botón y texto para seleccionar PDF ---
              OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Seleccionar PDF'),
                onPressed: _pickPdf,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 15),
              if (_pickedFileName != null)
                Center(
                  child: Text(
                    'Archivo: $_pickedFileName',
                    style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _addBook,
                child: const Text('Añadir Libro'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
