import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackerapp/utils/database_services.dart';
import 'package:trackerapp/utils/location.dart';
import 'package:trackerapp/models/location_model.dart';
import 'package:trackerapp/components/info_menu.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trackerapp/utils/user_services.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  final String routeName = '/map'; // Nom de la route pour cet écran

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Position initiale de la caméra sur la carte
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-2.9722139, 25.9196359),
    zoom: 15,
  );

  late StreamSubscription<Map<String, double>>? locationStreamSubscription;
  PositionModel userPosition = PositionModel(latitude: 0, longitude: 0); // Position utilisateur
  bool _isDrawingPolygon = false; // Mode dessin de polygone
  MapType _mapType = MapType.hybrid; // Type de carte (hybride par défaut)
  Set<Marker> markers = {}; // Ensemble des marqueurs sur la carte

  // Liste des coordonnées pour tracer une polyline (itinéraire)
  List<LatLng> _polylineCoordinates = [];
  Set<Polyline> _polylines = {};

  Set<Polygon> _polygons = {}; // Ensemble des polygones (zones sécurisées)
  List<LatLng> _polygonLatLngs = []; // Points du polygone
  Timer? _notificationTimer; // Timer pour les notifications périodiques
  bool _isOutsideZone = false; // Indique si le véhicule est hors de la zone sécurisée
  final int _notificationFrequency = 60; // Fréquence des notifications en secondes

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Initialisation des notifications
    _initializePolygon(); // Chargement des polygones de sécurité
    locationStreamSubscription = FirestoreDatabaseService().realTimeCoordinatesStream().listen((event) async {
      // Écoute des changements de position en temps réel
      final PositionModel position = PositionModel(
        latitude: event['lat']!,
        longitude: event['lng']!,
      );

      // Vérifie si le véhicule est dans la zone sécurisée
      if (_polygonLatLngs.isNotEmpty) {
        bool isInZone = isPointInPolygon(LatLng(position.latitude, position.longitude), _polygonLatLngs);

        if (!isInZone && !_isOutsideZone) {
          // Le véhicule vient de sortir de la zone
          _isOutsideZone = true;
          _showNotification(
            "Alerte de sécurité",
            "Le véhicule est sorti de la zone sécurisée.",
          );
          _startNotificationTimer();
        } else if (isInZone && _isOutsideZone) {
          // Le véhicule est revenu dans la zone
          _isOutsideZone = false;
          _stopNotificationTimer();
          _showNotification(
            "Information",
            "Le véhicule est revenu dans la zone sécurisée.",
          );
        }
      }

      try {
        // Mise à jour de la position du véhicule sur la carte
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
        setState(() {
          markers.add(
            Marker(
              markerId: const MarkerId('Véhicule'),
              position: LatLng(position.latitude, position.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: const InfoWindow(title: 'Véhicule', snippet: 'Position actuelle'),
            ),
          );
        });
        controller.showMarkerInfoWindow(const MarkerId('Véhicule'));
      } catch (e) {
        debugPrint("Erreur lors de la mise à jour de la carte : $e");
      }
    }, onError: (error) {
      debugPrint("Erreur du flux : $error");
    });
  }

  // Démarre un timer pour envoyer des notifications périodiques
  void _startNotificationTimer() {
    _stopNotificationTimer(); // Annule le timer précédent s'il existe
    _notificationTimer = Timer.periodic(Duration(seconds: _notificationFrequency), (timer) {
      if (_isOutsideZone) {
        _showNotification(
          "Alerte de sécurité",
          "Le véhicule est toujours en dehors de la zone sécurisée.",
        );
      } else {
        _stopNotificationTimer();
      }
    });
  }

  // Arrête le timer des notifications
  void _stopNotificationTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  @override
  void dispose() {
    // Annule les abonnements et nettoie les ressources
    if (locationStreamSubscription != null) {
      locationStreamSubscription!.cancel().then((_) {
        locationStreamSubscription = null;
      }).catchError((error) {
        debugPrint("Erreur lors de l'annulation du flux : $error");
      });
    }
    _stopNotificationTimer();
    flutterLocalNotificationsPlugin.cancelAll();
    if (!_controller.isCompleted) return super.dispose();
    _controller.future.then((controller) {
      controller.dispose();
    }).catchError((error) {
      debugPrint("Erreur lors de la libération du contrôleur : $error");
    });
    super.dispose();
  }

  // Initialise les notifications locales
  void _initializeNotifications() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Affiche une notification locale
  Future<void> _showNotification(String title, String body) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  // Initialise les polygones de sécurité
  void _initializePolygon() async {
    try {
      _polygonLatLngs = await getCurrentUserPolygone();
      if (mounted) {
        setState(() {
          if (_polygonLatLngs.isNotEmpty) {
            _polygons = {
              Polygon(
                polygonId: const PolygonId("zone_securisee"),
                points: _polygonLatLngs,
                fillColor: Colors.green.withOpacity(0.3),
                strokeColor: Colors.green,
                strokeWidth: 2,
              )
            };
          }
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation du polygone : $e");
    }
  }

  void _toggleDrawingMode() {
    if (_isDrawingPolygon) {
      savePolygonCoordinates(_polygonLatLngs);
      _polygonLatLngs = []; // Reset the polygon points when entering drawing mode
    }
    setState(() {
      _isDrawingPolygon = !_isDrawingPolygon;
    });
  }

  void _addPoint(LatLng point) {
    _polygonLatLngs.add(point);
    setState(() {
      _polygons = {
        Polygon(
          polygonId: const PolygonId("zone_securisee"),
          points: _polygonLatLngs,
          fillColor: Colors.green.withOpacity(0.3),
          strokeColor: Colors.green,
          strokeWidth: 2,
        )
      };
    });
  }

  // Vérifie si un point est dans un polygone
  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      LatLng a = polygon[j];
      LatLng b = polygon[j + 1];
      if (rayCastIntersect(point, a, b)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1; // true si impair (à l'intérieur), false si pair (à l'extérieur)
  }

  bool rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }

    double m = (bY - aY) / (bX - aX);
    double x = (pY - aY) / m + aX;
    return x > pX;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Localisation", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: const DrawerButton(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 0, 124, 173),
          actions: [
            IconButton(
              icon: Icon(_isDrawingPolygon ? Icons.check : Icons.edit, color: Colors.white),
              onPressed: () {
                if (_isDrawingPolygon) {
                  _toggleDrawingMode();
                } else {
                  _toggleDrawingMode();
                }
              },
              color: Colors.white,
            ),
            // Supprimer le polygone
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                setState(() {
                  _polygons = {};
                  _polygonLatLngs = [];
                });
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  "Menu",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 124, 173),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const ListTile(
                leading: Icon(
                  Icons.home,
                  color: Color.fromARGB(255, 0, 124, 173),
                ),
                title: Text(
                  "Accueil",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 124, 173),
                    fontSize: 14,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.directions_car,
                  color: Color.fromARGB(255, 0, 124, 173),
                ),
                title: const Text(
                  "Mon Véhicule",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 124, 173),
                    fontSize: 14,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final snapshot = await FirestoreDatabaseService().realTimeCoordinatesStream().first;
                  final PositionModel position = PositionModel(
                    latitude: snapshot['lat']!,
                    longitude: snapshot['lng']!,
                  );
                  final GoogleMapController controller = await _controller.future;
                  controller
                      .animateCamera(CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 20));
                },
              ),
              const ListTile(
                leading: Icon(
                  Icons.map,
                  color: Color.fromARGB(255, 0, 124, 173),
                ),
                title: Text(
                  "Trouver mon véhicule",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 124, 173),
                    fontSize: 14,
                  ),
                ),
              ),
              const ListTile(
                leading: Icon(
                  Icons.security,
                  color: Color.fromARGB(255, 0, 124, 173),
                ),
                title: Text(
                  "Définir une zone de sécurité",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 124, 173),
                    fontSize: 14,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Color.fromARGB(255, 0, 124, 173),
                ),
                title: const Text(
                  "Ma position",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 124, 173),
                    fontSize: 14,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final Position position = await Geolocator.getCurrentPosition();
                  final GoogleMapController controller = await _controller.future;
                  controller.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
                },
              ),
              const Divider(
                color: Color.fromARGB(255, 0, 124, 173),
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 0, 124, 173),
                ),
                title: const Text(
                  "Retour",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 124, 173),
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                StreamBuilder<Map<String, double>>(
                  stream: FirestoreDatabaseService().realTimeCoordinatesStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final PositionModel position = PositionModel(
                      latitude: snapshot.data!['lat']!,
                      longitude: snapshot.data!['lng']!,
                    );
                    // Met à jour les coordonnées de la polyline
                    _polylineCoordinates.add(LatLng(position.latitude, position.longitude));
                    _polylines.add(
                      Polyline(
                        polylineId: const PolylineId('polyline'),
                        color: Colors.blue,
                        width: 5,
                        points: _polylineCoordinates,
                        jointType: JointType.round,
                        startCap: Cap.roundCap,
                        endCap: Cap.roundCap,
                      ),
                    );
                    markers.add(
                      Marker(
                        markerId: const MarkerId('Véhicule'),
                        position: LatLng(position.latitude, position.longitude),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        infoWindow: const InfoWindow(title: 'Véhicule', snippet: 'Position actuelle'),
                      ),
                    );
                    return GoogleMap(
                      initialCameraPosition: _initialCameraPosition,
                      mapType: _mapType,
                      markers: markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      trafficEnabled: true,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      polylines: _polylines,
                      polygons: _polygons,
                      onTap: (LatLng point) {
                        if (_isDrawingPolygon) {
                          _addPoint(point);
                        }
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  child: Opacity(
                    opacity: 0.8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.person_pin_circle),
                                  onPressed: () async {
                                    try {
                                      final bool isLocationGranted =
                                          await StreamLocationService.askLocationPermission();
                                      if (isLocationGranted) {
                                        final Position position = await Geolocator.getCurrentPosition();
                                        final GoogleMapController controller = await _controller.future;
                                        controller.animateCamera(
                                            CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
                                      }
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  color: const Color.fromARGB(255, 0, 124, 173),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.directions_car),
                                  onPressed: () async {
                                    final snapshot = await FirestoreDatabaseService().realTimeCoordinatesStream().first;
                                    final PositionModel position = PositionModel(
                                      latitude: snapshot['lat']!,
                                      longitude: snapshot['lng']!,
                                    );
                                    final GoogleMapController controller = await _controller.future;
                                    controller.animateCamera(
                                        CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 20));
                                    controller.showMarkerInfoWindow(const MarkerId('Véhicule'));
                                  },
                                  color: const Color.fromARGB(255, 0, 124, 173),
                                ),
                                DropdownButton(
                                  items: const [
                                    DropdownMenuItem(
                                      value: MapType.normal,
                                      child: Text("Normal"),
                                    ),
                                    DropdownMenuItem(
                                      value: MapType.satellite,
                                      child: Text("Satellite"),
                                    ),
                                    DropdownMenuItem(
                                      value: MapType.terrain,
                                      child: Text("Terrain"),
                                    ),
                                    DropdownMenuItem(
                                      value: MapType.hybrid,
                                      child: Text("Hybrid"),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _mapType = value as MapType;
                                    });
                                  },
                                  underline: Container(),
                                  style: const TextStyle(color: Color.fromARGB(255, 0, 124, 173)),
                                  value: _mapType,
                                  iconEnabledColor: const Color.fromARGB(255, 0, 124, 173),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.info,
                                    color: Colors.green,
                                  ),
                                  onPressed: () async {
                                    final snapshot = await FirestoreDatabaseService().realTimeCoordinatesStream().first;
                                    final PositionModel vehiclePosition = PositionModel(
                                      latitude: snapshot['lat']!,
                                      longitude: snapshot['lng']!,
                                    );
                                    final Position position = await Geolocator.getCurrentPosition();
                                    final PositionModel userPosition = PositionModel(
                                      latitude: position.latitude,
                                      longitude: position.longitude,
                                    );
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return InfoMenu(
                                          userPosition: userPosition,
                                          vehiclePosition: vehiclePosition,
                                        );
                                      },
                                    );
                                  },
                                  color: const Color.fromARGB(255, 0, 124, 173),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
