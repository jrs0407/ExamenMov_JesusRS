import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          'Historial de Solicitudes',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const LogList(),
    );
  }
}

class LogList extends StatelessWidget {
  const LogList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('logs_password_reset')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No hay solicitudes registradas'),
          );
        }

        final logs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final email = log['email'] ?? 'Correo desconocido';
            final timestamp = (log['timestamp'] as Timestamp?)?.toDate();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.green),
                title: Text(
                  email,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  timestamp != null
                      ? 'Fecha: ${formatDate(timestamp)}'
                      : 'Fecha no disponible',
                  style: GoogleFonts.roboto(fontSize: 14),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => eliminarLog(context, log.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Formatea la fecha para mostrarla mejor
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Elimina el log de Firestore
  void eliminarLog(BuildContext context, String logId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Registro'),
        content: const Text('¿Estás seguro de que deseas eliminar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('logs_password_reset')
          .doc(logId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro eliminado')),
      );
    }
  }
}
