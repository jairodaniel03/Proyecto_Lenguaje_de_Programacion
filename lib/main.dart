import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_lenguaje/src/models/book.dart';
import 'package:proyecto_lenguaje/src/views/add_book_page.dart';
import 'package:proyecto_lenguaje/src/views/home_page.dart';
import 'package:proyecto_lenguaje/src/views/log_in.dart';
import 'package:proyecto_lenguaje/src/views/book_reader_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Se mantiene comentado para el modo 100% offline
  // await Firebase.initializeApp(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  GoRouter get _router => GoRouter(
    initialLocation: '/login', // La pantalla de login ahora es 100% falsa
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/add-book',
        name: 'add-book',
        builder: (context, state) => const AddBookPage(),
      ),
      // --- Nueva Ruta para el Lector de Libros ---
      GoRoute(
        path: '/book-reader',
        name: 'book-reader',
        builder: (context, state) {
          // Recibimos el objeto 'Book' completo
          final book = state.extra as Book; 
          return BookReaderPage(book: book);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Reto Lectura',
      routerConfig: _router,
    );
  }
}
