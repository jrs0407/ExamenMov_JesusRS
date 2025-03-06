import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutriflow_app/screens/cuestionario_screens/genero_screen.dart';
import 'package:nutriflow_app/screens/login_page.dart';
import 'package:nutriflow_app/user_data.dart'; // Para usar las mismas tipografías que en login
// import 'login_page.dart'; // Ajusta la importación de tu LoginPage real

// Un ejemplo de la pantalla a la que navegas con el botón "Next"
class NextRegistrationPage extends StatelessWidget {
  const NextRegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siguiente Paso'),
      ),
      body: const Center(
        child: Text('Continuación del proceso de registro...'),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores de texto
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variables para mostrar errores
  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  bool _isPasswordHidden = true;

  // Validación de nombre de usuario
  void _validateUsername() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _usernameError = 'El nombre de usuario no puede estar vacío.';
      });
    } else {
      setState(() {
        _usernameError = null;
      });
    }
  }

  // Validación de email (similar a tu LoginPage: que contenga '@')
  void _validateEmail() {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() {
        _emailError = 'El correo debe contener "@"';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  // Validación de la contraseña (igual que en LoginPage)
  void _validatePassword() {
    final String password = _passwordController.text;
    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    final bool hasDigit = password.contains(RegExp(r'\d'));
    final bool hasMinLength = password.length >= 8;

    if (!hasUppercase || !hasLowercase || !hasDigit || !hasMinLength) {
      setState(() {
        _passwordError = 'La contraseña debe incluir:\n'
            '- Min 1 mayúscula\n'
            '- Min 1 minúscula\n'
            '- Min 1 dígito\n'
            '- Min 8 caracteres';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  // Al pulsar el botón "Next", validamos todos los campos
  void _onNextPressed() async {
    _validateUsername();
    _validateEmail();
    _validatePassword();

    // Si no hay errores, navegamos a la siguiente pantalla
    // [!] Deberíamos enviar los datos. El usuario solo se subirá tras haber completado el cuestionario
    // [!] (De lo contrario, tendríamos que controlar si el usuario se ha registrado pero no lo ha completado
    // [!] lo que considero un lío inecesario)
    if (_usernameError == null &&
        _emailError == null &&
        _passwordError == null) {
      // Usar los valores correctos desde los controladores
      String username = _usernameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('La contraseña es muy débil.');
        } else if (e.code == 'email-already-in-use') {
          print('Ya existe una cuenta asociada a dicho email.');
        }
      } catch (e) {
        print(e);
      }

      // Crear el objeto UserData con los datos del usuario
      UserData userData =
          UserData(nombre: username, email: email, password: password);

      // Navegar a la siguiente pantalla con el objeto userData
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneroScreen(userData: userData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mismos colores que en tu LoginPage
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color buttonGreen = Color(0xFF43A047);

    return Scaffold(
      appBar: AppBar(
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
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        // Gradiente a pantalla completa
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Título principal
                Text(
                  'Crear Cuenta',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Introduce tus datos para registrarte',
                  style: GoogleFonts.roboto(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),

                // ------------------- NOMBRE DE USUARIO -------------------
                if (_usernameError != null) ...[
                  Text(
                    _usernameError!,
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
                    controller: _usernameController,
                    onEditingComplete: _validateUsername,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Tu nombre de usuario',
                      labelText: 'Nombre de usuario',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      prefixIcon: const Icon(Icons.person, color: Colors.green),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                    onEditingComplete: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Ej: usuario@gmail.com',
                      labelText: 'Correo electrónico',
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

                // ------------------- CONTRASEÑA -------------------
                if (_passwordError != null) ...[
                  Text(
                    _passwordError!,
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
                    controller: _passwordController,
                    obscureText: _isPasswordHidden,
                    onEditingComplete: _validatePassword,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Tu contraseña',
                      labelText: 'Contraseña',
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
                const SizedBox(height: 30),

                // ------------------- BOTÓN NEXT -------------------
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ------------------- TEXTO "YA TENGO CUENTA" -------------------
                GestureDetector(
                  onTap: () {
                    // Navegar a la pantalla de Login (LoginPage)

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      // Ahora mismo aquí hay un error porque, cuando se haga merge
                      // se utilizará el LoginPage correcto. No preocuparse.
                    );
                  },
                  child: Text(
                    'Ya tengo cuenta',
                    style: GoogleFonts.roboto(
                      color: primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
