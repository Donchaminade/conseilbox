<?php
include_once __DIR__ . '/../config.php';
include_once __DIR__ . '/../utils.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Vérifier si l'ID est fourni dans l'URL
    $id = isset($_GET['id']) ? $_GET['id'] : die(sendError('Missing ID parameter.', 400));

    // Récupérer un seul conseil (sans la colonne 'image')
    $query = "SELECT id, title, content, anecdote, author, location, status, social_link_1, social_link_2, social_link_3, created_at FROM conseils WHERE id = :id LIMIT 0,1";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();

    $conseil = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($conseil) {
        sendResponse($conseil);
    } else {
        sendError('Conseil not found.', 404);
    }
} else {
    sendError('Method not allowed.', 405);
}
?>