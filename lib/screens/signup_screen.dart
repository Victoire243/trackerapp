import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackerapp/utils/signup_services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  final String routeName = '/signup'; // Nom de la route pour cet écran

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Contrôleurs pour les champs de saisie
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Clé pour valider le formulaire
  bool _obscureText = true; // Contrôle de la visibilité du mot de passe

  // Fonction pour gérer l'inscription de l'utilisateur
  signupUser() async {
    try {
      // Création d'un compte utilisateur avec Firebase
      // ignore: unused_local_variable
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.toString().trim(),
        password: _passwordController.text.toString().trim(),
      );
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs d'inscription
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le mot de passe fourni est trop faible.'),
          ),
        );
        return;
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le compte existe déjà pour cet email.'),
          ),
        );
        return;
      }
    }
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        // Affiche un message d'erreur si l'inscription échoue
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'inscription.'),
          ),
        );
      } else {
        // Affiche un message de succès et ajoute l'utilisateur à la base de données
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie. Vous pouvez vous connecter.'),
            duration: Duration(seconds: 2),
          ),
        );
        addNewUserToDataBase(
          _usernameController.text.toString().trim(),
          _emailController.text.toString().trim(),
          _phoneController.text,
          [], // Liste vide pour les véhicules
        );
        Navigator.pop(context); // Retourne à l'écran précédent
      }
    });
  }

  @override
  void dispose() {
    // Libère les ressources des contrôleurs
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Conception de l'écran d'inscription
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                // Affiche le titre de l'application
                height: MediaQuery.of(context).size.height * 0.2,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20),
                child: RichText(
                  text: const TextSpan(
                    text: "V",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Tracker",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 124, 173),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  // Formulaire d'inscription
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 0, 124, 173),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: <Widget>[
                        const Text(
                          "INSCRIPTION", // Titre du formulaire
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Champ pour le nom d'utilisateur
                        TextFormField(
                          controller: _usernameController,
                          clipBehavior: Clip.antiAlias,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "Nom d'utilisateur",
                            labelStyle: TextStyle(color: Colors.white),
                            hintText: "Entrez votre nom d'utilisateur",
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(
                              Icons.person,
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
                              return "Veuillez entrer votre nom d'utilisateur";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Champ pour le numéro de téléphone
                        IntlPhoneField(
                          controller: _phoneController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "Téléphone",
                            labelStyle: TextStyle(color: Colors.white),
                            hintText: "Entrez votre numéro de téléphone",
                            hintStyle: TextStyle(color: Colors.white70),
                            counterText: "",
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 0, 73, 102),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          initialCountryCode: 'CD', // Code pays par défaut
                          languageCode: 'fr', // Langue française
                          // ignore: deprecated_member_use
                          searchText: 'Rechercher un pays',
                          invalidNumberMessage: "Numéro invalide",
                          dropdownTextStyle: const TextStyle(color: Colors.white),
                          dropdownIcon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Champ pour l'email
                        TextFormField(
                          controller: _emailController,
                          clipBehavior: Clip.antiAlias,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: Colors.white),
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
                        const SizedBox(height: 10),
                        // Champ pour le mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          textInputAction: TextInputAction.next,
                          clipBehavior: Clip.antiAlias,
                          style: const TextStyle(color: Colors.white),
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
                        const SizedBox(height: 10),
                        // Champ pour confirmer le mot de passe
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureText,
                          textInputAction: TextInputAction.done,
                          clipBehavior: Clip.antiAlias,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Confirmer mot de passe",
                            labelStyle: const TextStyle(color: Colors.white),
                            hintText: "Confirmer votre mot de passe",
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
                                  _obscureText = !_obscureText;
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
                              return "Veuillez confirmer votre mot de passe";
                            }
                            if (value != _passwordController.text) {
                              return "Les mots de passe ne correspondent pas";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Bouton pour créer un compte
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Appelle la fonction d'inscription
                                signupUser();
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
                              "CREER UN COMPTE",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 124, 173),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Lien pour se connecter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "Vous avez déjà un compte ?",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Retourne à l'écran de connexion
                              },
                              child: const Text(
                                " Connectez-vous",
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
