import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Mécanisme de mise en cache des données utilisateur
class UserCache {
  // Document utilisateur (mis en cache)
  static DocumentSnapshot? _userDocument;
  // Heure de la dernière mise en cache
  static DateTime? _lastFetchTime;
  // Durée de validité du cache
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Définit l'email de l'utilisateur dans le cache
  static void setUserEmail(String email) {}

  // Définit le document utilisateur dans le cache
  static void setUserDocument(DocumentSnapshot doc) {
    _userDocument = doc;
    _lastFetchTime = DateTime.now();
  }

  // Vérifie si le cache est encore valide
  static bool isCacheValid() {
    if (_userDocument == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  // Efface le cache utilisateur
  static void clearCache() {
    _userDocument = null;
    _lastFetchTime = null;
  }
}

// Fonction optimisée pour obtenir le document utilisateur actuel
Future<DocumentSnapshot> getCurrentUserDoc() async {
  // Utilise le document mis en cache si disponible
  if (UserCache.isCacheValid() && UserCache._userDocument != null) {
    return UserCache._userDocument!;
  }

  // Sinon, récupère les données depuis Firebase
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("Aucun utilisateur n'est actuellement connecté.");
  }

  String email = user.email ?? "";
  UserCache.setUserEmail(email);

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot query = await firestore.collection('users').where('email', isEqualTo: email).limit(1).get();

  if (query.docs.isEmpty) {
    throw Exception("Aucun utilisateur trouvé avec l'email fourni.");
  }

  // Met en cache le résultat
  UserCache.setUserDocument(query.docs.first);
  return query.docs.first;
}

// Récupère l'ID de l'utilisateur actuel
Future<String> getCurrentUserId() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("No user is currently signed in.");
  }
  return user.uid;
}

// Récupère l'email de l'utilisateur actuel
Future<String> getCurrentUserEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("No user is currently signed in.");
  }
  return user.email ?? "No email available";
}

// Récupère le nom de l'utilisateur actuel
Future<String> getCurrentUserName() async {
  DocumentSnapshot doc = await getCurrentUserDoc();
  return doc['name'] as String;
}

// Récupère le numéro de téléphone de l'utilisateur actuel
Future<String> getCurrentUserPhoneNumber() async {
  DocumentSnapshot doc = await getCurrentUserDoc();
  return doc['phone'] as String;
}

// Récupère la liste des véhicules de l'utilisateur actuel
Future<List<String>> getCurrentUserVehicles() async {
  DocumentSnapshot doc = await getCurrentUserDoc();
  return List<String>.from(doc['vehicles']);
}

// Ajoute un nouveau véhicule à la liste des véhicules de l'utilisateur actuel
Future<void> addVehicleToUser(String vehicleName, vehiclePlate, idGpsArduino) async {
  String email = await getCurrentUserEmail();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot query = await firestore.collection('users').where('email', isEqualTo: email).limit(1).get();

  if (query.docs.isEmpty) {
    throw Exception("No user found with the provided email.");
  }

  DocumentReference userDoc = query.docs.first.reference;
  await userDoc.update({
    'vehicles': FieldValue.arrayUnion([vehicleName, vehiclePlate, idGpsArduino]),
  });
}

// Modifie un véhicule dans la liste des véhicules de l'utilisateur actuel
Future<void> modifyVehicleInUser(String oldVehicleName, String newVehicleName) async {
  String email = await getCurrentUserEmail();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot query = await firestore.collection('users').where('email', isEqualTo: email).limit(1).get();

  if (query.docs.isEmpty) {
    throw Exception("No user found with the provided email.");
  }

  DocumentReference userDoc = query.docs.first.reference;
  await userDoc.update({
    'vehicles': FieldValue.arrayRemove([oldVehicleName]),
  });
  await userDoc.update({
    'vehicles': FieldValue.arrayUnion([newVehicleName]),
  });
}

// Déconnecte l'utilisateur actuel
Future<void> logoutUser() async {
  await FirebaseAuth.instance.signOut();
}

// Sauvegarde les coordonnées d'un polygone de sécurité dans Firestore
Future<void> savePolygonCoordinates(List<LatLng> polygonLatLngs) async {
  String email = await getCurrentUserEmail();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot query = await firestore.collection('users').where('email', isEqualTo: email).limit(1).get();

  if (query.docs.isEmpty) {
    throw Exception("Aucun utilisateur trouvé avec l'email fourni.");
  }

  // Convertit les LatLng en liste de maps contenant latitude/longitude
  List<Map<String, double>> serializedPolygon = polygonLatLngs
      .map((point) => {
            'latitude': point.latitude,
            'longitude': point.longitude,
          })
      .toList();

  DocumentReference userDoc = query.docs.first.reference;
  await userDoc.update({
    'polygone': serializedPolygon,
  });
}

// Récupère les polygones de zone de sécurité de l'utilisateur actuel
Future<List<LatLng>> getCurrentUserPolygone() async {
  String email = await getCurrentUserEmail();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot query = await firestore.collection('users').where('email', isEqualTo: email).limit(1).get();

  try {
    if (query.docs.isEmpty) {
      throw Exception("No user found with the provided email.");
    }

    var polygoneData = query.docs.first['polygone'];
    if (polygoneData == null) return [];

    List<LatLng> result = [];
    for (var point in polygoneData) {
      result.add(LatLng(point['latitude'] as double, point['longitude'] as double));
    }
    return result;
  } catch (e) {
    return [];
  }
}
