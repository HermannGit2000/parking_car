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
  void _setAdresseSimulee() {
    const adresseSimulee = 'Centre-ville, Libreville, Estuaire, Gabon';
    setState(() {
      _searchLocation = adresseSimulee;
      _locationController.text = adresseSimulee;
    });
  }

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
  String _selectedParkingName = '';

  TimeOfDay? _heureDebut;
  TimeOfDay? _heureFin;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La localisation est désactivée. Une adresse simulée sera utilisée.')),
        );
        _setAdresseSimulee();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission refusée. Une adresse simulée sera utilisée.')),
          );
          _setAdresseSimulee();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission refusée définitivement. Une adresse simulée sera utilisée.')),
        );
        _setAdresseSimulee();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final quartier = place.subLocality ?? '';
        final ville = place.locality ?? '';
        final region = place.administrativeArea ?? '';
        final pays = place.country ?? '';

        final adresse = [
          if (quartier.isNotEmpty) quartier,
          if (ville.isNotEmpty) ville,
          if (region.isNotEmpty) region,
          if (pays.isNotEmpty) pays,
        ].join(', ');

        setState(() {
          _searchLocation = adresse;
          _locationController.text = adresse;
        });
      } else {
        _setAdresseSimulee();
      }
    } catch (e) {
      debugPrint('Erreur géolocalisation : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la localisation. Une adresse simulée sera utilisée.')),
      );
      _setAdresseSimulee();
    }
  }

  Future<void> _selectHeureDebut(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _heureDebut = picked;
      });
    }
  }

  Future<void> _selectHeureFin(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _heureFin = picked;
      });
    }
  }

  void _validerReservation() async {
    if (_searchType.isEmpty ||
        _matriculeController.text.isEmpty ||
        _searchLocation.isEmpty ||
        _heureDebut == null ||
        _heureFin == null ||
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
      'matricule': _matriculeController.text,
      'localisation': _searchLocation,
      'nomParking': _selectedParkingName,
      'heure_debut': _heureDebut!.format(context),
      'heure_fin': _heureFin!.format(context),
      'montant': montant,
      'date': Timestamp.now(),
    });

    Navigator.of(context).pop();
    Navigator.pushNamed(context, '/mes_reservations');
  }

  void _resetForm() {
    setState(() {
      _searchType = '';
      _searchMatricul = '';
      _searchLocation = '';
      _selectedParkingName = '';
      _heureDebut = null;
      _heureFin = null;
      _amountController.clear();
      _locationController.clear();
      _matriculeController.clear();
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
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
              decoration: _inputDecoration('Nom du parking'),
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
                    decoration: _inputDecoration('Type'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _matriculeController,
                    decoration: _inputDecoration('Matricule'),
                    onChanged: (value) {
                      _searchMatricul = value;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Image simulation map au-dessus localisation
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/libreville.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: _inputDecoration('Localisation'),
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectHeureDebut(context),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: _inputDecoration("Heure de début"),
                        controller: TextEditingController(
                          text: _heureDebut != null ? _heureDebut!.format(context) : '',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectHeureFin(context),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: _inputDecoration("Heure de fin"),
                        controller: TextEditingController(
                          text: _heureFin != null ? _heureFin!.format(context) : '',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _validerReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text("Valider", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Colors.teal),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.teal),
                    label: const Text("Réinitialiser", style: TextStyle(fontSize: 16, color: Colors.teal)),
                  ),
                ),
              ],
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
