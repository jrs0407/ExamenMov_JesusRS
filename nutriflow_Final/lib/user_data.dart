class UserData {
  String? nombre;
  String? email;
  String? password;
  String? metabolismo;
  String? horasDormir;
  double? altura;
  int? edad;
  double? peso;
  String? objetivo;
  double? pesoDeseado;
  List<String>? restriccionesAlimentarias;
  bool? isMetric; // (métrico o imperial)

  UserData({
    this.nombre,
    this.email,
    this.password,
    this.metabolismo,
    this.horasDormir,
    this.altura,
    this.edad,
    this.peso,
    this.objetivo,
    this.pesoDeseado,
    this.restriccionesAlimentarias,
    this.isMetric,
  });
}
