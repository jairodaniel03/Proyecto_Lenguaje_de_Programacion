import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_lenguaje/src/views/add_book_page.dart';
import 'package:proyecto_lenguaje/src/views/home_page.dart';
import 'package:proyecto_lenguaje/src/views/log_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Descomentar esta línea cuando la configuración de Firebase esté completa.
  // await Firebase.initializeApp(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  GoRouter get _router => GoRouter(
    initialLocation: '/login',
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
