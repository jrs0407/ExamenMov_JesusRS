import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nutriflow_app/screens/add_food_screen.dart';
import 'package:nutriflow_app/screens/editar_food_screen.dart';

class AdministrarDietaScreen extends StatefulWidget {
  final String clienteId;

  const AdministrarDietaScreen({Key? key, required this.clienteId})
      : super(key: key);

  @override
  _AdministrarDietaScreenState createState() => _AdministrarDietaScreenState();
}

class _AdministrarDietaScreenState extends State<AdministrarDietaScreen> {
  final ValueNotifier<String> selectedMealNotifier =
      ValueNotifier<String>('Desayuno');
  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color buttonDarkGreen = const Color.fromARGB(255, 187, 235, 189);
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Stream<QuerySnapshot> _obtenerComidas() {
    return FirebaseFirestore.instance.collection('comidas').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: DropdownButtonHideUnderline(
          child: ValueListenableBuilder<String>(
            valueListenable: selectedMealNotifier,
            builder: (context, selectedMeal, child) {
              return DropdownButton<String>(
                value: selectedMeal,
                dropdownColor: const Color.fromARGB(255, 92, 136, 92),
                items: ['Desayuno', 'Media Mañana', 'Almuerzo', 'Merienda', 'Cena']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    selectedMealNotifier.value = newValue;
                  }
                },
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              );
            },
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha seleccionada: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Busca un alimento',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton('Editar rápida', 'assets/editar.png', () {
                  mostrarEditarAlimentoDialog(context);
                }),
                _buildActionButton('Adición rápida', 'assets/add.png', () {
                  mostrarAgregarAlimentoDialog(context);
                }),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _obtenerComidas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No hay comidas disponibles"));
                  }

                  final comidas = snapshot.data!.docs.where((doc) {
                    final comida = doc.data() as Map<String, dynamic>;
                    final nombre = comida['Nombre']?.toString().toLowerCase() ?? '';
                    return _searchQuery.isEmpty || nombre.contains(_searchQuery);
                  }).toList();

                  if (comidas.isEmpty) {
                    return const Center(child: Text("No se encontraron resultados"));
                  }

                  return ListView.builder(
                    itemCount: comidas.length,
                    itemBuilder: (context, index) {
                      final comida = comidas[index].data() as Map<String, dynamic>;
                      final String nombre = comida['Nombre'] ?? 'Sin Nombre';
                      final int calorias = int.tryParse(comida['Calorias']?.toString() ?? '0') ?? 0;
                      final int grasas = int.tryParse(comida['Grasas']?.toString() ?? '0') ?? 0;
                      final int proteinas = int.tryParse(comida['Proteinas']?.toString() ?? '0') ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(nombre),
                          subtitle: Text('$calorias cal, $grasas g grasas, $proteinas g proteínas'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _showAddQuantityDialog(nombre, calorias, grasas, proteinas);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, String assetPath, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonDarkGreen,
            foregroundColor: Colors.black,
          ),
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, height: 24),
              const SizedBox(height: 4),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddQuantityDialog(String foodName, int calorias, int grasas, int proteinas) {
    String quantity = '';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Añadir Cantidad de $foodName'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cantidad (1 - 999)',
                      border: OutlineInputBorder(),
                      errorText: errorMessage,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        quantity = value;
                        errorMessage = null;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    int? parsedQuantity = int.tryParse(quantity);

                    if (parsedQuantity == null || parsedQuantity < 1 || parsedQuantity > 999) {
                      setState(() {
                        errorMessage = "Ingrese un valor entre 1 y 999";
                      });
                    } else {
                      await _guardarDietaEnFirestore(foodName, parsedQuantity, calorias, grasas, proteinas);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Añadir'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _guardarDietaEnFirestore(String foodName, int quantity, int calorias, int grasas, int proteinas) async {
    try {
      CollectionReference dietasRef = FirebaseFirestore.instance
          .collection('clientes')
          .doc(widget.clienteId)
          .collection('dietas');

      await dietasRef.add({
        'Nombre': foodName,
        'Cantidad': quantity,
        'Fecha': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'TipoComida': selectedMealNotifier.value,
        'Calorias': calorias, 
        'Grasas': grasas,    
        'Proteinas': proteinas,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$foodName añadido con éxito')),
      );
    } catch (e) {
      print("Error al guardar en Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar en Firestore')),
      );
    }
  }

  void mostrarAgregarAlimentoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: AgregarAlimentoScreen(),
        );
      },
    );
  }

  void mostrarEditarAlimentoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: EditarAlimentoScreen(),
        );
      },
    );
  }
}