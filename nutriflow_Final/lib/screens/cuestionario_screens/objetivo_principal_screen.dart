import 'package:flutter/material.dart';
import 'package:nutriflow_app/screens/cuestionario_screens/peso_objetivo_screen.dart';
import 'package:nutriflow_app/user_data.dart';

// Definición de los colores personalizados
final Color secondaryGreen = Color(0xFF43A047); // Verde claro
final Color primaryGreen = Color(0xFF2E7D32); // Verde oscuro

class ObjetivoPrincipalScreen extends StatefulWidget {
  final UserData userData;

  ObjetivoPrincipalScreen({required this.userData});

  @override
  _ObjetivoPrincipalScreenState createState() =>
      _ObjetivoPrincipalScreenState();
}

class _ObjetivoPrincipalScreenState extends State<ObjetivoPrincipalScreen> {
  String? _selectedObjective;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/dieta.png', height: 30),
            const SizedBox(width: 8),
            const Text('Pregunta: 2/6'),
          ],
        ),
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
            // Título de la pantalla
            Text(
              '¿Cuál es tu objetivo principal?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 32),
            // Opciones de radio para los objetivos
            RadioListTile<String>(
              title: const Text('Perder peso'),
              value: 'perder peso',
              groupValue: _selectedObjective,
              onChanged: (String? value) {
                setState(() {
                  _selectedObjective = value;
                });
              },
              activeColor: secondaryGreen,
            ),
            RadioListTile<String>(
              title: const Text('Ganar peso'),
              value: 'ganar peso',
              groupValue: _selectedObjective,
              onChanged: (String? value) {
                setState(() {
                  _selectedObjective = value;
                });
              },
              activeColor: secondaryGreen,
            ),
            RadioListTile<String>(
              title: const Text('Mantenerse en forma y sano'),
              value: 'mantenerse en forma',
              groupValue: _selectedObjective,
              onChanged: (String? value) {
                setState(() {
                  _selectedObjective = value;
                });
              },
              activeColor: secondaryGreen,
            ),
            RadioListTile<String>(
              title: const Text('Aumentar metabolismo'),
              value: 'aumentar metabolismo',
              groupValue: _selectedObjective,
              onChanged: (String? value) {
                setState(() {
                  _selectedObjective = value;
                });
              },
              activeColor: secondaryGreen,
            ),
            const SizedBox(height: 32),
            // Botón de continuar, que solo se habilita cuando se selecciona una opción
            ElevatedButton(
              onPressed: _selectedObjective != null
                  ? () {
                      _navigateToPesoObjetivoScreen();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: secondaryGreen, // Uso de backgroundColor
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  // Navegar a la pantalla de "Peso Objetivo"
  void _navigateToPesoObjetivoScreen() {
    widget.userData.objetivo = _selectedObjective;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PesoObjetivoScreen(userData: widget.userData),
      ),
    );
  }
}