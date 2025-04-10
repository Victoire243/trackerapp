import 'package:flutter/material.dart';
import 'package:trackerapp/components/vehicles_menu.dart';
import 'package:trackerapp/utils/user_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  final String routeName = '/home';

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userEmail = '';
  String userName = '';
  String userPhoneNumber = '';
  String userId = ''; // ID de l'utilisateur
  List<String> userVehicles = []; // Liste des véhicules de l'utilisateur
  bool isLoading = true; // Indicateur de chargement
  String vehicleName = '';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserDetails();
  }

  Future<void> _initializeUserDetails() async {
    try {
      userEmail = await getCurrentUserEmail();
      userName = await getCurrentUserName();
      userPhoneNumber = await getCurrentUserPhoneNumber();
      userId = await getCurrentUserId(); // Récupérer l'ID de l'utilisateur
      userVehicles = await getCurrentUserVehicles(); // Récupérer la liste des véhicules
      vehicleName = userVehicles.isNotEmpty ? userVehicles[0] : 'Aucun véhicule'; // Vérifier si la liste est vide
    } catch (e) {
      // Gérer les erreurs si nécessaire
    } finally {
      setState(() {
        isLoading = false; // Les données sont prêtes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await showModalBottomSheet(
            sheetAnimationStyle: AnimationStyle(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 500),
            ),
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.18,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 124, 173),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Voulez-vous revenir à l'écran d'accueil ?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "NON",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Se déconnecter de l'application
                            logoutUser().then((_) {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/');
                            }).catchError((error) {
                              // Afficher un message d'erreur si la déconnexion échoue
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Erreur lors de la déconnexion : $error",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
                          },
                          child: const Text(
                            "OUI, REVENIR",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 124, 173),
          title: RichText(
            text: const TextSpan(
              text: "V",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "Tracker",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
            onPressed: () {
              // TODO : implement help
            },
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                // profil utilisateur
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                          ),
                          const SizedBox(width: 10),
                          isLoading
                              ? const CircularProgressIndicator()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.time_to_leave,
                                          color: Color.fromARGB(255, 0, 124, 173),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          vehicleName,
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 124, 173),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                        ],
                      ),
                    ],
                  ),
                ),
                // capteur status visualisation
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 0, 124, 173),
                  ),
                  child: const Badge(
                    smallSize: 13,
                    backgroundColor: Colors.green,
                    alignment: Alignment.topRight,
                    child: Text("En ligne   ", style: TextStyle(color: Colors.white)),
                  ),
                ),
                GridView(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                  ),
                  children: <Widget>[
                    // Localiser mon vehicule
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/map');
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.location_on, color: Color.fromARGB(255, 0, 124, 173), size: 30),
                            SizedBox(height: 5),
                            Text(
                              "Localiser mon véhicule",
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Trouver mon véhicule
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO : implement trouver mon véhicule
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.directions, color: Color.fromARGB(255, 0, 124, 173), size: 30),
                            SizedBox(height: 5),
                            Text(
                              "Trouver mon véhicule",
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    //  Historique
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO : implement historique
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.history, color: Color.fromARGB(255, 0, 124, 173), size: 30),
                            SizedBox(height: 5),
                            Text(
                              "Historique",
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    //  Mes véhicules
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            sheetAnimationStyle:
                                AnimationStyle(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return VehiclesMenu(
                                userEmail: userEmail,
                                userVehicles: userVehicles,
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.time_to_leave, color: Color.fromARGB(255, 0, 124, 173), size: 30),
                            SizedBox(height: 5),
                            Text(
                              "Ajouter un véhicule",
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Rapports et statistiques
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO : implement rapports et statistiques
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.bar_chart, color: Color.fromARGB(255, 0, 124, 173), size: 30),
                            SizedBox(height: 5),
                            Text(
                              "Rapports",
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Informations
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO : implement informations
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.info, color: Color.fromARGB(255, 0, 124, 173), size: 30),
                            SizedBox(height: 5),
                            Text(
                              "Informations",
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Mode économie d'énergie
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO : implement mode économie d'énergie
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.battery_charging_full, color: Color.fromARGB(255, 0, 124, 173), size: 30),
                            SizedBox(height: 5),
                            Text(
                              "Mode économie d'énergie",
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Nous contacter
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO : implement nous contacter
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(5)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.email, color: Color.fromARGB(255, 0, 124, 173), size: 30),
                            SizedBox(height: 5),
                            Text(
                              "Nous contacter",
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
