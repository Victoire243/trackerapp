import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  final String routeName = '/'; // Nom de la route pour cet écran

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Contrôleurs pour les champs de saisie (email et mot de passe)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Clé pour valider le formulaire
  bool _obscureText = true; // Contrôle de la visibilité du mot de passe

  // Fonction pour gérer l'authentification de l'utilisateur
  authensignin() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.toString().trim(),
        password: _passwordController.text.toString().trim(),
      );
      if (credential.user != null) {
        // Efface les champs après connexion réussie
        _emailController.clear();
        _passwordController.clear();
        Navigator.pushNamed(context, '/home'); // Redirige vers l'écran d'accueil
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        // Affiche un message d'erreur en cas de problème
        _emailController.clear();
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email ou mot de passe invalide'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Libère les ressources des contrôleurs
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Empêche de quitter l'écran sans confirmation
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          } else {
            // Affiche une boîte de dialogue pour confirmer la sortie
            await showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.18,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 0, 124, 173),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Voulez-vous vraiment quitter l'application ?", // Message de confirmation
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Annule la sortie
                            },
                            child: const Text(
                              "NON",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Fermer le modal
                              Navigator.pop(context);
                              Navigator.pop(context);
                              SystemNavigator.pop(); // Quitte l'application
                            },
                            child: const Text(
                              "OUI, QUITTER",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          }
        }
      },
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          // Conception de l'écran de bienvenue
          decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 124, 173)),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Image.asset(
                  "assets/images/tracker_logo.png", // Logo de l'application
                  width: MediaQuery.of(context).size.width * 0.95,
                ),
                const Text(
                  "Bienvenue sur VTracker", // Message de bienvenue
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: Form(
                    key: _formKey, // Formulaire pour la connexion
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: <Widget>[
                        // Champ de saisie pour l'email
                        TextFormField(
                          controller: _emailController,
                          clipBehavior: Clip.antiAlias,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white),
                            hintText: "Entrez votre email",
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 0, 73, 102),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez entrer votre email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Champ de saisie pour le mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          clipBehavior: Clip.antiAlias,
                          style: const TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            labelStyle: const TextStyle(color: Colors.white),
                            hintText: "Entrez votre mot de passe",
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText; // Alterne la visibilité
                                });
                              },
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 0, 73, 102),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez entrer votre mot de passe";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Bouton pour se connecter
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Perform login action
                                authensignin(); // Appelle la fonction de connexion
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.grey; // Change color when pressed
                                  }
                                  return Colors.white; // Default color
                                },
                              ),
                            ),
                            child: const Text(
                              "SE CONNECTER",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 124, 173),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Lien pour s'inscrire
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "Vous n'avez pas de compte ?",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Clear the text fields
                                _emailController.clear();
                                _passwordController.clear();
                                Navigator.pushNamed(context, '/signup'); // Redirige vers l'inscription
                              },
                              child: const Text(
                                " Inscrivez-vous",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
