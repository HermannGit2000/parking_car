import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MesReservationsPage extends StatefulWidget {
  const MesReservationsPage({Key? key}) : super(key: key);

  @override
  State<MesReservationsPage> createState() => _MesReservationsPageState();
}

class _MesReservationsPageState extends State<MesReservationsPage> {
  late final String userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? '';
  }

  Widget _imageForType(String type, double size) {
    String assetPath;
    switch (type.toLowerCase()) {
      case 'voiture':
        assetPath = 'assets/images/ferrari.jpg';
        break;
      case 'moto':
        assetPath = 'assets/images/moto.jpg';
        break;
      case 'camion':
        assetPath = 'assets/images/camion.jpg';
        break;
      default:
        assetPath = 'assets/images/kil.jpg';
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future<void> _annulerReservation(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('reservations').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation annulée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'annulation: $e')),
        );
      }
    }
  }

  void _showConfirmDialog(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer annulation'),
        content: const Text('Voulez-vous vraiment annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _annulerReservation(docId);
            },
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes réservations')),
        body: const Center(child: Text('Veuillez vous connecter.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mes réservations')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double imageSize = 60;
          double fontSizeTitle = 16;
          double fontSizeContent = 13;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reservations')
                .where('userId', isEqualTo: userId)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(child: Text('Aucune réservation trouvée.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final parkingName = data['nomParking'] ?? 'N/A';
                  // Je suppose que tu voulais afficher heure début - heure fin, je corrige pour afficher ces champs :
                  final heureDebut = data['heure_debut'] ?? '';
                  final heureFin = data['heure_fin'] ?? '';
                  final heures = heureDebut.isNotEmpty && heureFin.isNotEmpty
                      ? '$heureDebut - $heureFin'
                      : 'Heure inconnue';

                  final type = data['type'] ?? 'N/A';
                  final montant = data['montant']?.toString() ?? 'N/A';
                  final dateTimestamp = data['date'] as Timestamp?;
                  final dateStr = dateTimestamp != null
                      ? dateTimestamp.toDate().toLocal().toString().split('.')[0]
                      : 'Date inconnue';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.teal.shade300, width: 1),
                    ),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _imageForType(type, imageSize),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  parkingName,
                                  style: TextStyle(
                                    fontSize: fontSizeTitle,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.teal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Type: $type',
                                        style: TextStyle(fontSize: fontSizeContent),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Heure: $heures',
                                        style: TextStyle(fontSize: fontSizeContent),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Montant: $montant FCFA',
                                        style: TextStyle(fontSize: fontSizeContent),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        dateStr,
                                        style: TextStyle(
                                          fontSize: fontSizeContent - 1,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            tooltip: 'Annuler la réservation',
                            onPressed: () => _showConfirmDialog(doc.id),
                            splashRadius: 20,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
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
