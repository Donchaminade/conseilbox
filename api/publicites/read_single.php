<?php
include_once __DIR__ . '/../config.php';
include_once __DIR__ . '/../utils.php';



if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Vérifier si l'ID est fourni dans l'URL
    $id = isset($_GET['id']) ? $_GET['id'] : die(sendError('Missing ID parameter.', 400));

    // Récupérer une seule publicité
    $query = "SELECT id, title, content, image_url, target_url, is_active, start_date, end_date, created_at FROM publicites WHERE id = :id LIMIT 0,1";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();

    $publicite = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($publicite) {
        sendResponse($publicite);
    } else {
        sendError('Publicite not found.', 404);
    }
} else {
    sendError('Method not allowed.', 405);
}
?>