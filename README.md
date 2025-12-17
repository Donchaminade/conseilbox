# ConseilBox

Bienvenue sur le projet ConseilBox, une application mobile multiplateforme développée avec Flutter, conçue pour le partage de connaissances et d'expériences. Cette application permet aux utilisateurs de découvrir, d'interagir avec et de proposer des "conseils", ainsi que de consulter des "publicités" mises en avant.

## Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Technologies Utilisées](#technologies-utilisées)
- [Architecture du Projet](#architecture-du-projet)
- [Installation](#installation)
  - [Prérequis](#prérequis)
  - [Frontend (Application Flutter)](#frontend-application-flutter)
  - [Backend (API PHP)](#backend-api-php)
- [Utilisation](#utilisation)
- [Contribution](#contribution)
- [Licence](#licence)

## Fonctionnalités

ConseilBox offre une expérience utilisateur riche avec les fonctionnalités suivantes :

- **Flux de Conseils Personnalisé** : Explorez un fil d'actualité de conseils, avec un défilement fluide et une interface utilisateur réactive grâce à l'utilisation des Slivers.
- **Gestion des Favoris** : Enregistrez vos conseils préférés pour les retrouver facilement et les consulter à tout moment.
- **Partage Facile** : Partagez des conseils et des publicités avec vos contacts via les options de partage natives de votre appareil.
- **Proposition de Conseils** : Soumettez vos propres conseils via un formulaire intégré et contribuez à la communauté.
- **Section Publicités Interactive** : Découvrez des publicités mises en avant, présentées dans une grille moderne inspirée des interfaces de type "marketplace".
- **Recherche et Tri Avancés** : Filtrez et triez les publicités grâce à une barre de recherche et de tri intuitive et esthétique.
- **Écran de Démarrage Dynamique** : Une animation d'introduction élégante et chorégraphiée au lancement de l'application.
- **Statistiques d'Accueil** : Visualisez en un coup d'œil le nombre total de conseils disponibles.
- **Navigation Intuitive** : Accédez facilement aux différentes sections (Accueil, Explorer, Publicités, Favoris) via une barre de navigation inférieure.

## Technologies Utilisées

### Frontend (Flutter)

- **Flutter (Dart)** : Framework UI pour le développement multiplateforme.
- **`provider`** : Solution de gestion d'état simple et efficace.
- **`shared_preferences`** : Pour la persistance des données locales simples (ex: token d'authentification).
- **`url_launcher`** : Pour l'ouverture de liens externes.
- **`share_plus`** : Pour la fonctionnalité de partage de contenu.
- **`dio`** : Client HTTP puissant pour les requêtes réseau.
- **`intl`** : Pour la gestion de l'internationalisation et le formatage des dates.
- **`google_fonts` (Delius)** : Police de caractères utilisée pour l'esthétique de l'application.

### Backend (PHP)

- **PHP** : Langage de script côté serveur pour l'API RESTful.
- **MySQL/MariaDB** : Système de gestion de base de données relationnelle.
- **API RESTful Personnalisée** : Points de terminaison pour la gestion des conseils et des publicités, incluant la pagination, le filtrage et le tri.

## Architecture du Projet

Le projet est structuré autour des principes de séparation des préoccupations :

- **`lib/config`**: Contient les configurations de l'application (couleurs, thèmes, styles de texte).
- **`lib/core`**: Logique métier principale, services API, modèles de données, gestionnaires (ex: favoris), et widgets réutilisables.
  - **`lib/core/managers`**: Gestionnaires d'état spécifiques (ex: `FavoritesManager`).
  - **`lib/core/models`**: Définitions des modèles de données (Conseil, Publicite, PaginatedResponse).
  - **`lib/core/network`**: Configuration et client API pour les interactions réseau.
  - **`lib/core/services`**: Services d'accès aux données (ConseilService, PubliciteService).
  - **`lib/core/widgets`**: Composants UI réutilisables à travers l'application.
- **`lib/features`**: Implémentation des fonctionnalités spécifiques de l'application, organisées par écran ou module (accueil, conseils, publicités, login, paramètres, splash).
- **`lib/shared`**: Widgets et utilitaires partagés entre les fonctionnalités, mais moins "core" que ceux de `lib/core/widgets`.
- **`api`**: Contient les scripts PHP du backend pour gérer les requêtes des clients.

## Installation

### Prérequis

Assurez-vous d'avoir installé les éléments suivants sur votre machine de développement :

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.7 ou supérieure recommandée)
- Un IDE pour le développement Flutter (VS Code avec l'extension Flutter est recommandé)
- Pour le backend : Un environnement serveur PHP (ex: XAMPP, WAMP, Laravel Sail, ou un serveur web configuré avec PHP et MySQL/MariaDB).

### Frontend (Application Flutter)

1.  **Cloner le dépôt** :
    ```bash
    git clone [URL_DU_DEPOT]
    cd conseilbox
    ```
2.  **Installer les dépendances Flutter** :
    ```bash
    flutter pub get
    ```
3.  **Lancer l'application** :
    Vous pouvez lancer l'application sur un émulateur, un appareil physique ou sur le web.
    L'URL de base de l'API est configurée dans `lib/core/network/api_config.dart`. Par défaut, elle utilise des adresses locales pour le développement.
    Pour cibler une API spécifique (locale, staging, production), utilisez l'option `--dart-define` :
    ```bash
    flutter run \
      --dart-define API_BASE_URL="http://votre-adresse-ip-locale:8000/api" # Pour un serveur local (ex: php artisan serve) 
    
    # Ou pour une API distante
    flutter run \
      --dart-define API_BASE_URL="https://api.votre-domaine.com/api"
    ```
    Pour une compilation de production (release build) :
    ```bash
    flutter build apk \
      --dart-define API_BASE_URL="https://api.votre-domaine.com/api"
    ```

### Backend (API PHP)

1.  **Configurer la base de données** :
    *   Créez une base de données MySQL ou MariaDB (ex: `conseilbox_db`).
    *   Le projet PHP nécessite une table `conseils` et `publicites` avec des champs appropriés (id, title, content, author, created_at, etc.). Vous devrez créer le schéma de base de données manuellement ou via un script de migration si disponible.
2.  **Mettre les fichiers de l'API sur votre serveur web** :
    *   Copiez le contenu du dossier `api/` vers le répertoire racine de votre API (ex: `public_html/api/`).
3.  **Mettre à jour la configuration de la base de données** :
    *   Éditez `api/config.php` avec les informations d'identification de votre base de données.
4.  **Assurer la configuration du serveur web** :
    *   Configurez votre serveur web (Apache, Nginx, ou utilisez `php -S localhost:8000 -t api`) pour servir les fichiers PHP de l'API. Assurez-vous que les réécritures d'URL (mod_rewrite ou équivalent) sont activées si nécessaire.

## Utilisation

Après l'installation et le lancement de l'application :

1.  **Écran de démarrage** : Une animation d'introduction est jouée.
2.  **Connexion** : Connectez-vous avec un code d'authentification valide (actuellement `Constants.correctLoginCode`).
3.  **Navigation** : Utilisez la barre de navigation inférieure pour explorer les sections : Accueil, Explorer, Publicités, et Favoris.
4.  **Interaction** :
    *   Appuyez sur un conseil ou une publicité pour voir les détails.
    *   Utilisez les icônes de cœur pour ajouter/retirer des favoris.
    *   Utilisez l'icône de partage pour partager du contenu.
    *   Le bouton flottant "Conseiller" permet de soumettre un nouveau conseil.
    *   Les onglets "Explorer" et "Publicités" offrent des options de recherche et de tri.

## Contribution

Les contributions à ce projet sont les bienvenues. Veuillez suivre les étapes suivantes :

1.  Fork le dépôt.
2.  Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`).
3.  Commitez vos changements (`git commit -m 'feat: Add AmazingFeature'`).
4.  Poussez vers la branche (`git push origin feature/AmazingFeature`).
5.  Ouvrez une Pull Request.

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.
