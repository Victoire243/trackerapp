import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackerapp/firebase_options.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase before the app starts
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
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 124, 173)),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      routes: myRoutes(),
      initialRoute: '/',
    );
  }
}