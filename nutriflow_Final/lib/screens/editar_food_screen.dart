import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditarAlimentoScreen extends StatefulWidget {
  @override
  _EditarAlimentoScreenState createState() => _EditarAlimentoScreenState();
}

class _EditarAlimentoScreenState extends State<EditarAlimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _calorias = '';
  String _grasas = '';
  String _proteinas = '';
  String? _nombreError;
  String? _caloriasError;
  String? _grasasError;
  String? _proteinasError;

  void _validarCampos() {
    setState(() {
      _nombreError = _nombre.isEmpty ? 'Campo requerido' : null;
      _caloriasError = _validarNumero(_calorias);
      _grasasError = _validarNumero(_grasas);
      _proteinasError = _validarNumero(_proteinas);
    });
  }

  String? _validarNumero(String valor) {
    if (valor.isEmpty) {
      return 'Campo requerido';
    }
    final numero = int.tryParse(valor);
    if (numero == null || numero < 0 || numero > 9999) {
      return 'Debe estar entre 0 y 9999';
    }
    return null;
  }

  Future<void> _editarAlimento() async {
    if (_formKey.currentState!.validate()) {
      final alimentosRef = FirebaseFirestore.instance.collection('comidas');

      final String nombreLimpio = _nombre.trim().toLowerCase();

      final querySnapshot = await alimentosRef.get();
      
      final doc = querySnapshot.docs.firstWhere(
        (doc) => doc['Nombre'].toString().trim().toLowerCase() == nombreLimpio,
      
      );

      if (doc != null) {
        await alimentosRef.doc(doc.id).update({
          'Calorias': int.parse(_calorias), 
          'Grasas': int.parse(_grasas), 
          'Proteinas': int.parse(_proteinas), 
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Alimento actualizado con éxito')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: El producto no existe')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Alimento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre', errorText: _nombreError),
                onChanged: (value) {
                  setState(() {
                    _nombre = value.trim();
                  });
                  _validarCampos();
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Calorías', errorText: _caloriasError),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _calorias = value.trim();
                  });
                  _validarCampos();
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Grasas (g)', errorText: _grasasError),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _grasas = value.trim();
                  });
                  _validarCampos();
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Proteínas (g)', errorText: _proteinasError),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _proteinas = value.trim();
                  });
                  _validarCampos();
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _editarAlimento,
          child: Text('Editar'),
        ),
      ],
    );
  }
}