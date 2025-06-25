import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Parking {
  final String type;
  final String location;
  final String hour;
  final String matricul;

  Parking({
    required this.type,
    required this.location,
    required this.hour,
    required this.matricul,
  });
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> carouselItems = [
    carouselCard("assets/images/voiture.jpg", "Gabon: Vers une croissance des parkings"),
    carouselCard("assets/images/iol.jpg", "Migration des calamars des mers"),
    carouselCard("assets/images/yet.jpg", "Gabon: Les coupures deviennent invivables"),
    carouselCard("assets/images/fit.jpg", "Libreville: Vers une urbanisation durable"),
  ];

  String _searchType = '';
  String _searchMatricul = '';
  String _searchLocation = '';
  String _searchHour = '';
  String _searchAmount = '';

  double userBalance = 5000;

  final List<Parking> _allParkings = [
    Parking(type: 'Voiture', location: 'Centre-ville', hour: '08:00', matricul: "555"),
    Parking(type: 'Moto', location: 'Quartier Est', hour: '09:00', matricul: "333"),
    Parking(type: 'Camion', location: 'Nord', hour: '10:00', matricul: "4444"),
    Parking(type: 'Voiture', location: 'Sud', hour: '11:00', matricul: "4449"),
  ];

  List<Parking> _filteredParkings = [];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredParkings = _allParkings;
  }

  void _filter() {
    setState(() {
      _filteredParkings = _allParkings.where((p) {
        final matchType = p.type.toLowerCase().contains(_searchType.toLowerCase());
        final matchMatricule = p.matricul.toLowerCase().contains(_searchMatricul.toLowerCase());
        final matchLocation = p.location.toLowerCase().contains(_searchLocation.toLowerCase());
        final matchHour = p.hour.contains(_searchHour);
        return matchType && matchMatricule && matchLocation && matchHour;
      }).toList();
    });
  }

  void _resetFields() {
    setState(() {
      _searchType = '';
      _searchMatricul = '';
      _searchLocation = '';
      _searchHour = '';
      _searchAmount = '';
      _amountController.clear();
      _locationController.clear();
      _filteredParkings = _allParkings;
    });
  }

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

    final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = '${place.locality}, ${place.administrativeArea}';
        setState(() {
          _searchLocation = address;
          _locationController.text = address;
          _filter();
        });
      }
    } catch (e) {
      setState(() {
        _searchLocation = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _locationController.text = _searchLocation;
        _filter();
      });
    }
  }

  void _validerReservation() async {
    if (_searchType.isEmpty ||
        _searchMatricul.isEmpty ||
        _searchLocation.isEmpty ||
        _searchHour.isEmpty ||
        _amountController.text.isEmpty) {
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

    if (montant > userBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solde insuffisant.")),
      );
      return;
    }

    // Affiche la popup de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simule un délai (ex: enregistrement dans Firestore)
    await Future.delayed(const Duration(seconds: 2));

    // Met à jour le solde
    setState(() {
      userBalance -= montant;
    });

    // Ferme la popup de chargement
    Navigator.of(context).pop();

    // Navigue vers la page de confirmation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationPage(soldeRestant: userBalance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Stationnement et Réservation",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: DropdownButtonFormField<String>(
                      value: _searchType.isNotEmpty ? _searchType : null,
                      items: ['Voiture', 'Moto', 'Camion']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _searchType = value!;
                          _filter();
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: DropdownButtonFormField<String>(
                      value: _searchMatricul.isNotEmpty ? _searchMatricul : null,
                      items: ['555', '333', '4444', '4449']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _searchMatricul = value!;
                          _filter();
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
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
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
                        _filter();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location, color: Colors.teal),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 46,
              child: DropdownButtonFormField<String>(
                value: _searchHour.isNotEmpty ? _searchHour : null,
                items: ['08:00', '09:00', '10:00', '11:00']
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _searchHour = value!;
                    _filter();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Heure',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 46,
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: 'Montant',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                  suffix: Text('Solde: ${userBalance.toInt()} FCFA'),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _searchAmount = value,
              ),
            ),

            const SizedBox(height: 26),

            ElevatedButton(
              onPressed: _validerReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Valider", style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _resetFields,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.teal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Réinitialiser", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14)),
            ),

            const SizedBox(height: 36),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Parking publicitaire",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
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

class ConfirmationPage extends StatelessWidget {
  final double soldeRestant;

  const ConfirmationPage({super.key, required this.soldeRestant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmation"), backgroundColor: Colors.teal),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text("Réservation enregistrée avec succès !", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text("Solde restant: ${soldeRestant.toInt()} FCFA", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Retour à l'accueil"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
