import 'package:flutter/material.dart';
import 'package:parking_car/ModifierProfilPage.dart';// <- Chemin corrigé ici

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToModifierProfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ModifierProfilPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/logo.jpg'),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  Text(
                    "Nom de l'utilisateur",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "email@exemple.com",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _navigateToModifierProfil(context),
              icon: const Icon(Icons.edit, color: Colors.teal),
              label: const Text(
                "Modifier le profil",
                style: TextStyle(color: Colors.teal),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.teal),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showSnackbar(context, "Déconnexion simulée"),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.teal),
              title: const Text("Paramètres"),
              onTap: () => _showSnackbar(context, "Paramètres à venir"),
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.teal),
              title: const Text("Confidentialité"),
              onTap: () => _showSnackbar(context, "Options de confidentialité à venir"),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.teal),
              title: const Text("À propos de l'application"),
              onTap: () => _showSnackbar(context, "Version 1.0.0 - Parking Car"),
            ),
          ],
        ),
      ),
    );
  }
}
