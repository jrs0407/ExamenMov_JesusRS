import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as FirebaseFireStore;
import 'package:nutriflow_app/screens/login_page.dart';
import 'package:nutriflow_app/user_data.dart';

// Definición de los colores personalizados
final Color secondaryGreen = Color(0xFF43A047); // Verde claro
final Color primaryGreen = Color(0xFF2E7D32); // Verde oscuro

class RestriccionesScreen extends StatefulWidget {
  final UserData userData;

  RestriccionesScreen({required this.userData});

  @override
  _RestriccionesScreenState createState() => _RestriccionesScreenState();
}

class _RestriccionesScreenState extends State<RestriccionesScreen> {
  // Variables para las opciones de CheckBox
  bool _lacteos = false;
  bool _mani = false;
  bool _soja = false;

  bool _intoleranteLactosa = false;
  bool _celiaco = false;
  bool _vegano = false;

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
            const Text('Pregunta: 6/6'),
          ],
        ),
        backgroundColor: primaryGreen,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Alguna restricción alimentaria?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Alergias',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            // Checkboxes para las alergias (3 opciones)
            CheckboxListTile(
              title: const Text('Lácteos'),
              value: _lacteos,
              onChanged: (bool? value) {
                setState(() {
                  _lacteos = value!;
                });
              },
              activeColor: secondaryGreen, // Color verde para la caja activa
            ),
            CheckboxListTile(
              title: const Text('Maní'),
              value: _mani,
              onChanged: (bool? value) {
                setState(() {
                  _mani = value!;
                });
              },
              activeColor: secondaryGreen,
            ),
            CheckboxListTile(
              title: const Text('Soja'),
              value: _soja,
              onChanged: (bool? value) {
                setState(() {
                  _soja = value!;
                });
              },
              activeColor: secondaryGreen,
            ),
            const SizedBox(height: 32),
            Text(
              'Restricciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            // Checkboxes para las restricciones (3 opciones)
            CheckboxListTile(
              title: const Text('Intolerante a la lactosa'),
              value: _intoleranteLactosa,
              onChanged: (bool? value) {
                setState(() {
                  _intoleranteLactosa = value!;
                });
              },
              activeColor: secondaryGreen,
            ),
            CheckboxListTile(
              title: const Text('Celiaco'),
              value: _celiaco,
              onChanged: (bool? value) {
                setState(() {
                  _celiaco = value!;
                });
              },
              activeColor: secondaryGreen,
            ),
            CheckboxListTile(
              title: const Text('Vegano'),
              value: _vegano,
              onChanged: (bool? value) {
                setState(() {
                  _vegano = value!;
                });
              },
              activeColor: secondaryGreen,
            ),
            const SizedBox(height: 32),
            // Botón de actualizar y finalizar
            ElevatedButton(
              onPressed: () {
                // Aquí actualizas los datos del usuario y navegas a la pantalla principal
                _navigateToHomeScreen();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: secondaryGreen, // Cambié el estilo para que funcione
              ),
              child: const Text('Actualizar Datos y Finalizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHomeScreen() async {
    widget.userData.restriccionesAlimentarias = [];
    if (_lacteos) widget.userData.restriccionesAlimentarias!.add('Lácteos');
    if (_mani) widget.userData.restriccionesAlimentarias!.add('Maní');
    if (_soja) widget.userData.restriccionesAlimentarias!.add('Soja');
    if (_intoleranteLactosa) widget.userData.restriccionesAlimentarias!.add('Intolerante a la lactosa');
    if (_celiaco) widget.userData.restriccionesAlimentarias!.add('Celiaco');
    if (_vegano) widget.userData.restriccionesAlimentarias!.add('Vegano');

    // Subir datos a Firebase
    await _uploadDataToFirebase(widget.userData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  Future<void> _uploadDataToFirebase(UserData userData) async {
    try {
      await FirebaseFirestore.instance.collection('clientes').add({
        'nombre': userData.nombre,
        'email': userData.email,
        'password':userData.password,
        'metabolismo': userData.metabolismo,
        'horasDormir': userData.horasDormir,
        'altura': userData.altura,
        'edad': userData.edad,
        'peso': userData.peso,
        'objetivo': userData.objetivo,
        'pesoDeseado': userData.pesoDeseado,
        'restriccionesAlimentarias': userData.restriccionesAlimentarias,
      });
      print('Datos subidos correctamente a Firebase');
    } catch (e) {
      print('Error al subir datos a Firebase: $e');
    }
  }
}