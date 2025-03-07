import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutriflow_app/screens/log_screen.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color buttonGreen = Color(0xFF43A047);

  @override
  Widget build(BuildContext context) {
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
        width: double.infinity,
        height: double.infinity,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_reset, size: 32, color: primaryGreen),
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
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
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
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _validarYRegistrarRecuperacion,
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
                //Boton navegación al historial
                TextButton.icon(
                  icon: const Icon(Icons.history,
                      color: Color(0xFF2E7D32)), 
                  label: Text(
                    'Ver historial de solicitudes',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Color(0xFF2E7D32), 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LogScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funcion principal que valida el límite y registra
  Future<void> _validarYRegistrarRecuperacion() async {
    final email = _emailController.text.trim();

    if (!email.contains('@')) {
      setState(() => _errorMessage = 'El correo debe contener "@".');
      return;
    }

    try {
      final peticionesHoy = await _contarPeticionesHoy(email);
      if (peticionesHoy >= 5) {
        setState(() {
          _errorMessage =
              'Has superado el límite de 5 peticiones en las últimas 24 horas.';
        });
        return;
      }

      await _registrarLogRecuperacion(email);

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Éxito'),
          content: Text('Se ha enviado el correo de recuperación a $email'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    }
  }

  // Registra el log y limpia logs viejos
  Future<void> _registrarLogRecuperacion(String email) async {
    final logsRef =
        FirebaseFirestore.instance.collection('logs_password_reset');

    await logsRef.add({
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _limpiarLogsAntiguos(email);
  }

  // Elimina logs con más de 24 horas de antigüedad
  Future<void> _limpiarLogsAntiguos(String email) async {
    final logsRef =
        FirebaseFirestore.instance.collection('logs_password_reset');

    final fechaLimite = DateTime.now().subtract(const Duration(days: 1));

    final querySnapshot = await logsRef
        .where('email', isEqualTo: email)
        .where('timestamp', isLessThan: Timestamp.fromDate(fechaLimite))
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Cuenta cuantas peticiones ha hecho este email en las últimas 24 horas
  Future<int> _contarPeticionesHoy(String email) async {
    final logsRef =
        FirebaseFirestore.instance.collection('logs_password_reset');

    final fechaLimite = DateTime.now().subtract(const Duration(days: 1));

    final querySnapshot = await logsRef
        .where('email', isEqualTo: email)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(fechaLimite))
        .get();

    return querySnapshot.docs.length;
  }
}
