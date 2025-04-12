import 'package:flutter/material.dart';
import 'package:trackerapp/utils/user_services.dart';

// Menu pour gérer les véhicules de l'utilisateur
class VehiclesMenu extends StatefulWidget {
  final String userEmail; // Email de l'utilisateur
  final List<String> userVehicles; // Liste des véhicules de l'utilisateur

  const VehiclesMenu({
    super.key,
    required this.userEmail,
    required this.userVehicles,
  });

  @override
  State<VehiclesMenu> createState() => _VehiclesMenuState();
}

class _VehiclesMenuState extends State<VehiclesMenu> {
  // Contrôleurs pour les champs de saisie
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _vehiclePlateController = TextEditingController();
  final TextEditingController _gpsArduinoIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Clé pour valider le formulaire
  late List<String> userVehicles = widget.userVehicles; // Initialisation des véhicules

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Libère les ressources des contrôleurs
    _vehicleController.dispose();
    _vehiclePlateController.dispose();
    _gpsArduinoIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9, // Hauteur du menu
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Couleur de fond
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            // Formulaire pour ajouter un nouveau véhicule
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    'Ajouter un véhicule', // Titre du formulaire
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Champ pour le nom du véhicule
                  TextFormField(
                    controller: _vehicleController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: "Nom du véhicule",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom du véhicule';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Champ pour la plaque d'immatriculation
                  TextFormField(
                    controller: _vehiclePlateController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: "Plaque d'immatriculation",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la plaque d\'immatriculation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Champ pour l'ID GPS Arduino
                  TextFormField(
                    controller: _gpsArduinoIdController,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: "ID GPS Arduino",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'ID GPS Arduino';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Bouton pour ajouter le véhicule
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Vérifie si l'utilisateur a déjà un véhicule enregistré
                        if (userVehicles.isEmpty) {
                          addVehicleToUser(
                            _vehicleController.text,
                            _vehiclePlateController.text,
                            _gpsArduinoIdController.text,
                          );
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vous avez déjà un véhicule enregistré',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        // Met à jour la liste des véhicules de l'utilisateur
                        setState(() {
                          userVehicles.add(_vehicleController.text);
                        });
                        // Affiche un message de succès
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Véhicule ${_vehicleController.text} ajouté avec succès!',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Réinitialise les champs du formulaire
                        _vehicleController.clear();
                        _vehiclePlateController.clear();
                        _gpsArduinoIdController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ajouter le véhicule'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void removeVehicle(String userVehicl) {}
}
