<?php

// Configuration de la limitation de débit
define('RATE_LIMIT_REQUESTS', 60); // Nombre maximal de requêtes autorisées
define('RATE_LIMIT_PERIOD', 60);   // Période en secondes (ici, 1 minute)
define('RATE_LIMIT_FILE', __DIR__ . '/../logs/rate_limits.json'); // Fichier pour stocker les données de limite

/**
 * Vérifie et applique la limitation de débit pour l'adresse IP actuelle.
 *
 * @return bool Retourne true si la requête est autorisée, false si elle est limitée.
 */
function checkRateLimit() {
    $ip = $_SERVER['REMOTE_ADDR'];
    $currentTime = time();
    $rateLimits = [];

    // Assurez-vous que le dossier des logs existe
    $logDir = dirname(RATE_LIMIT_FILE);
    if (!is_dir($logDir)) {
        mkdir($logDir, 0777, true);
    }

    // Lire les données existantes
    if (file_exists(RATE_LIMIT_FILE)) {
        $fileContent = file_get_contents(RATE_LIMIT_FILE);
        if ($fileContent) {
            $rateLimits = json_decode($fileContent, true);
        }
    }

    // Nettoyer les anciennes entrées
    foreach ($rateLimits as $key => $entry) {
        if ($entry['timestamp'] < $currentTime - RATE_LIMIT_PERIOD) {
            unset($rateLimits[$key]);
        }
    }

    // Initialiser ou mettre à jour l'entrée pour l'IP actuelle
    if (!isset($rateLimits[$ip])) {
        $rateLimits[$ip] = ['count' => 0, 'timestamp' => $currentTime];
    }

    // Incrémenter le compteur
    $rateLimits[$ip]['count']++;

    // Calculer le temps restant avant la réinitialisation
    $timeRemaining = RATE_LIMIT_PERIOD - ($currentTime - $rateLimits[$ip]['timestamp']);
    $requestsRemaining = RATE_LIMIT_REQUESTS - $rateLimits[$ip]['count'];

    // Mettre à jour les headers HTTP pour la limitation de débit
    header('X-RateLimit-Limit: ' . RATE_LIMIT_REQUESTS);
    header('X-RateLimit-Remaining: ' . max(0, $requestsRemaining));
    header('X-RateLimit-Reset: ' . max(0, $timeRemaining));

    // Écrire les données mises à jour
    file_put_contents(RATE_LIMIT_FILE, json_encode($rateLimits, JSON_PRETTY_PRINT));

    // Vérifier si la limite est dépassée
    if ($rateLimits[$ip]['count'] > RATE_LIMIT_REQUESTS) {
        return false; // Limite dépassée
    }

    return true; // Requête autorisée
}

?>