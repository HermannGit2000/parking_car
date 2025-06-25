import 'package:flutter/material.dart';

class AidePage extends StatelessWidget {
  const AidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aide & Support"),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Bienvenue dans l'assistance",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Cette application vous permet de réserver facilement une place de stationnement en quelques clics. Voici comment l'utiliser :",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: "1. Rechercher une place",
            content:
                "• Sélectionnez le type de véhicule (voiture, moto, camion).\n"
                "• Entrez ou choisissez votre localisation.\n"
                "• Choisissez une heure de stationnement.\n"
                "• Indiquez votre numéro de plaque (matricule).",
          ),
          _buildSection(
            title: "2. Utiliser la localisation",
            content:
                "Vous pouvez cliquer sur l’icône 📍 à côté du champ localisation pour utiliser automatiquement votre position actuelle.",
          ),
          _buildSection(
            title: "3. Réserver et payer",
            content:
                "• Entrez le montant à payer pour la réservation.\n"
                "• Vérifiez que votre solde est suffisant.\n"
                "• Cliquez sur 'Valider' pour réserver.",
          ),
          _buildSection(
            title: "4. Historique",
            content:
                "Les réservations sont enregistrées automatiquement. Vous pouvez consulter vos réservations passées dans la section dédiée (à implémenter).",
          ),
          const SizedBox(height: 24),
          const Text(
            "FAQ - Questions Fréquentes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFAQ(
            question: "Pourquoi ma localisation ne fonctionne pas ?",
            answer:
                "Assurez-vous que les services de localisation sont activés et que vous avez donné l'autorisation à l'application.",
          ),
          _buildFAQ(
            question: "Comment recharger mon solde ?",
            answer:
                "Actuellement, la recharge de solde n’est pas encore disponible. Cette fonctionnalité sera ajoutée prochainement.",
          ),
          _buildFAQ(
            question: "Puis-je annuler une réservation ?",
            answer:
                "Non. Une fois la réservation validée, elle n’est pas remboursable pour le moment.",
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              "Besoin de plus d’aide ?\nContactez-nous à support@parkingapp.com",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  static Widget _buildFAQ({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Text(answer),
        ),
      ],
    );
  }
}
