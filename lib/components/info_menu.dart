import 'package:flutter/material.dart';
import 'package:trackerapp/models/location_model.dart';

class InfoMenu extends StatelessWidget {
  const InfoMenu({super.key, required this.userPosition, required this.vehiclePosition});
  final PositionModel userPosition;
  final PositionModel vehiclePosition;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "User Position",
              ),
              Text(
                "Latitude: ${userPosition.latitude}",
              ),
              Text(
                "Longitude: ${userPosition.longitude}",
              ),
              const SizedBox(height: 16),
              const Text(
                "Vehicle Position",
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
