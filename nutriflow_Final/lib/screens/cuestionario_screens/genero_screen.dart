import 'package:flutter/material.dart';
import 'package:nutriflow_app/screens/cuestionario_screens/objetivo_principal_screen.dart';
import 'package:nutriflow_app/user_data.dart'; // Importa el modelo de datos

// Definición de los colores personalizados
final Color secondaryGreen = Color(0xFF43A047); // Verde claro
final Color primaryGreen = Color(0xFF2E7D32); // Verde oscuro

class GeneroScreen extends StatefulWidget {
  final UserData userData;

  GeneroScreen({required this.userData});

  @override
  _GeneroScreenState createState() => _GeneroScreenState();
}

class _GeneroScreenState extends State<GeneroScreen> {
  bool _isChecked = false; // Controla si se aceptan los términos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Estoy contando con que el logo lo vamos a poner en assets para no tener que cogerla de internet y esperar la carga...
        // Si no se hace así, cambiar v
        title: Image.asset('assets/dieta.png', height: 40),
        backgroundColor: primaryGreen,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título de bienvenida
            Text(
              '¡Bienvenido al cuestionario!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            // Explicación del cuestionario
            const Text(
              'Este cuestionario tiene como objetivo conocer tu tipo de metabolismo y brindarte recomendaciones personalizadas.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Por favor, selecciona uno de los siguientes tipos de metabolismo.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            // Botones para seleccionar el tipo de metabolismo
            Expanded(
              child: TextButton(
                onPressed:
                    _isChecked ? () => _navigateToNextScreen('femenino') : null,
                style: TextButton.styleFrom(
                  backgroundColor: secondaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Metabolismo Femenino'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextButton(
                onPressed: _isChecked
                    ? () => _navigateToNextScreen('masculino')
                    : null,
                style: TextButton.styleFrom(
                  backgroundColor: secondaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Metabolismo Masculino'),
              ),
            ),
            const SizedBox(height: 16),
            // Checkbox para aceptar términos y condiciones
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                    
                  },
                  activeColor: secondaryGreen,
                ),
                const Expanded(
                  child: Text(
                    'Acepto los términos y condiciones.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Navega a la siguiente pantalla
  void _navigateToNextScreen(String tipo) {
    widget.userData.metabolismo = tipo;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObjetivoPrincipalScreen(userData: widget.userData),
      ),
    );
  }
}
