// Ajouter les informations d'un nouvel utilisateur dans Firestore

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addNewUserToDataBase(String name, String email, String phone, List vehicles) {
  // Référence à la collection "users" dans Firestore
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  // Ajoute un nouvel utilisateur avec ses informations
  return users
      .add({
        'name': name, // Nom de l'utilisateur
        'email': email, // Email de l'utilisateur
        'phone': phone, // Numéro de téléphone
        'vehicles': vehicles, // Liste des véhicules
        'signupDate': DateTime.now(), // Date d'inscription
        'polygone': [] // Zone de sécurité (vide par défaut)
      })
      .then((value) => print("Nouveau utilisateur ajouté !")) // Succès
      .catchError((error) => print("Erreur d'ajout : $error")); // Gestion des erreurs
}
