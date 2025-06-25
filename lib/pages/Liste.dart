import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parking_car/pages/reservation_page.dart';

class ListeDesParkings extends StatelessWidget {
  const ListeDesParkings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des parkings"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('parkings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final parkings = snapshot.data!.docs;

          if (parkings.isEmpty) {
            return const Center(child: Text("Aucun parking disponible"));
          }

          return ListView.builder(
            itemCount: parkings.length,
            itemBuilder: (context, index) {
              final doc = parkings[index];
              final data = doc.data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  title: Text(data['nom'] ?? 'Parking sans nom'),
                  subtitle: Text(
                      'Places disponibles : ${data['places_disponibles'] ?? 0}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationPage(docId: doc.id, data: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
