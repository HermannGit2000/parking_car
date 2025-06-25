import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parking_car/Home.dart';
import 'package:parking_car/aide.dart';
import 'package:parking_car/historique.dart';
import 'package:parking_car/mes_reservatios.dart';
import 'package:parking_car/notifications.dart';
import 'package:parking_car/pages/Liste.dart';
import 'package:parking_car/pages/reservation_page.dart';
import 'package:parking_car/parametre.dart';
import 'package:parking_car/pofil.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Pageaccueil extends StatefulWidget {
  const Pageaccueil({super.key});

  @override
  State<Pageaccueil> createState() => _PageaccueilState();
}

class _PageaccueilState extends State<Pageaccueil> {
  int pageIndex = 2;
  String userName = "Hermann Dianga";
  File? userImageFile;
  String defaultImagePath = "assets/images/fit.jpg";
  final ImagePicker _picker = ImagePicker();

  final List<Widget> pages = [
    const ListeDesParkings(),
    const MesReservationsPage(),
    const Home(),
    const NotificationPage(),
    const ProfilPage(),
    const HistoriquePage(),
    const ParametresPage(),
    const AidePage(),
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        userImageFile = File(image.path);
      });
    }
  }

  Future<void> _editUserName() async {
    final TextEditingController controller = TextEditingController(text: userName);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le nom'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Entrez votre nouveau nom'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    userName = newName;
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> estAdmin() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get().timeout(const Duration(seconds: 5));
      return doc.exists && doc.data()?['role'] == 'admin';
    } catch (e) {
      print("Erreur dans estAdmin(): $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;
    final inactiveColor = Colors.grey.shade500;
    final gradientColors = [Colors.blue.shade800, Colors.lightBlueAccent];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Parking',
                    style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  TextSpan(
                    text: ' Car',
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w400, fontSize: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: userImageFile != null ? FileImage(userImageFile!) : AssetImage(defaultImagePath) as ImageProvider,
              ),
            ),
          ),
        ),
      ),
      drawer: buildDrawer(primaryColor),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: pages[pageIndex],
      ),
      bottomNavigationBar: buildBottomNavigationBar(primaryColor, inactiveColor),
    );
  }

  Widget buildBottomNavigationBar(Color activeColor, Color inactiveColor) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navBarItem(LucideIcons.parkingSquare, 'Parking', 0, activeColor, inactiveColor),
          navBarItem(LucideIcons.car, 'Véhicules', 1, activeColor, inactiveColor),
          navBarItem(LucideIcons.home, 'Accueil', 2, activeColor, inactiveColor),
          navBarItem(LucideIcons.bell, 'Notifications', 3, activeColor, inactiveColor),
          navBarItem(LucideIcons.userCircle2, 'Profil', 4, activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget navBarItem(IconData icon, String label, int index, Color activeColor, Color inactiveColor) {
    final isSelected = pageIndex == index;
    return GestureDetector(
      onTap: () => setState(() => pageIndex = index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: activeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? activeColor : inactiveColor, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer(Color primaryColor) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1)),
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: userImageFile != null ? FileImage(userImageFile!) : AssetImage(defaultImagePath) as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 18, color: primaryColor),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _editUserName,
                      child: Icon(Icons.edit, size: 18, color: primaryColor),
                    )
                  ],
                )
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.event_available_outlined, color: primaryColor),
            title: Text("Réserver un parking"),
            onTap: () {
              setState(() => pageIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: primaryColor),
            title: Text("Historique"),
            onTap: () {
              setState(() => pageIndex = 5);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.add_location_alt, color: primaryColor),
            title: Text("Ajouter un parking"),
            onTap: () async {
              Navigator.pop(context);
              final admin = await estAdmin();
              if (admin) {
                setState(() => pageIndex = 0);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Accès réservé aux administrateurs.")),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: primaryColor),
            title: Text("Paramètres"),
            onTap: () {
              setState(() => pageIndex = 6);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: primaryColor),
            title: Text("Aide"),
            onTap: () {
              setState(() => pageIndex = 7);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Déconnexion", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Déconnexion non implémentée")),
              );
            },
          ),
        ],
      ),
    );
  }
}
