import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirestoreDatabaseService {
  // Référence à la base de données Firebase Realtime Database
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Flux en temps réel des coordonnées (latitude et longitude)
  Stream<Map<String, double>> realTimeCoordinatesStream() {
    return _dbRef.onValue.map((event) {
      // Récupère les données de l'événement
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final lat = data['lat'] as double; // Latitude
      final lng = data['lng'] as double; // Longitude
      return {'lat': lat, 'lng': lng}; // Retourne un map contenant les coordonnées
    });
  }
}
