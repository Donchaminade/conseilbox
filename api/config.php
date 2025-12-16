<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Access-Control-Allow-Headers,Content-Type,Access-Control-Allow-Methods, Authorization, X-Requested-With');

// Inclure le fichier de configuration principal de la base de données
include_once __DIR__ . '/../config.php';
include_once __DIR__ . '/utils.php'; // Inclure utils.php pour sendError
include_once __DIR__ . '/rate_limiter.php'; // Inclure le rate limiter

// Assigner l'objet PDO global à $conn pour les fichiers d'API
$conn = $pdo;

// Appliquer la limitation de débit à toutes les requêtes API
if (!checkRateLimit()) {
    sendError('Too many requests. Please try again later.', 429);
}

// Fonction pour gérer les requêtes OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Assurez-vous que $conn est défini (bien que maintenant géré par l'inclusion de config.php)
if (!isset($conn)) {
    sendError('Database connection not established.', 500);
}
?>