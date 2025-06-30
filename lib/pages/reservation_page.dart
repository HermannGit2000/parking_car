import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReservationPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const ReservationPage({required this.docId, required this.data, Key? key}) : super(key: key);

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImageToStorage(String reservationId) async {
    if (_selectedImage == null) return null;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('reservation_images/$reservationId.jpg');

    await storageRef.putFile(_selectedImage!);
    return await storageRef.getDownloadURL();
  }

  Future<void> _reserver() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final reservationRef = FirebaseFirestore.instance.collection('reservations').doc();

      final imageUrl = await _uploadImageToStorage(reservationRef.id);

      await reservationRef.set({
        'userId': user.uid,
        'parkingId': widget.docId,
        'parkingNom': widget.data['nom'] ?? 'Parking',
        'date': Timestamp.fromDate(now),
        'imageUrl': imageUrl ?? '',
      });

      // Met à jour le nombre de places disponibles
      final parkingRef = FirebaseFirestore.instance.collection('parkings').doc(widget.docId);
      final parkingSnapshot = await parkingRef.get();
      final placesDispo = parkingSnapshot.data()?['places_disponibles'] ?? 0;

      if (placesDispo > 0) {
        await parkingRef.update({
          'places_disponibles': FieldValue.increment(-1),
          'disponible': placesDispo - 1 > 0,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Réservation enregistrée")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Erreur réservation : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nomParking = widget.data['nom'] ?? 'Parking';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver une place'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomParking,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Choisir une image"),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _reserver,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: const Text("Réserver", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
