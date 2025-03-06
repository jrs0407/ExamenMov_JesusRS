import 'package:flutter/material.dart';
import 'package:nutriflow_app/screens/cuestionario_screens/horas_dormir_screen.dart';
import 'package:nutriflow_app/user_data.dart';

// Definición de los colores personalizados
final Color secondaryGreen = Color(0xFF43A047); // Verde claro
final Color primaryGreen = Color(0xFF2E7D32); // Verde oscuro

class MedidasScreen extends StatefulWidget {
  final UserData userData;

  MedidasScreen({required this.userData});

  @override
  _MedidasScreenState createState() => _MedidasScreenState();
}

class _MedidasScreenState extends State<MedidasScreen> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();

  bool _isMetric = true;
  bool _isPesoValid = true;
  bool _isAlturaValid = true;
  bool _isEdadValid = true;

  String _pesoErrorMessage = '';
  String _alturaErrorMessage = '';
  String _edadErrorMessage = '';

  final FocusNode _pesoFocusNode = FocusNode();
  final FocusNode _alturaFocusNode = FocusNode();
  final FocusNode _edadFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isMetric = widget.userData.isMetric ?? true; // Usa el valor almacenado o métrico por defecto
    _pesoFocusNode.addListener(_onFocusChange);
    _pesoFocusNode.addListener(_onFocusChange);
    _alturaFocusNode.addListener(_onFocusChange);
    _edadFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _pesoFocusNode.removeListener(_onFocusChange);
    _alturaFocusNode.removeListener(_onFocusChange);
    _edadFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (!_pesoFocusNode.hasFocus) {
      _validatePeso();
    }
    if (!_alturaFocusNode.hasFocus) {
      _validateAltura();
    }
    if (!_edadFocusNode.hasFocus) {
      _validateEdad();
    }
  }

  void _validatePeso() {
    String pesoText = _pesoController.text;
    double? peso = double.tryParse(pesoText);

    if (peso == null ||
        peso <= 0 ||
        (peso < 40 && _isMetric) ||
        (peso > 400 && _isMetric) ||
        (peso < 88 && !_isMetric) ||
        (peso > 880 && !_isMetric)) {
      setState(() {
        _isPesoValid = false;
        _pesoErrorMessage = 'Peso fuera de rango. Ingresa un valor válido.';
      });
    } else {
      setState(() {
        _isPesoValid = true;
        _pesoErrorMessage = '';
      });
    }
  }

  void _validateAltura() {
    String alturaText = _alturaController.text;
    double? altura = double.tryParse(alturaText);

    if (altura == null || altura <= 0 || altura > 3.0) {
      setState(() {
        _isAlturaValid = false;
        _alturaErrorMessage = 'Altura fuera de rango. Ingresa un valor válido.';
      });
    } else {
      setState(() {
        _isAlturaValid = true;
        _alturaErrorMessage = '';
      });
    }
  }

  void _validateEdad() {
    String edadText = _edadController.text;
    int? edad = int.tryParse(edadText);

    if (edad == null || edad <= 0 || edad > 120) {
      setState(() {
        _isEdadValid = false;
        _edadErrorMessage = 'Edad fuera de rango. Ingresa un valor válido.';
      });
    } else {
      setState(() {
        _isEdadValid = true;
        _edadErrorMessage = '';
      });
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
            const Text('Pregunta: 4/6'),
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
            Text(
              'Comprobemos las medidas de tu cuerpo',
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
                  _validatePeso();
                  _validateAltura();
                  _validateEdad();
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
                focusNode: _pesoFocusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: _isMetric ? 'Peso en kg' : 'Peso en lbs',
                  errorText:
                      _pesoErrorMessage.isEmpty ? null : _pesoErrorMessage,
                  border: const OutlineInputBorder(),
                  suffixText: _isMetric ? 'kg' : 'lbs',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: primaryGreen,
                        width: 2), // Cambiar a color primario (verde)
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey, width: 1), // Borde por defecto
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _pesoErrorMessage = '';
                    _isPesoValid = true;
                  });
                },
                onFieldSubmitted: (value) {
                  _validatePeso();
                },
              ),
            ),
            const SizedBox(height: 16),
            // Campo de texto para ingresar la altura
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextFormField(
                controller: _alturaController,
                focusNode: _alturaFocusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: _isMetric ? 'Altura en metros' : 'Altura en pies',
                  errorText:
                      _alturaErrorMessage.isEmpty ? null : _alturaErrorMessage,
                  border: const OutlineInputBorder(),
                  suffixText: _isMetric ? 'm' : 'ft',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: primaryGreen,
                        width: 2), // Cambiar a color primario (verde)
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey, width: 1), // Borde por defecto
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _alturaErrorMessage = '';
                    _isAlturaValid = true;
                  });
                },
                onFieldSubmitted: (value) {
                  _validateAltura();
                },
              ),
            ),
            const SizedBox(height: 16),
            // Campo de texto para ingresar la edad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextFormField(
                controller: _edadController,
                focusNode: _edadFocusNode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Edad',
                  errorText:
                      _edadErrorMessage.isEmpty ? null : _edadErrorMessage,
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: primaryGreen,
                        width: 2), // Cambiar a color primario (verde)
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey, width: 1), // Borde por defecto
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _edadErrorMessage = '';
                    _isEdadValid = true;
                  });
                },
                onFieldSubmitted: (value) {
                  _validateEdad();
                },
              ),
            ),
            const SizedBox(height: 32),
            // Botón de continuar
            ElevatedButton(
              onPressed: _isPesoValid && _isAlturaValid && _isEdadValid
                  ? _navigateToHorasDormirScreen
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

  void _navigateToHorasDormirScreen() {
    widget.userData.peso = double.parse(_pesoController.text);
    widget.userData.altura = double.parse(_alturaController.text);
    widget.userData.edad = int.parse(_edadController.text);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HorasDormirScreen(userData: widget.userData),
      ),
    );
  }
}
