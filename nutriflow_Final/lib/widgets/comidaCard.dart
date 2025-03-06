import 'package:flutter/material.dart';
import 'package:nutriflow_app/models/dietas.dart';

class ComidaCard extends StatelessWidget {
  final Dieta dieta;

  const ComidaCard({
    super.key,
    required this.dieta,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      child: Column(
        children: [
          ListTile(
            title: Text(
              dieta.nombre,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cantidad: ${dieta.cantidad} g'),
                Text('Calorías: ${dieta.calorias}'),
                Text('Grasas: ${dieta.grasas} g'),
                Text('Proteínas: ${dieta.proteinas} g'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
