import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirestoreDatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<Map<String, double>> realTimeCoordinatesStream() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final lat = data['lat'] as double;
      final lng = data['lng'] as double;
      return {'lat': lat, 'lng': lng};
    });
  }
}
