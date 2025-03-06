import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartComidas extends StatelessWidget {
  final double totalCalorias;
  final double totalProteinas;
  final double totalGrasas;

  const PieChartComidas({
    super.key,
    required this.totalCalorias,
    required this.totalProteinas,
    required this.totalGrasas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Distribución Nutricional Total",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 1.2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 50,
              borderData: FlBorderData(show: false),
              sections: _mostrarSecciones(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildIndicadores(),
      ],
    );
  }

  List<PieChartSectionData> _mostrarSecciones() {
    final total = totalCalorias + totalProteinas + totalGrasas;

    return [
      PieChartSectionData(
        color: Colors.blue,
        value: totalCalorias,
        title: '${((totalCalorias / total) * 100).toStringAsFixed(1)}% Cal',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: totalProteinas,
        title: '${((totalProteinas / total) * 100).toStringAsFixed(1)}% Prot',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: totalGrasas,
        title: '${((totalGrasas / total) * 100).toStringAsFixed(1)}% Grasas',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildIndicadores() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Indicador(color: Colors.blue, text: 'Calorías'),
        SizedBox(width: 10),
        _Indicador(color: Colors.red, text: 'Proteínas'),
        SizedBox(width: 10),
        _Indicador(color: Colors.green, text: 'Grasas'),
      ],
    );
  }
}

class _Indicador extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicador({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
