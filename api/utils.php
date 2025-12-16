<?php
include_once __DIR__ . '/logger.php'; // Inclure le logger

function sendResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit();
}

function sendError($message, $statusCode = 500) {
    // Log l'erreur avant d'envoyer la réponse
    logError($message, [
        'request_method' => $_SERVER['REQUEST_METHOD'] ?? 'N/A',
        'request_uri' => $_SERVER['REQUEST_URI'] ?? 'N/A',
        'status_code' => $statusCode,
        'php_input' => file_get_contents('php://input') // Capture le corps de la requête
    ]);

    http_response_code($statusCode);
    echo json_encode(['message' => $message]);
    exit();
}
?>