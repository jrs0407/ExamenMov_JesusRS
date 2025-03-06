import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutriflow_app/models/dietas.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, List<Dieta>>> getDietasPorTipo() async {
    User? user = _auth.currentUser;

    if (user == null) {
      return {};
    }

    String? email = user.email;
    QuerySnapshot clienteSnapshot = await _db
        .collection('clientes')
        .where('email', isEqualTo: email)
        .get();

    if (clienteSnapshot.docs.isEmpty) {
      return {};
    }

    String clienteId = clienteSnapshot.docs.first.id;
    CollectionReference collectionReferenceDietas = _db
        .collection('clientes')
        .doc(clienteId)
        .collection('dietas');

    QuerySnapshot queryDietas = await collectionReferenceDietas.get();
    Map<String, List<Dieta>> dietasPorTipo = {
      "Desayuno": [],
      "Aperitivo": [],
      "Almuerzo": [],
      "Merienda": [],
      "Cena": [],
    };
    for (var documento in queryDietas.docs) {
      Dieta dieta = Dieta.fromFiresBase(documento);
      dietasPorTipo[dieta.tipoComida]?.add(dieta);
    }

    return dietasPorTipo;
  }
}
