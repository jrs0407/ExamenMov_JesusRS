import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Añadido para usar Google Fonts
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  // Mensaje de error en rojo si el email no contiene '@'
  String? _errorMessage; // Mensaje de error en rojo u otros errores

  @override
  Widget build(BuildContext context) {
    // Colores base (verdes) para la UI
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color buttonGreen = Color(0xFF43A047);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: Text(
          'Olvidé mi contraseña',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
      ),
      body: SizedBox(
        // Abarca todo el alto y ancho de la pantalla
        width: double.infinity,
        height: double.infinity,
        // Fondo con gradiente que llena la pantalla
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Encabezado vistoso en la parte superior
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_reset, size: 32, color: primaryGreen),
                    const SizedBox(width: 10),
                    Text(
                      'Recuperar Contraseña',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Perdiste tu contraseña?\nNo te preocupes, ingresa tu correo electrónico y te enviaremos un enlace para que puedas restablecerla.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // Si hay error, lo mostramos en rojo encima del TextField
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 4),
                ],

                // Campo de texto para el email
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
                      labelText: 'Ingresa el email',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón Enviar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      final String email = _emailController.text.trim();
                      // Verificamos si contiene '@'
                      if (!email.contains('@')) {
                        setState(() {
                          _errorMessage = 'El correo debe contener "@".';
                        });
                        return;
                      }

                      // Si pasa la validación del formato de email, llamamos a sendPasswordResetEmail
                      setState(() => _errorMessage = null);

                      try {
                        // Intenta enviar el correo de restablecimiento
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);

                        // Si se envía correctamente, mostramos un AlertDialog
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Correo enviado'),
                            content: Text(
                              'Se ha enviado un enlace de recuperación a $email.\n'
                              'Revisa tu bandeja de entrada.\n'
                              'Si no recibes nada, lo más probable es que tu cuenta no exista.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        // Errores de Firebase
                        if (e.code == 'user-not-found') {
                          setState(() {
                            _errorMessage =
                                'No existe ninguna cuenta con ese correo.';
                          });
                        } else {
                          setState(() {
                            _errorMessage =
                                'Error de Firebase: ${e.message ?? e.code}';
                          });
                        }
                      } catch (e) {
                        // Errores genéricos
                        setState(() {
                          _errorMessage = 'Ocurrió un error inesperado: $e';
                        });
                      }
                    },
                    child: Text(
                      'Enviar',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
