import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart'; // Para usar Google Fonts
import 'package:firebase_auth/firebase_auth.dart'; // Para FirebaseAuth
import 'package:nutriflow_app/screens/client_management_screen.dart';
import 'package:nutriflow_app/screens/registro_screen.dart';
import 'package:nutriflow_app/user_data.dart';
import 'forgot_password_page.dart';
import 'normal_screen.dart'; // Navegamos aquí tras un login correcto

// Configuración de GoogleSignIn (ejemplo)
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>['email'],
);

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores de email y contraseña
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Mensajes de error en rojo si la validación falla
  String? _emailError;
  String? _passwordError;

  bool _isLoading = false;
  bool _isPasswordHidden = true; // Controla la visibilidad en el TextField

  // Función de login con email/contraseña
  Future<void> _loginWithEmail() async {
    // Limpiamos posibles errores antes de validar
    setState(() {
      _emailError = null;
      _passwordError = null;
      _isLoading = true;
    });

    // Obtenemos lo que el usuario escribió
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    // ---------- VALIDACIÓN DEL EMAIL ----------
    if (!email.contains('@')) {
      setState(() {
        _emailError = 'El correo debe contener "@"';
        _isLoading = false;
      });
      return;
    }

    // ---------- VALIDACIÓN DE CONTRASEÑA ----------
    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    final bool hasDigit = password.contains(RegExp(r'\d'));
    final bool hasMinLength = password.length >= 8;

    if (!hasUppercase || !hasLowercase || !hasDigit || !hasMinLength) {
      setState(() {
        _passwordError = 'La contraseña debe incluir:\n'
            '- Min 1 mayúscula\n'
            '- Min 1 minúscula\n'
            '- Min 1 dígito\n'
            '- Min 8 caracteres';
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() => _isLoading = false);

      // Navegamos a la pantalla normal
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdministrarClientesScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'user-not-found') {
          _emailError = 'No existe un usuario con ese correo.';
        } else if (e.code == 'wrong-password') {
          _passwordError = 'Contraseña incorrecta.';
        } else {
          _passwordError =
              'Error al iniciar sesión: Las credenciales son incorrectas.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _passwordError = 'Ocurrió un error inesperado: $e';
      });
    }
  }

  // Función de login con Google (ahora sí vinculado con Firebase)
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // Iniciar GoogleSignIn
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        debugPrint('Inicio de sesión con Google cancelado por el usuario');
        setState(() => _isLoading = false);
        return;
      }

      //Obtenemos las credenciales de autenticación (tokens)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      //Creamos las credenciales para Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciamos sesión en Firebase con las credenciales de Google
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Muestro en consola el UID para verificar que está registrado
      final User? user = userCredential.user;
      debugPrint('Usuario de Google logueado con UID: ${user?.uid}');

      setState(() => _isLoading = false);

      // Para la demo, navegamos a NormalScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NormalScreen()),
      );
    } catch (e) {
      debugPrint('Error al iniciar sesión con Google: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores base (verdes) para la UI
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color buttonGreen = Color(0xFF43A047);

    return Scaffold(
      appBar: AppBar(
        // Elevación y estilo del AppBar
        elevation: 0,
        backgroundColor: primaryGreen,
        centerTitle: true,
        title: Text(
          'NutriFlow',
          style: GoogleFonts.pacifico(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        // Fondo con gradiente
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Contenido con scroll
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Imagen/Logo centrado con forma circular y sombra
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                            'assets/dieta.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título
                  Text(
                    'Inicio de sesión',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtítulo
                  Text(
                    'Bienvenido(a) a NutriFlow',
                    style: GoogleFonts.roboto(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ------------------- EMAIL -------------------
                  if (_emailError != null) ...[
                    Text(
                      _emailError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Ej: usuario@gmail.com',
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        prefixIcon: const Icon(Icons.email, color: Colors.green),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ------------------- CONTRASEÑA -------------------
                  // Error en rojo si lo hay
                  if (_passwordError != null) ...[
                    Text(
                      _passwordError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Campo de texto para contraseña
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _isPasswordHidden,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Tu contraseña',
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        prefixIcon: const Icon(Icons.lock, color: Colors.green),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordHidden
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordHidden = !_isPasswordHidden;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ¿Olvidaste la contraseña?
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navegar a "Olvidé mi contraseña"
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        '¿Olvidaste la contraseña?',
                        style: GoogleFonts.roboto(
                          color: primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón: Inicia Sesión
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Iniciar Sesión',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Separador
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'O',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botón: Continuar con Google
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: _isLoading ? null : _loginWithGoogle,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      label: Text(
                        'Continuar con Google',
                        style: GoogleFonts.roboto(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ---------------- BOTÓN NAVEGACIÓN REGISTRO----------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navegar a tu pantalla de registro
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Indicador de carga si _isLoading == true
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
