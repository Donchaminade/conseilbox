<?php
include_once __DIR__ . '/../config.php';
include_once __DIR__ . '/../utils.php';

if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Obtenir les données de la requête (JSON uniquement, sans upload de fichier direct)
    $data = json_decode(file_get_contents("php://input"));

    // Valider l'ID
    if (!isset($data->id) || !is_numeric($data->id)) {
        sendError('Invalid or missing ID parameter.', 400);
    }

    // Nettoyer les données. Utiliser null pour les champs non fournis afin de les ignorer dans la mise à jour.
    $data->id = htmlspecialchars(strip_tags($data->id));
    $data->title = isset($data->title) ? htmlspecialchars(strip_tags($data->title)) : null;
    $data->content = isset($data->content) ? htmlspecialchars(strip_tags($data->content)) : null;
    $data->anecdote = isset($data->anecdote) ? htmlspecialchars(strip_tags($data->anecdote)) : null;
    // La colonne 'image' est supprimée de ce point d'API
    $data->author = isset($data->author) ? htmlspecialchars(strip_tags($data->author)) : null;
    $data->location = isset($data->location) ? htmlspecialchars(strip_tags($data->location)) : null;
    $data->status = isset($data->status) ? htmlspecialchars(strip_tags($data->status)) : null;
    $data->social_link_1 = isset($data->social_link_1) ? htmlspecialchars(strip_tags($data->social_link_1)) : null;
    $data->social_link_2 = isset($data->social_link_2) ? htmlspecialchars(strip_tags($data->social_link_2)) : null;
    $data->social_link_3 = isset($data->social_link_3) ? htmlspecialchars(strip_tags($data->social_link_3)) : null;

    // Validation des données (si elles sont présentes)
    if ($data->title !== null) {
        if (empty($data->title) || strlen($data->title) < 3 || strlen($data->title) > 255) {
            sendError('Title must be between 3 and 255 characters.', 400);
        }
    }
    if ($data->content !== null) {
        if (empty($data->content) || strlen($data->content) < 10) {
            sendError('Content must be at least 10 characters long.', 400);
        }
    }
    if ($data->author !== null) {
        if (empty($data->author) || strlen($data->author) < 2 || strlen($data->author) > 255) {
            sendError('Author must be between 2 and 255 characters.', 400);
        }
    }

    if ($data->status !== null) {
        $allowedStatuses = ['pending', 'published', 'rejected'];
        if (!in_array($data->status, $allowedStatuses)) {
            sendError('Invalid status. Allowed values are: ' . implode(', ', $allowedStatuses), 400);
        }
    }

    if ($data->social_link_1 && !filter_var($data->social_link_1, FILTER_VALIDATE_URL)) {
        sendError('Social link 1 is not a valid URL.', 400);
    }
    if ($data->social_link_2 && !filter_var($data->social_link_2, FILTER_VALIDATE_URL)) {
        sendError('Social link 2 is not a valid URL.', 400);
    }
    if ($data->social_link_3 && !filter_var($data->social_link_3, FILTER_VALIDATE_URL)) {
        sendError('Social link 3 is not a valid URL.', 400);
    }

    // Préparer la requête de mise à jour dynamique
    $setClauses = [];
    $bindParams = [':id' => $data->id]; // L'ID est toujours nécessaire pour la clause WHERE

    if ($data->title !== null) {
        $setClauses[] = 'title = :title';
        $bindParams[':title'] = $data->title;
    }
    if ($data->content !== null) {
        $setClauses[] = 'content = :content';
        $bindParams[':content'] = $data->content;
    }
    if ($data->anecdote !== null) {
        $setClauses[] = 'anecdote = :anecdote';
        $bindParams[':anecdote'] = $data->anecdote;
    }
    // La colonne 'image' est supprimée de ce point d'API
    if ($data->author !== null) {
        $setClauses[] = 'author = :author';
        $bindParams[':author'] = $data->author;
    }
    if ($data->location !== null) {
        $setClauses[] = 'location = :location';
        $bindParams[':location'] = $data->location;
    }
    if ($data->status !== null) {
        $setClauses[] = 'status = :status';
        $bindParams[':status'] = $data->status;
    }
    if ($data->social_link_1 !== null) {
        $setClauses[] = 'social_link_1 = :social_link_1';
        $bindParams[':social_link_1'] = $data->social_link_1;
    }
    if ($data->social_link_2 !== null) {
        $setClauses[] = 'social_link_2 = :social_link_2';
        $bindParams[':social_link_2'] = $data->social_link_2;
    }
    if ($data->social_link_3 !== null) {
        $setClauses[] = 'social_link_3 = :social_link_3';
        $bindParams[':social_link_3'] = $data->social_link_3;
    }

    // Toujours mettre à jour updated_at si des champs ont été modifiés
    if (!empty($setClauses)) {
        $setClauses[] = 'updated_at = NOW()';
    } else {
        // Si aucun champ n'est fourni pour la mise à jour, renvoyer une réponse et terminer
        sendResponse(['message' => 'No fields provided for update, no changes made.'], 200);
    }


    $query = "UPDATE conseils SET " . implode(', ', $setClauses) . " WHERE id = :id";
    $stmt = $conn->prepare($query);

    foreach ($bindParams as $param => $value) {
        $stmt->bindValue($param, $value);
    }

    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendResponse(['message' => 'Conseil updated successfully.']);
        } else {
            sendError('Conseil not found or no data changed.', 404);
        }
    } else {
        sendError('Failed to update conseil.', 503);
    }
} else {
    sendError('Method not allowed.', 405);
}
?>