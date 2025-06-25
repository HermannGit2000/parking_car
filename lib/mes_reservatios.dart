import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MesReservationsPage extends StatelessWidget {
  const MesReservationsPage({super.key});

  // Récupère le nom du parking à partir de son ID
  Future<String> getNomParking(String parkingId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('parkings').doc(parkingId).get();
      if (doc.exists) {
        final data = doc.data();
        return data != null && data.containsKey('nom') ? data['nom'] : 'Parking inconnu';
      } else {
        return 'Parking supprimé';
      }
    } catch (e) {
      return 'Erreur lors du chargement';
    }
  }

  // Annule une réservation et remet à jour le nombre de places disponibles
  Future<void> annulerReservation(String reservationId, String parkingId, BuildContext context) async {
    try {
      // Supprimer la réservation
      await FirebaseFirestore.instance.collection('reservations').doc(reservationId).delete();

      // Réajuster les places disponibles du parking
      await FirebaseFirestore.instance.collection('parkings').doc(parkingId).update({
        'places_disponibles': FieldValue.increment(1),
        'disponible': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Réservation annulée.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'annulation : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mes réservations"), backgroundColor: Colors.white),
        body: const Center(child: Text("Veuillez vous connecter.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mes réservations"), backgroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('userId', isEqualTo: user.uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucune réservation trouvée."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              // Sécurité: vérifier que les champs existent
              final parkingId = data['parkingId'] as String? ?? '';
              final Timestamp? timestamp = data['date'] as Timestamp?;
              final date = timestamp != null ? timestamp.toDate() : DateTime.now();

              return FutureBuilder<String>(
                future: getNomParking(parkingId),
                builder: (context, snapshot) {
                  final nomParking = snapshot.data ?? 'Chargement...';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.local_parking, color: Colors.teal),
                      title: Text(nomParking),
                      subtitle: Text(
                        "Réservé le : ${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: "Annuler",
                        onPressed: () => annulerReservation(doc.id, parkingId, context),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
