import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//  Caching mechanism for user data
class UserCache {
  // ignore: unused_field
  static String? _userEmail;
  static DocumentSnapshot? _userDocument;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  static void setUserEmail(String email) {
    _userEmail = email;
  }

  static void setUserDocument(DocumentSnapshot doc) {
    _userDocument = doc;
    _lastFetchTime = DateTime.now();
  }

  static bool isCacheValid() {
    if (_userDocument == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  static void clearCache() {
    _userEmail = null;
    _userDocument = null;
    _lastFetchTime = null;
  }
}

// Optimized getCurrentUser function to prevent repetitive queries
Future<DocumentSnapshot> getCurrentUserDoc() async {
  // Use cached document if available
  if (UserCache.isCacheValid() && UserCache._userDocument != null) {
    return UserCache._userDocument!;
  }

  // Otherwise, fetch from Firebase
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("No user is currently signed in.");
  }

  String email = user.email ?? "";
  UserCache.setUserEmail(email);

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot query = await firestore.collection('users').where('email', isEqualTo: email).limit(1).get();

  if (query.docs.isEmpty) {
    throw Exception("No user found with the provided email.");
  }

  // Cache the result
  UserCache.setUserDocument(query.docs.first);
  return query.docs.first;
}

// Get the current user's ID
Future<String> getCurrentUserId() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("No user is currently signed in.");
  }
  return user.uid;
}

// Get the current user's email
Future<String> getCurrentUserEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("No user is currently signed in.");
  }
  return user.email ?? "No email available";
}

// Get the current user's name
Future<String> getCurrentUserName() async {
  DocumentSnapshot doc = await getCurrentUserDoc();
  return doc['name'] as String;
}

// Get the current user's phone number
Future<String> getCurrentUserPhoneNumber() async {
  DocumentSnapshot doc = await getCurrentUserDoc();
  return doc['phone'] as String;
}

// Get the current user's list of vehicles
Future<List<String>> getCurrentUserVehicles() async {
  DocumentSnapshot doc = await getCurrentUserDoc();
  return List<String>.from(doc['vehicles']);
}

// Add a new vehicle to the current user's list of vehicles
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

// Modify a vehicle in the current user's list of vehicles
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

// Logout the current user
Future<void> logoutUser() async {
  await FirebaseAuth.instance.signOut();
}

// Save polygone'user safety to firestore
Future<void> savePolygonCoordinates(List<LatLng> polygonLatLngs) async {
  String email = await getCurrentUserEmail();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot query = await firestore.collection('users').where('email', isEqualTo: email).limit(1).get();

  if (query.docs.isEmpty) {
    throw Exception("No user found with the provided email.");
  }

  // Convertir les LatLng en liste de maps contenant lat/lng
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

// Get current user polygones safaty zone
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
