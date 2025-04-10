import 'package:flutter/material.dart';
import 'package:trackerapp/utils/user_services.dart';

// ignore: must_be_immutable
class VehiclesMenu extends StatefulWidget {
  final String userEmail;
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
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _vehiclePlateController = TextEditingController();
  final TextEditingController _gpsArduinoIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late List<String> userVehicles = widget.userVehicles;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    _vehiclePlateController.dispose();
    _gpsArduinoIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
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
            // Form to add new vehicle
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    'Ajouter un véhicule',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
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
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Ajouter le véhicule à la base de données
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
                        // Mettre à jour la liste des véhicules de l'utilisateur
                        setState(() {
                          userVehicles.add(_vehicleController.text);
                        });
                        // Afficher un message de succès
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Véhicule ${_vehicleController.text} ajouté avec succès!',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Réinitialiser les champs du formulaire
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
