import 'package:flutter/material.dart';
import 'package:trackerapp/components/vehicles_menu.dart';
import 'package:trackerapp/utils/user_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  final String routeName = '/home'; // Nom de la route pour cet écran

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables pour stocker les informations utilisateur
  String userEmail = '';
  String userName = '';
  String userPhoneNumber = '';
  String userId = ''; // ID de l'utilisateur
  List<String> userVehicles = []; // Liste des véhicules de l'utilisateur
  bool isLoading = true; // Indicateur de chargement
  String vehicleName = ''; // Nom du véhicule principal

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserDetails(); // Initialisation des détails utilisateur
  }

  Future<void> _initializeUserDetails() async {
    try {
      // Récupération des informations utilisateur depuis Firebase
      userEmail = await getCurrentUserEmail();
      userName = await getCurrentUserName();
      userPhoneNumber = await getCurrentUserPhoneNumber();
      userId = await getCurrentUserId(); // Récupérer l'ID de l'utilisateur
      userVehicles = await getCurrentUserVehicles(); // Récupérer la liste des véhicules
      vehicleName = userVehicles.isNotEmpty ? userVehicles[0] : 'Aucun véhicule'; // Vérifie si la liste est vide
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
      canPop: false, // Empêche de quitter l'écran sans confirmation
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          // Affiche une boîte de dialogue pour confirmer le retour à l'écran d'accueil
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
                      "Voulez-vous revenir à l'écran d'accueil ?", // Message de confirmation
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
                            Navigator.pop(context); // Annule l'action
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
                            // Déconnexion de l'utilisateur
                            logoutUser().then((_) {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/');
                            }).catchError((error) {
                              // Affiche un message d'erreur si la déconnexion échoue
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
              text: "V", // Partie du titre en orange
              style: TextStyle(
                color: Colors.orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "Tracker", // Partie du titre en blanc
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
              // TODO : Implémenter l'aide
            },
          ),
        ),
        body: Container(
          // Conception de l'écran principal
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                // Profil utilisateur
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30, // Avatar utilisateur
                          ),
                          const SizedBox(width: 10),
                          isLoading
                              ? const CircularProgressIndicator() // Indicateur de chargement
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName, // Nom de l'utilisateur
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
                                          vehicleName, // Nom du véhicule
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
                // Indicateur de statut en ligne
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
                // Grille des options principales
                GridView(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Nombre de colonnes
                    childAspectRatio: 1, // Ratio largeur/hauteur
                  ),
                  children: <Widget>[
                    // Bouton pour localiser le véhicule
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/map'); // Redirige vers l'écran de la carte
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(5),
                        ),
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
                          // TODO : Implémenter trouver mon véhicule
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(5),
                        ),
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
                    // Historique
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO : Implémenter historique
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(5),
                        ),
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
                    // Mes véhicules
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
                          padding: const EdgeInsets.all(5),
                        ),
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
                          // TODO : Implémenter rapports et statistiques
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(5),
                        ),
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
                          // TODO : Implémenter informations
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(5),
                        ),
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
                          // TODO : Implémenter mode économie d'énergie
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(5),
                        ),
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
                          // TODO : Implémenter nous contacter
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(5),
                        ),
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
