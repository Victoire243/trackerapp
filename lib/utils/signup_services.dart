// Add new user informations to firestore

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addNewUserToDataBase(String name, String email, String phone, List vehicles) {
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  return users
      .add({
        'name': name,
        'email': email,
        'phone': phone,
        'vehicles': vehicles,
        'signupDate': DateTime.now(),
        'polygone': []
      })
      .then((value) => print("Nouveau utilisateur ajouté !"))
      .catchError((error) => print("Erreur d'ajout : $error"));
}
