import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_lenguaje/src/services/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- NAVEGACIÓN EXITOSA ---
  void _navigateToHome() {
    // Usamos `context.go` para reemplazar la pila de navegación y evitar volver al login
    if (mounted) context.go('/');
  }

  // --- INICIO DE SESIÓN LOCAL ---
  Future<void> _signInWithEmail() async {
    // Validar que los campos del formulario no estén vacíos
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simular llamada al servicio
    await _authService.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );
    
    // En nuestro modo de desarrollo, siempre navegamos a home
    _navigateToHome();

    // La gestión de errores se añadirá cuando Firebase esté conectado
    if (mounted) setState(() => _isLoading = false);
  }

  // --- INICIO DE SESIÓN CON GOOGLE ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    await _authService.signInWithGoogle();
    _navigateToHome();
    if (mounted) setState(() => _isLoading = false);
  }

  // --- REGISTRO ---
  Future<void> _register() async {
    // En un futuro, esto podría llevar a una pantalla de registro separada
    // Por ahora, simplemente simula un inicio de sesión
    setState(() => _isLoading = true);
    print("Navegando a la creación de cuenta (simulado)");
    // Simular una llamada de registro
    await _authService.createUserWithEmailAndPassword("simulated@user.com", "password");
    _navigateToHome();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.brown))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildInfoCard("Cada página te acerca a tu meta", Icons.book),
                      const SizedBox(height: 15),
                      _buildInfoCard("Registra tu avance fácilmente", Icons.checklist),
                      const SizedBox(height: 40),
                      _buildEmailField(),
                      const SizedBox(height: 15),
                      _buildPasswordField(),
                      const SizedBox(height: 25),
                      _buildLoginButton(),
                      const SizedBox(height: 20),
                      _buildGoogleSignInButton(),
                      const SizedBox(height: 20),
                      _buildRegisterButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA MAYOR CLARIDAD ---

  Widget _buildHeader() => Column(
        children: const [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories, size: 50, color: Colors.brown),
              SizedBox(width: 10),
              Text(
                "Reto Lectura",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "¿ACEPTAS EL DESAFÍO?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.brown,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Login",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.brown,
            ),
          ),
        ],
      );

  Widget _buildInfoCard(String text, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.brown.shade50,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.brown, size: 20),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16, color: Colors.brown)),
          ],
        ),
      );

  Widget _buildEmailField() => TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: "Email",
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Por favor, ingresa tu email' : null,
      );

  Widget _buildPasswordField() => TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: "Contraseña",
          prefixIcon: Icon(Icons.lock),
          border: OutlineInputBorder(),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Por favor, ingresa tu contraseña' : null,
      );

  Widget _buildLoginButton() => ElevatedButton(
        onPressed: _signInWithEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Ingresar",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );

  Widget _buildGoogleSignInButton() => GestureDetector(
        onTap: _signInWithGoogle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.brown.shade50,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.g_mobiledata, color: Colors.brown, size: 28),
              SizedBox(width: 12),
              Text(
                "Ingresa con Google",
                style: TextStyle(fontSize: 16, color: Colors.brown, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );

  Widget _buildRegisterButton() => TextButton(
        onPressed: _register,
        child: const Text(
          "¿Eres nuevo? ¡Regístrate ya!",
          style: TextStyle(
            fontSize: 15,
            color: Colors.brown,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}
