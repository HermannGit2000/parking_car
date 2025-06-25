import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReservationPage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const ReservationPage({required this.docId, required this.data, Key? key}) : super(key: key);

  Future<void> reserver(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (data['places_disponibles'] > 0) {
      try {
        await FirebaseFirestore.instance.collection('parkings').doc(docId).update({
          'places_disponibles': FieldValue.increment(-1),
          'disponible': data['places_disponibles'] - 1 > 0,
        });

        await FirebaseFirestore.instance
            .collection('reservations')
            .add({'userId': user.uid, 'parkingId': docId, 'date': DateTime.now()});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Réservation effectuée !")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  Future<void> annulerReservation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final resSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: user.uid)
        .where('parkingId', isEqualTo: docId)
        .limit(1)
        .get();

    if (resSnapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance.collection('reservations').doc(resSnapshot.docs.first.id).delete();

      await FirebaseFirestore.instance.collection('parkings').doc(docId).update({
        'places_disponibles': FieldValue.increment(1),
        'disponible': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Réservation annulée.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucune réservation à annuler.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int places = data['places_disponibles'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text("Réserver: ${data['nom']}"), backgroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_parking, size: 60, color: Colors.teal),
              const SizedBox(height: 20),
              Text("Places disponibles: $places",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: places > 0 ? () => reserver(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text("Réserver une place"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => annulerReservation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Annuler ma réservation"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
