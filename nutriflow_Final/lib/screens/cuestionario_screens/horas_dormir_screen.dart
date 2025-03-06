import 'package:flutter/material.dart';
import 'package:nutriflow_app/screens/cuestionario_screens/restricciones_screen.dart';
import 'package:nutriflow_app/user_data.dart';

// Definición de los colores personalizados
final Color secondaryGreen = Color(0xFF43A047); // Verde claro
final Color primaryGreen = Color(0xFF2E7D32); // Verde oscuro

class HorasDormirScreen extends StatefulWidget {
  final UserData userData;

  HorasDormirScreen({required this.userData});

  @override
  _HorasDormirScreenState createState() => _HorasDormirScreenState();
}

class _HorasDormirScreenState extends State<HorasDormirScreen> {
  String? _selectedSleepHours;
  bool _isValidSelection = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const Text('Pregunta: 5/6'),
          ],
        ),
        backgroundColor: primaryGreen,
      ),
      body: Container(
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
            const SizedBox(height: 32),
            Text(
              '¿Cuánto sueles dormir?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 32),
            // Opciones de radio
            RadioListTile<String>(
              title: const Text('<5 horas'),
              value: '<5 horas',
              groupValue: _selectedSleepHours,
              onChanged: (value) {
                setState(() {
                  _selectedSleepHours = value;
                  _isValidSelection = true; // Habilitar el botón de continuar
                });
              },
              activeColor: primaryGreen,
            ),
            RadioListTile<String>(
              title: const Text('5-6 horas'),
              value: '5-6 horas',
              groupValue: _selectedSleepHours,
              onChanged: (value) {
                setState(() {
                  _selectedSleepHours = value;
                  _isValidSelection = true;
                });
              },
              activeColor: primaryGreen,
            ),
            RadioListTile<String>(
              title: const Text('7-8 horas'),
              value: '7-8 horas',
              groupValue: _selectedSleepHours,
              onChanged: (value) {
                setState(() {
                  _selectedSleepHours = value;
                  _isValidSelection = true;
                });
              },
              activeColor: primaryGreen,
            ),
            RadioListTile<String>(
              title: const Text('+8 horas'),
              value: '+8 horas',
              groupValue: _selectedSleepHours,
              onChanged: (value) {
                setState(() {
                  _selectedSleepHours = value;
                  _isValidSelection = true;
                });
              },
              activeColor: primaryGreen,
            ),
            const SizedBox(height: 32),
            // Botón de continuar, solo se habilita cuando se selecciona una opción
            ElevatedButton(
              onPressed: _isValidSelection
                  ? () {
                      _navigateToRestriccionesScreen();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: secondaryGreen,
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRestriccionesScreen() {
    widget.userData.horasDormir = _selectedSleepHours;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestriccionesScreen(userData: widget.userData),
      ),
    );
  }
}
