<?php

// Définir le chemin du fichier de log. Assurez-vous que le dossier est accessible en écriture.
define('LOG_FILE', __DIR__ . '/../logs/api_errors.log');

/**
 * Enregistre un message d'erreur dans le fichier de log.
 *
 * @param string $message Le message d'erreur à enregistrer.
 * @param array $context Des données supplémentaires à inclure dans le log (par exemple, $_SERVER, $_POST).
 */
function logError($message, $context = []) {
    // Assurez-vous que le dossier des logs existe
    $logDir = dirname(LOG_FILE);
    if (!is_dir($logDir)) {
        mkdir($logDir, 0777, true);
    }

    $timestamp = date('Y-m-d H:i:s');
    $logMessage = "[$timestamp] ERROR: $message\n";

    if (!empty($context)) {
        $logMessage .= "Context: " . json_encode($context, JSON_PRETTY_PRINT) . "\n";
    }
    $logMessage .= "--------------------------------------------------\n";

    file_put_contents(LOG_FILE, $logMessage, FILE_APPEND);
}

?>