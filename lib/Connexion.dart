import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:parking_car/PageAccueil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:parking_car/inscription.dart';
import 'package:parking_car/onboarding/Onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkRedirectResult();
  }

  Future<void> _checkRedirectResult() async {
    try {
      final userCredential = await FirebaseAuth.instance.getRedirectResult();
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Pageaccueil()),
        );
      }
    } catch (e) {
      print("Erreur de redirection : $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInEmailPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Pageaccueil()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Erreur inconnue";
      if (e.code == 'user-not-found') {
        message = "Utilisateur non trouvé";
      } else if (e.code == 'wrong-password') {
        message = "Mot de passe incorrect";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithRedirect(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Pageaccueil()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur Google : $e')),
      );
    }
  }
Future<void> _signInWithFacebook() async {
  try {
    if (kIsWeb) {
      // Pour le Web, on utilise directement le provider
      FacebookAuthProvider facebookProvider = FacebookAuthProvider();
      await FirebaseAuth.instance.signInWithRedirect(facebookProvider);
    } else {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success && result.accessToken != null) {
        final accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);

        await FirebaseAuth.instance.signInWithCredential(credential);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Pageaccueil()),
        );
      } else {
        throw Exception("Connexion Facebook annulée ou échouée : ${result.message ?? 'Aucune raison fournie'}");
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur Facebook : $e')),
    );
  }
}


  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer votre email pour réinitialiser.")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email de réinitialisation envoyé.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset("assets/images/symbole.jpg", fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Connectez-vous à Parking car",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Mot de passe",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: _resetPassword,
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signInEmailPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Connexion",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _signInWithGoogle,
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Image.asset('assets/images/google.jpg'),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Google',
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _signInWithFacebook,
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Image.asset('assets/images/facebook.jpg'),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Facebook',
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Inscription()),
                          );
                        },
                        child: const Text(
                          "Pas encore de compte ? Créez-en un",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('onboardingVu');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    },
                    child: const Text(
                      "↺ Réinitialiser l'onboarding",
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

extension on AccessToken {
  String get token => this.token;
}
