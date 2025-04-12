# VTracker - Application de Suivi de Véhicules

Bienvenue dans **VTracker**, une application mobile conçue pour vous aider à suivre et gérer vos véhicules en temps réel. Que vous soyez un particulier ou une entreprise, VTracker vous offre des fonctionnalités avancées pour surveiller vos véhicules et garantir leur sécurité.

---

## Fonctionnalités Principales

### 🚗 **Localisation en Temps Réel**
- Suivez la position actuelle de vos véhicules directement sur une carte interactive.
- Recevez des mises à jour en temps réel grâce à l'intégration avec Firebase.

### 🛡️ **Zones de Sécurité**
- Définissez des zones sécurisées pour vos véhicules.
- Recevez des notifications instantanées si un véhicule sort ou entre dans une zone définie.

### 🗺️ **Historique des Déplacements** (Fonctionnalité future)
- Consultez l'historique des trajets de vos véhicules.
- Visualisez les itinéraires parcourus directement sur la carte.

### 📊 **Rapports et Statistiques** (Fonctionnalité future)
- Analysez les données de vos véhicules pour une meilleure gestion.
- Accédez à des rapports détaillés sur les déplacements et les alertes.

### 🔔 **Notifications**
- Recevez des alertes en cas de sortie de zone ou d'autres événements importants.
- Notifications personnalisées pour rester informé à tout moment.

### 🚘 **Gestion des Véhicules**
- Ajoutez, modifiez ou supprimez vos véhicules facilement.
- Associez des informations comme la plaque d'immatriculation et l'ID GPS Arduino.

---

## Installation

### Prérequis
- **Flutter SDK** : Assurez-vous d'avoir Flutter installé sur votre machine. [Guide d'installation Flutter](https://flutter.dev/docs/get-started/install)
- **Firebase** : Configurez Firebase pour votre projet. Suivez les instructions dans le fichier `firebase_options.dart`.

### Étapes
1. Clonez ce dépôt :
   ```bash
   git clone https://github.com/votre-utilisateur/vtracker.git
   ```
2. Accédez au dossier du projet :
   ```bash
   cd trackerapp
   ```
3. Installez les dépendances :
   ```bash
   flutter pub get
   ```
4. Lancez l'application :
   ```bash
   flutter run
   ```

---

## Utilisation

### Écran d'Accueil
- Accédez rapidement aux fonctionnalités principales comme la localisation, l'historique et la gestion des véhicules.

### Carte Interactive
- Visualisez vos véhicules sur une carte Google Maps.
- Ajoutez des zones de sécurité en dessinant directement sur la carte.

### Gestion des Véhicules
- Ajoutez un véhicule en renseignant son nom, sa plaque d'immatriculation et son ID GPS Arduino.

---

## Technologies Utilisées

- **Flutter** : Framework pour le développement multiplateforme.
- **Firebase** : Backend pour la gestion des données en temps réel.
- **Google Maps API** : Intégration pour la carte interactive.
- **Geolocator** : Gestion des positions GPS.

---

## Contribution

Nous sommes ouverts aux contributions ! Si vous souhaitez améliorer l'application ou ajouter de nouvelles fonctionnalités, suivez ces étapes :
1. Forkez ce dépôt.
2. Créez une branche pour votre fonctionnalité :
   ```bash
   git checkout -b nouvelle-fonctionnalite
   ```
3. Faites vos modifications et soumettez une Pull Request.

---

## Support

Si vous rencontrez des problèmes ou avez des questions, n'hésitez pas à ouvrir une **issue** sur ce dépôt ou à nous contacter par email.

---

## Auteur

- **Victoire** : Développeurs passionnés par la technologie et la sécurité des véhicules.

Merci d'utiliser **VTracker** ! 🚀
