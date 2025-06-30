import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ModifierProfilPage extends StatefulWidget {
  const ModifierProfilPage({super.key});

  @override
  State<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends State<ModifierProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  TextEditingController _nomController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  String? photoUrl;
  File? _pickedImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (mounted) {
        setState(() {
          _nomController.text = doc.data()?['nom'] ?? '';
          _phoneController.text = doc.data()?['phone'] ?? '';
          photoUrl = doc.data()?['photoUrl'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? newPhotoUrl = photoUrl;

        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_photos/${user!.uid}.jpg');
          await ref.putFile(_pickedImage!);
          newPhotoUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          'nom': _nomController.text.trim(),
          'phone': _phoneController.text.trim(),
          'photoUrl': newPhotoUrl,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil mis à jour avec succès")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier mon profil", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.teal.shade100,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (photoUrl != null
                                ? NetworkImage(photoUrl!)
                                : const AssetImage('assets/images/ask.jpg'))
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nomController,
                      decoration: InputDecoration(
                        labelText: "Nom",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Champ requis" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: user!.email,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "Téléphone",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save),
                        label: const Text("Enregistrer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
