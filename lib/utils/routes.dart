import 'package:flutter/material.dart';
import 'package:trackerapp/screens/signup_screen.dart';
import 'package:trackerapp/screens/welcome_screen.dart';
import 'package:trackerapp/screens/home_screen.dart';
import 'package:trackerapp/screens/map_screen.dart';

// Fonction qui retourne les routes de l'application
Map<String, Widget Function(BuildContext)> myRoutes() {
  return {
    // Route pour l'écran de bienvenue
    const WelcomeScreen().routeName: (context) => const WelcomeScreen(),
    // Route pour l'écran d'inscription
    const SignUpScreen().routeName: (context) => const SignUpScreen(),
    // Route pour l'écran d'accueil
    const HomeScreen().routeName: (context) => const HomeScreen(),
    // Route pour l'écran de la carte
    const MapScreen().routeName: (context) => const MapScreen(),
  };
}
