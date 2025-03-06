import 'package:flutter/material.dart';
import 'package:nutriflow_app/models/dietas.dart';
import 'package:nutriflow_app/services/firebase_service.dart';
import 'package:nutriflow_app/widgets/comidaCard.dart';
import 'package:nutriflow_app/widgets/pie_chart_comidas.dart';

class NormalScreen extends StatefulWidget {
  const NormalScreen({super.key});

  @override
  State<NormalScreen> createState() => _NormalScreenState();
}

class _NormalScreenState extends State<NormalScreen> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Diario'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, List<Dieta>>>(
        future: firestoreService.getDietasPorTipo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar los datos"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay dietas disponibles"));
          }

          final dietasPorTipo = snapshot.data!;
          double totalCalorias = 0;
          double totalProteinas = 0;
          double totalGrasas = 0;

          for (var dietas in dietasPorTipo.values) {
            for (var dieta in dietas) {
              totalCalorias += dieta.calorias;
              totalProteinas += dieta.proteinas;
              totalGrasas += dieta.grasas;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ...dietasPorTipo.entries.map((entry) {
                  final tipoComida = entry.key;
                  final dietas = entry.value;

                  return dietas.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.green,
                              child: Text(
                                tipoComida,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ...dietas.map((dieta) {
                              return ComidaCard(dieta: dieta);
                            }).toList(),
                          ],
                        ) : const SizedBox.shrink();
                        }).toList(),

                const SizedBox(height: 20),
                PieChartComidas(
                  totalCalorias: totalCalorias,
                  totalProteinas: totalProteinas,
                  totalGrasas: totalGrasas,
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
