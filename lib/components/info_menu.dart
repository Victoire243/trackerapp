import 'package:flutter/material.dart';
import 'package:trackerapp/models/location_model.dart';

class InfoMenu extends StatelessWidget {
  const InfoMenu({super.key, required this.userPosition, required this.vehiclePosition});
  final PositionModel userPosition; // Position actuelle de l'utilisateur
  final PositionModel vehiclePosition; // Position actuelle du véhicule

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {}, // Action à effectuer lors de la fermeture du BottomSheet
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16), // Marges internes
          child: Column(
            children: [
              // Affiche les informations de position de l'utilisateur
              const Text(
                "Position de l'utilisateur",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Latitude: ${userPosition.latitude}",
              ),
              Text(
                "Longitude: ${userPosition.longitude}",
              ),
              const SizedBox(height: 16), // Espacement vertical
              // Affiche les informations de position du véhicule
              const Text(
                "Position du véhicule",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Latitude: ${vehiclePosition.latitude}",
              ),
              Text(
                "Longitude: ${vehiclePosition.longitude}",
              ),
            ],
          ),
        );
      },
    );
  }
}
