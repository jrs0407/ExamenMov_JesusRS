import 'package:flutter/material.dart';
import 'package:nutriflow_app/screens/cuestionario_screens/medidas_screen.dart';
import 'package:nutriflow_app/user_data.dart';

// Definición de los colores personalizados
final Color secondaryGreen = Color(0xFF43A047); // Verde claro
final Color primaryGreen = Color(0xFF2E7D32); // Verde oscuro

class PesoObjetivoScreen extends StatefulWidget {
  final UserData userData;

  PesoObjetivoScreen({required this.userData});

  @override
  _PesoObjetivoScreenState createState() => _PesoObjetivoScreenState();
}

class _PesoObjetivoScreenState extends State<PesoObjetivoScreen> {
  TextEditingController _pesoController = TextEditingController();
  bool _isMetric = true; // Sistema métrico por defecto
  bool _isValidPeso = true; // Para validar el peso
  String _pesoErrorMessage = '';
  FocusNode _focusNode = FocusNode(); // Para detectar cuando el campo pierde el foco

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validatePeso();
    }
  }

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
            const Text('Pregunta: 3/6'),
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
              '¿A qué peso deseas llegar?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 32),
            // ToggleButtons para elegir el sistema de medida
            ToggleButtons(
              isSelected: [_isMetric, !_isMetric],
              onPressed: (int index) {
                setState(() {
                  _isMetric = index == 0;
                  _validatePeso(); // Validar el peso cuando se cambia el sistema de medida
                });
              },
              color: Colors.black,
              selectedColor: primaryGreen,
              borderColor: primaryGreen,
              selectedBorderColor: primaryGreen,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Métrico'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Imperial'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Campo de texto para ingresar el peso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextFormField(
                controller: _pesoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true), // Teclado numérico con opción a decimales
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: _isMetric ? 'Peso en kg' : 'Peso en lbs',
                  errorText: _pesoErrorMessage.isEmpty ? null : _pesoErrorMessage,
                  border: const OutlineInputBorder(),
                  suffixText: _isMetric ? 'kg' : 'lbs',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: secondaryGreen, width: 2), // Color de enfoque
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _pesoErrorMessage = ''; // Limpiar el mensaje de error
                    _isValidPeso = true; // Inicialmente válido
                  });
                },
                onFieldSubmitted: (value) {
                  _validatePeso();
                },
              ),
            ),
            const SizedBox(height: 32),
            // Botón de continuar, solo se habilita cuando se introduce un peso válido
            ElevatedButton(
              onPressed: _isValidPeso
                  ? () {
                      _navigateToMedidasScreen();
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

  // Validación del peso
  void _validatePeso() {
    String pesoText = _pesoController.text;
    double? peso = double.tryParse(pesoText);

    // Validación de que el peso esté entre 40 y 400 kg (o equivalente imperial)
    if (peso == null || peso <= 0 || (peso < 40 && _isMetric) || (peso > 400 && _isMetric) || (peso < 88 && !_isMetric) || (peso > 880 && !_isMetric)) {
      setState(() {
        _isValidPeso = false;
        _pesoErrorMessage = 'Por favor, ingresa un peso válido entre 40 y 400 kg (88 y 880 lbs)';
      });
    } else {
      setState(() {
        _isValidPeso = true;
        _pesoErrorMessage = ''; // Limpiar el mensaje de error
      });
    }
  }

  // Navegar a la pantalla de "Medidas"
  void _navigateToMedidasScreen() {
    widget.userData.pesoDeseado = double.parse(_pesoController.text);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedidasScreen(userData: widget.userData),
      ),
    );
  }
}