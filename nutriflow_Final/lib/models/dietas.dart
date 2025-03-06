import 'package:cloud_firestore/cloud_firestore.dart';

class Dieta {
  final int cantidad;
  final String fecha;
  final String nombre;
  final String tipoComida;
  final int calorias;
  final int grasas;
  final int proteinas;

  Dieta({
    required this.cantidad,
    required this.fecha,
    required this.nombre,
    required this.tipoComida,
    required this.calorias,
    required this.grasas,
    required this.proteinas,
  });

  factory Dieta.fromFiresBase(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Dieta(
      cantidad: data['Cantidad'] ?? 0,
      fecha: data['Fecha'] ?? "",
      nombre: data['Nombre'] ?? "",
      tipoComida: data['TipoComida'] ?? "",
      calorias: data['Calorias'] ?? 0,
      grasas: data['Grasas'] ?? 0,
      proteinas: data['Proteinas'] ?? 0,
    );
  }
}
