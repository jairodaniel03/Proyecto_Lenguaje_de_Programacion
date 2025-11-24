import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:proyecto_lenguaje/src/models/book.dart';
import 'package:proyecto_lenguaje/src/services/firestore_service.dart';

class BookReaderPage extends StatefulWidget {
  final Book book;

  const BookReaderPage({super.key, required this.book});

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  FirestoreService? _firestoreService;
  late PDFViewController _pdfController;
  late int _currentPage;
  late int _totalPages;
  bool _isReady = false;

  // Cronómetro
  Timer? _timer;
  late int _elapsedSeconds;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book.pagesRead;
    _totalPages = widget.book.totalPages;
    _elapsedSeconds = widget.book.readingTimeInSeconds;
    
    _initializeService();
    _startTimer();
  }

  Future<void> _initializeService() async {
    _firestoreService = await FirestoreService.create();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveProgress();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    if (_firestoreService == null) return;

    // Actualizar el objeto libro con el nuevo progreso
    widget.book.pagesRead = _currentPage;
    widget.book.totalPages = _totalPages;
    widget.book.readingTimeInSeconds = _elapsedSeconds;

    // Actualizar el estado del libro
    if (_currentPage >= _totalPages -1 && _totalPages > 0) {
        widget.book.status = 'Leído';
    } else if (_currentPage > 0) {
        widget.book.status = 'En progreso';
    }

    await _firestoreService!.updateBook(widget.book);
    print('Progreso guardado!');
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(_formatDuration(_elapsedSeconds), style: const TextStyle(fontSize: 18)),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.book.pdfPath!,
            defaultPage: _currentPage,
            swipeHorizontal: true, // Para la navegación lateral
            pageFling: true, // Permite cambiar de página con un gesto rápido
            onRender: (pages) {
              setState(() {
                _totalPages = pages!;
                _isReady = true;
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
          ),
          if (!_isReady) const Center(child: CircularProgressIndicator()),

          // --- Botones de Navegación Laterales ---
          _buildPageNavigator(),
        ],
      ),
    );
  }

  Widget _buildPageNavigator() {
    return Row(
      children: <Widget>[
        // Zona Izquierda para Retroceder
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_currentPage > 0) {
                _pdfController.setPage(_currentPage - 1);
              }
            },
            child: Container(
              color: Colors.transparent, // Color invisible para detectar toques
              height: double.infinity,
            ),
          ),
        ),
        // Zona Derecha para Avanzar
        Expanded(
          child: GestureDetector(
            onTap: () {
               if (_currentPage < _totalPages - 1) {
                _pdfController.setPage(_currentPage + 1);
              }
            },
            child: Container(
              color: Colors.transparent, 
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}
