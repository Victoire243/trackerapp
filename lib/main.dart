import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackerapp/firebase_options.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase avant le démarrage de l'application
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const VTrackerApp());
}

class VTrackerApp extends StatelessWidget {
  const VTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Définition du thème principal de l'application
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 124, 173)),
        useMaterial3: true,
        fontFamily: "Poppins", // Police personnalisée
      ),
      routes: myRoutes(), // Définition des routes de l'application
      initialRoute: '/', // Route initiale
    );
  }
}