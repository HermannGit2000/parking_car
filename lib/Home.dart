import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> carouselItems = [
    carouselCard("assets/images/images.jpg", "Gabon: Vers une croissance des parkings"),
    carouselCard("assets/images/kil.jpg", "Les differents parkings"),
    carouselCard("assets/images/pol.jpg", "Gabon: L'avenir des parkings"),
    carouselCard("assets/images/fit.jpg", "Libreville: Vers une urbanisation durable"),
    carouselCard("assets/images/ask.jpg", "Informations sur les parkings")
  ];

  String _searchType = '';
  String _searchMatricul = '';
  String _searchLocation = '';
  String _searchHour = '';
  String _selectedParkingName = '';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez activer la localisation')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission refusée')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission refusée définitivement')),
      );
      return;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final quartier = place.subLocality;
        final ville = place.locality;
        final region = place.administrativeArea;

        final readableAddress = [
          if (quartier != null && quartier.isNotEmpty) quartier,
          if (ville != null && ville.isNotEmpty) ville,
          if (region != null && region.isNotEmpty) region,
        ].join(', ');

        setState(() {
          _searchLocation = readableAddress;
          _locationController.text = readableAddress;
        });
      }
    } catch (e) {
      setState(() {
        _searchLocation = "Localisation non trouvée";
        _locationController.text = _searchLocation;
      });
    }
  }

  void _validerReservation() async {
    if (_searchType.isEmpty ||
        _searchMatricul.isEmpty ||
        _searchLocation.isEmpty ||
        _searchHour.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedParkingName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    final montant = double.tryParse(_amountController.text);
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Montant invalide.")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté.")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2));

    await FirebaseFirestore.instance.collection('reservations').add({
      'userId': user.uid,
      'type': _searchType,
      'matricule': _searchMatricul,
      'localisation': _searchLocation,
      'nomParking': _selectedParkingName,
      'heure': _searchHour,
      'montant': montant,
      'date': Timestamp.now(),
    });

    Navigator.of(context).pop();
    Navigator.pushNamed(context, '/mes_reservations');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stationnement et Réservation")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedParkingName.isNotEmpty ? _selectedParkingName : null,
              items: [
                'Parking Centre-ville',
                'Parking Marché Mont-Bouët',
                'Parking Mbolo',
                'Parking Camp de Gaulle',
                'Parking de la Gare'
              ].map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedParkingName = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Nom du parking',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _searchType.isNotEmpty ? _searchType : null,
                    items: ['Voiture', 'Moto', 'Camion']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _searchType = value!;
                        if (_searchType == 'Voiture') {
                          _amountController.text = '2000';
                        } else if (_searchType == 'Camion') {
                          _amountController.text = '2500';
                        } else if (_searchType == 'Moto') {
                          _amountController.text = '1000';
                        } else {
                          _amountController.text = '';
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _searchMatricul.isNotEmpty ? _searchMatricul : null,
                    items: ['BZ 826 AA', 'GR 467 AA', 'CV 756 AA', 'JR 574 AA', 'BA 609', 'GY 826 AA', 'GN 567 AA']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _searchMatricul = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Matricule',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Localisation',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      _searchLocation = value;
                    },
                  ),
                ),
                IconButton(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location, color: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _searchHour.isNotEmpty ? _searchHour : null,
              items: ['08:00', '09:00', '10:00', '11:00']
                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _searchHour = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Heure',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Montant',
                prefixIcon: const Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
                suffixText: 'FCFA',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validerReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Valider", style: TextStyle(fontSize: 14)),
            ),

            const SizedBox(height: 36),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Parking publicitaire",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 140,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    autoPlayInterval: const Duration(seconds: 4),
                  ),
                  items: carouselItems,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Consultez les parkings disponibles, réservez votre place, et profitez d’un stationnement sécurisé en toute simplicité.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static Widget carouselCard(String assetPath, String caption) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(assetPath, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                caption,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
