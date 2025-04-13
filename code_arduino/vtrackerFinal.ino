// Définir le modem utilisé (SIM800L dans ce cas)
#define TINY_GSM_MODEM_SIM800

#include <TinyGPSPlus.h>
#include <TinyGsmClient.h>
#include <ArduinoHttpClient.h>
#include <SoftwareSerial.h>

// Définition des broches pour le module SIM800L et le GPS
#define rxPin 6  // Broche RX pour SIM800L
#define txPin 5  // Broche TX pour SIM800L
#define RXD2 3   // Broche RX pour GPS
#define TXD2 4   // Broche TX pour GPS

// Taille du tampon pour le modem
#define TINY_GSM_RX_BUFFER 512

// Informations Firebase
const char FIREBASE_HOST[] = " "; // Hôte Firebase
const String FIREBASE_AUTH = " ";    // Clé d'authentification Firebase
const String FIREBASE_PATH = "/";                                           // Chemin Firebase
const int SSL_PORT = 443;                                                   // Port SSL pour HTTPS

// Informations APN pour la connexion GPRS
char apn[] = "iew.orange.cd"; // APN de l'opérateur
char user[] = "";             // Nom d'utilisateur APN (vide si non requis)
char pass[] = "";             // Mot de passe APN (vide si non requis)

// Initialisation des objets pour la communication série et le modem
SoftwareSerial SerialGSM(rxPin, txPin); // Communication série avec SIM800L
TinyGsm modem(SerialGSM);              // Objet modem

TinyGPSPlus gps;                       // Objet GPS
SoftwareSerial SerialGPS(RXD2, TXD2);  // Communication série avec le GPS
TinyGsmClientSecure gsm_client_secure_modem(modem, 0); // Client sécurisé pour HTTPS
HttpClient http_client = HttpClient(gsm_client_secure_modem, FIREBASE_HOST, SSL_PORT); // Client HTTP

unsigned long previousMillis = 0; // Variable pour gérer les intervalles de temps
long interval = 1000;             // Intervalle entre les envois de données (en millisecondes)

void setup() {
  // Initialisation des communications série
  Serial.begin(38400);
  Serial.println("Initialisation du port série Arduino");

  SerialGPS.begin(9600);
  Serial.println("Initialisation du port série GPS");
  delay(2500);

  SerialGSM.begin(9600);
  Serial.println("Initialisation du port série SIM800L");
  delay(2500);

  // Initialisation du modem
  Serial.println("Initialisation du modem...");
  modem.init();
  String modemInfo = modem.getModemInfo();
  Serial.print("Modem: ");
  Serial.println(modemInfo);
  Serial.print("Fournisseur : ");
  Serial.println(modem.getProvider());
  Serial.print("Opérateur : ");
  Serial.println(modem.getOperator());
  Serial.print("IMEI: ");
  Serial.println(modem.getIMEI());
  Serial.print("Qualité du signal : ");
  Serial.println(modem.getSignalQuality());

  // Configuration du délai de réponse HTTP
  http_client.setHttpResponseTimeout(90 * 1000);
}

void loop() {
  // Connexion au réseau GPRS
  Serial.print(F("Connexion à "));
  Serial.println(apn);
  if (!modem.gprsConnect(apn, user, pass)) {
    Serial.println("Échec de la connexion");
    delay(1000);
    return;
  }
  Serial.println("Connexion réussie");
  http_client.connect(FIREBASE_HOST, SSL_PORT);

  // Boucle principale pour envoyer les données GPS
  while (true) {
    if (!http_client.connected()) {
      Serial.println();
      http_client.stop();  // Arrêt de la connexion HTTP
      Serial.println("HTTP non connecté");
      break;
    } else {
      gps_loop(); // Appel de la fonction pour traiter les données GPS
    }
    delay(200);
  }
}

void PostToFirebase(const char* method, const String& path, const String& data, HttpClient* http) {
  // Fonction pour envoyer des données à Firebase
  String response;
  int statusCode = 0;
  http->connectionKeepAlive();

  String url;
  if (path[0] != '/') {
    url = "/";
  }
  url += path + ".json";
  url += "?auth=" + FIREBASE_AUTH;

  String contentType = "application/json";
  http->put(url, contentType, data); // Envoi des données via HTTP PUT
  statusCode = http->responseStatusCode();
  Serial.print("Code de statut : ");
  Serial.println(statusCode);
  response = http->responseBody();
  Serial.print("Réponse : ");
  Serial.println(response);

  if (!http->connected()) {
    Serial.println();
    http->stop(); 
    Serial.println("HTTP POST déconnecté");
  }
}

void gps_loop() {
  // Fonction pour lire et traiter les données GPS
  boolean newData = false;
  if (gps.encode(SerialGPS.read())) {
    newData = true;
  }
  smartDelay(1000);

  if (newData == true) {
    newData = false;

    String latitude, longitude;
    String date, time, speed, satellites;

    smartDelay(1000);

    latitude = String(gps.location.lat(), 10);   // Latitude en degrés
    longitude = String(gps.location.lng(), 10); // Longitude en degrés
    Serial.print("Latitude : ");
    Serial.println(latitude);
    Serial.print("Longitude : ");
    Serial.println(longitude);

    // Récupération des autres données GPS
    date = gps.date.value();  // Date brute au format DDMMYY
    time = gps.time.value();  // Heure brute au format HHMMSSCC

    // Construction de la chaîne JSON pour Firebase
    String gpsData = "{";
    gpsData += "\"lat\":" + latitude + ",";
    gpsData += "\"lng\":" + longitude + ",";
    gpsData += "\"date\":" + date + ",";
    gpsData += "\"time\":" + time + ",";
    gpsData += "}";

    // Envoi des données à Firebase
    PostToFirebase("POST", FIREBASE_PATH, gpsData, &http_client);
  }
}

static void smartDelay(unsigned long ms) {
  // Fonction pour introduire un délai tout en traitant les données GPS
  unsigned long start = millis();
  do {
    while (SerialGPS.available())
      gps.encode(SerialGPS.read());
  } while (millis() - start < ms);
}
