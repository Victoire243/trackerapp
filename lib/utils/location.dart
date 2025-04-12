import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class StreamLocationService {
  // Paramètres pour le suivi de la localisation (distance minimale entre deux mises à jour)
  static const LocationSettings _locationSettings = LocationSettings(distanceFilter: 1);

  // Indicateur pour vérifier si la permission de localisation est accordée
  static bool _isLocationGranted = false;

  // Flux pour écouter les changements de position en temps réel
  static Stream<Position>? get onLocationChanged {
    if (_isLocationGranted) {
      return Geolocator.getPositionStream(locationSettings: _locationSettings);
    }
    return null; // Retourne null si la permission n'est pas accordée
  }

  // Demande la permission d'accès à la localisation
  static Future<bool> askLocationPermission() async {
    _isLocationGranted = await Permission.location.request().isGranted;
    return _isLocationGranted; // Retourne true si la permission est accordée
  }
}
