import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoriqueReservationsPage extends StatelessWidget {
  const HistoriqueReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des réservations"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement des données."));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservations = snapshot.data!.docs;

          if (reservations.isEmpty) {
            return const Center(child: Text("Aucune réservation trouvée."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final data = reservations[index].data();
              final date = (data['date'] as Timestamp).toDate();
              final formattedDate = DateFormat.yMd().add_Hm().format(date);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.local_parking, color: Colors.teal),
                  title: Text('${data['type']} - ${data['matricule']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('📍 Parking : ${data['nomParking'] ?? "Non précisé"}'),
                      Text('🗺️ Localisation : ${data['localisation'] ?? "Inconnue"}'),
                      Text('⏰ Heure : ${data['heure'] ?? "--"}'),
                      Text('💰 Montant : ${data['montant']} FCFA'),
                      Text('🗓️ Date : $formattedDate'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

