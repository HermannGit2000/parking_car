import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParametresPage extends StatefulWidget {
  const ParametresPage({super.key});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  bool notificationsActives = true;
  String? userEmail;
  String? userName;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userEmail = user?.email;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?['nom'] ?? "Utilisateur";
        });
      }
    }
  }

  void _toggleNotifications(bool value) {
    setState(() => notificationsActives = value);
    // Sauvegarder la préférence dans Firestore ou localement si nécessaire
  }

  void _changerMotDePasse() async {
    if (userEmail != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("E-mail de réinitialisation envoyé à $userEmail")),
      );
    }
  }

  void _seDeconnecter() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(userName ?? "Nom de l'utilisateur"),
            subtitle: Text(userEmail ?? "Adresse e-mail"),
          ),
          const Divider(),
          SwitchListTile(
            value: notificationsActives,
            onChanged: _toggleNotifications,
            title: const Text("Notifications"),
            secondary: const Icon(Icons.notifications_active),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Changer le mot de passe"),
            onTap: _changerMotDePasse,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
            onTap: _seDeconnecter,
          ),
        ],
      ),
    );
  }
}
