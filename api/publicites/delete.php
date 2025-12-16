<?php
include_once __DIR__ . '/../config.php';
include_once __DIR__ . '/../utils.php';



if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Obtenir les données de la requête
    $data = json_decode(file_get_contents("php://input"));

    // Valider l'ID
    if (!isset($data->id)) {
        sendError('Missing ID parameter.', 400);
    }

    // Préparer la requête de suppression
    $query = "DELETE FROM publicites WHERE id = :id";
    $stmt = $conn->prepare($query);

    // Nettoyer l'ID
    $data->id = htmlspecialchars(strip_tags($data->id));

    // Liaison des paramètres
    $stmt->bindParam(':id', $data->id);

    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendResponse(['message' => 'Publicite deleted successfully.']);
        } else {
            sendError('Publicite not found.', 404);
        }
    } else {
        sendError('Failed to delete publicite.', 503);
    }
} else {
    sendError('Method not allowed.', 405);
}
?>