import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking_car/Connexion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_car/connexion.dart' hide Connexion;

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool _isLoading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkIfUserShouldSeeOnboarding();
  }

  Future<void> _checkIfUserShouldSeeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingVu = prefs.getBool('onboardingVu') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _showOnboarding = !onboardingVu;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    return _showOnboarding ? const OnboardingScreen() : const Connexion();
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

final List<Map<String, String>> onboardingData = [
  {
    'animation': 'assets/lottie/car_parking.json',
    'title': 'Bienvenu dans notre application',
    'desc': 'Trouvez rapidement une place libre près de vous.',
  },
  {
    'animation': 'assets/lottie/map_navigation.json',
    'title': 'Navigation en temps réel',
    'desc': 'Suivez votre trajet jusqu’à la place de parking.',
  },
  {
    'animation': 'assets/lottie/app_onboarding.json',
    'title': 'Simple et rapide',
    'desc': 'Lancez l’app et commencez à stationner sans stress.',
  },
];

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingVu', true);

    // ✅ Navigation différée après le rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Connexion()),
      );
    });
  }

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  final item = onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 9,
                          child: Lottie.asset(item['animation']!),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['desc']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: _currentPage == index ? 20 : 8,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.inactiveGray,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    CupertinoButton(
                      onPressed: _previousPage,
                      child: const Text('Précédent'),
                    )
                  else
                    const SizedBox.shrink(),
                  CupertinoButton.filled(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? 'Commencer'
                          : 'Suivant',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
