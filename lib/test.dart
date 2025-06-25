import 'package:flutter/material.dart';
import 'package:parking_car/PageAccueil.dart';
import 'package:parking_car/notifications.dart';

import 'package:parking_car/inscription.dart';

class Connexion extends StatefulWidget {
  const Connexion ({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/yet.jpg"),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 290,
                    height: 70,
                    transform: Matrix4.translationValues(60, -60, 0),
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "Connection",
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ),
                  ),

                  // Champ email
                  SizedBox(
                    width: 400,
                    height: 100,
                   child: Padding(
                    padding:EdgeInsets.only(top: 50),
                     child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Entrez votre email",
                        prefixIcon: Icon(
                          Icons.alternate_email_sharp,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _emailController.clear();
                          },
                          icon: Icon(
                            Icons.close_sharp,
                            color: Colors.white,
                          ),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ), ),
                  ),


                // Ici c'est l'icon tout en haut
                  Positioned(
                    top: -130,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Icon(
                        Icons.person_pin,
                        size: 100,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              // Champ mot de passe
              SizedBox(
                width: 400,
                height: 100,
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: TextFormField(
                    controller: _passwordcontroller,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Entrez votre mot de passe",
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: Colors.white,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _passwordcontroller.clear();
                        },
                        icon: Icon(
                          Icons.clear_sharp,
                          color: Colors.white,
                        ),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 0,
              ),

              // Texte mot de passe oublié
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(right: 1, bottom:0,top: 85,left: 230),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        print("Mot de passe oublié cliqué");
                        Navigator.push(context,MaterialPageRoute(builder: (context) =>NotificationPage()));
                        // Tu peux mettre ici Navigator.push() vers une autre page
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: Text(
                          "Mot de passe oublié ?",
                          style: TextStyle(
                            color: Colors.yellow,
                            decoration: TextDecoration.overline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bouton connexion cliquable avec effet splash
              SizedBox(
                width: 100,
                height: 130,
                child: Padding(padding: EdgeInsets.only(top: 70,bottom: 9),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Pageaccueil()), // page suivante
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 60),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 10,
                    shadowColor: Colors.black,
                  ),
                  child: Text(
                    "Connexion",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
              ),
              
              // Espace entre le bouton connexion et le texte creer un nouveau compte
              SizedBox(
                height: 55,
              ),
              // Text en bas crrer un nouveau compte
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding:const EdgeInsets.only(bottom: 10.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        print("Vous n'avez pas de compte? cliquer ici pour creer un compte");
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Inscription()));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                           horizontal: 5),
                          child: Text("Vous n'avez pas de compte? cliquer ici pour creer un compte",
                          style: TextStyle(fontSize: 15,
                          decoration: TextDecoration.underline,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue),
                          ),
                          
                           ),
                    ),
                  ),
                  
                ),
                
              )
            ],
          ),
        ),
      ),
      )
      
    );
  }
}