import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AjouterParkings extends StatelessWidget {
  const AjouterParkings({super.key});

  Future<void> ajouterParkings(BuildContext context) async {
    try {
      final parkings = [
        {'nom': 'Parking de la Gare', 'places_disponibles': 12},
        {'nom': 'Parking Grand Marché', 'places_disponibles': 20},
        {'nom': 'Parking Bord de Mer', 'places_disponibles': 15},
        {'nom': 'Parking Montagne Verte', 'places_disponibles': 8},
        {'nom': 'Parking des Universités', 'places_disponibles': 18},
        {'nom': 'Parking Zone Industrielle', 'places_disponibles': 25},
        {'nom': 'Parking du Stade Central', 'places_disponibles': 10},
        {'nom': 'Parking Tour Horizon', 'places_disponibles': 16},
        {'nom': 'Parking Carrefour Express', 'places_disponibles': 9},
        {'nom': 'Parking Complexe Santé', 'places_disponibles': 14},
        {'nom': 'Parking Cité des Affaires', 'places_disponibles': 22},
      ];

      for (var parking in parkings) {
        await FirebaseFirestore.instance.collection('parkings').add(parking);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Parkings ajoutés avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajout de Parkings")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => ajouterParkings(context),
          child: const Text("Ajouter les parkings"),
        ),
      ),
    );
  }
}
