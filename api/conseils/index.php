<?php
include_once __DIR__ . '/../config.php';
include_once __DIR__ . '/../utils.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Pagination
    $page = isset($_GET['page']) && is_numeric($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
    $limit = isset($_GET['limit']) && is_numeric($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = ($page - 1) * $limit;

    // Sorting
    $allowedSortBy = ['id', 'title', 'author', 'location', 'status', 'created_at', 'random'];
    $sortBy = isset($_GET['sort_by']) && in_array($_GET['sort_by'], $allowedSortBy) ? $_GET['sort_by'] : 'created_at';
    $order = isset($_GET['order']) && in_array(strtoupper($_GET['order']), ['ASC', 'DESC']) ? strtoupper($_GET['order']) : 'DESC';

    // Filtering
    $whereClauses = [];
    $bindParams = [];

    if (isset($_GET['status'])) {
        $statuses = explode(',', $_GET['status']); // Handle comma-separated statuses
        $placeholders = [];
        $i = 0;
        foreach ($statuses as $status) {
            $status = trim($status);
            if (!in_array($status, ['pending', 'published', 'rejected', 'active'])) { // Added 'active' here
                sendError('Invalid status filter. Allowed values are: pending, published, rejected, active', 400);
            }
            $placeholder = ':status' . $i++;
            $placeholders[] = $placeholder;
            $bindParams[$placeholder] = $status;
        }
        if (!empty($placeholders)) {
            $whereClauses[] = 'status IN (' . implode(',', $placeholders) . ')';
        }
    }
    
    if (isset($_GET['search']) && !empty($_GET['search'])) {
        $searchTerm = '%' . $_GET['search'] . '%';
        $whereClauses[] = '(title LIKE :search OR content LIKE :search OR author LIKE :search OR location LIKE :search)';
        $bindParams[':search'] = $searchTerm;
    }


    // Build the query
    $query = "SELECT id, title, content, anecdote, author, location, status, social_link_1, social_link_2, social_link_3, created_at FROM conseils";

    if (!empty($whereClauses)) {
        $query .= " WHERE " . implode(' AND ', $whereClauses);
    }

    if ($sortBy === 'random') {
        $query .= " ORDER BY RAND()";
    } else {
        $query .= " ORDER BY " . $sortBy . " " . $order;
    }
    
    if ($limit > 0) {
        $query .= " LIMIT :limit OFFSET :offset";
    }

    $stmt = $conn->prepare($query);

    // Lier les paramètres
    foreach ($bindParams as $param => $value) {
        $stmt->bindValue($param, $value);
    }
    if ($limit > 0) {
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    }

    $stmt->execute();
    $conseils = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Obtenir le nombre total de conseils pour la pagination
    $countQuery = "SELECT COUNT(*) FROM conseils";
    if (!empty($whereClauses)) {
        $countQuery .= " WHERE " . implode(' AND ', $whereClauses);
    }
    $countStmt = $conn->prepare($countQuery);
    foreach ($bindParams as $param => $value) {
        $countStmt->bindValue($param, $value);
    }
    $countStmt->execute();
    $totalConseils = $countStmt->fetchColumn();

    sendResponse([
        'total' => $totalConseils,
        'page' => $page,
        'limit' => $limit,
        'conseils' => $conseils
    ]);

} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Créer un nouveau conseil (JSON uniquement, sans upload de fichier direct)
    $data = json_decode(file_get_contents("php://input"));

    if (!isset($data->title) || !isset($data->content) || !isset($data->author)) {
        sendError('Missing required parameters: title, content, author', 400);
    }

    // Nettoyer les données
    $data->title = htmlspecialchars(strip_tags($data->title));
    $data->content = htmlspecialchars(strip_tags($data->content));
    $data->anecdote = isset($data->anecdote) ? htmlspecialchars(strip_tags($data->anecdote)) : null;
    // La colonne 'image' est supprimée de ce point d'API
    $data->author = htmlspecialchars(strip_tags($data->author));
    $data->location = isset($data->location) ? htmlspecialchars(strip_tags($data->location)) : null;
    $data->status = isset($data->status) ? htmlspecialchars(strip_tags($data->status)) : 'pending';
    $data->social_link_1 = isset($data->social_link_1) ? htmlspecialchars(strip_tags($data->social_link_1)) : null;
    $data->social_link_2 = isset($data->social_link_2) ? htmlspecialchars(strip_tags($data->social_link_2)) : null;
    $data->social_link_3 = isset($data->social_link_3) ? htmlspecialchars(strip_tags($data->social_link_3)) : null;

    // Validation des données
    if (empty($data->title) || strlen($data->title) < 3 || strlen($data->title) > 255) {
        sendError('Title is required and must be between 3 and 255 characters.', 400);
    }
    if (empty($data->content) || strlen($data->content) < 10) {
        sendError('Content is required and must be at least 10 characters long.', 400);
    }
    if (empty($data->author) || strlen($data->author) < 2 || strlen($data->author) > 255) {
        sendError('Author is required and must be between 2 and 255 characters.', 400);
    }

    $allowedStatuses = ['pending', 'published', 'rejected', 'active'];
    if (!in_array($data->status, $allowedStatuses)) {
        sendError('Invalid status. Allowed values are: ' . implode(', ', $allowedStatuses), 400);
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

    // Requête INSERT sans la colonne 'image'
    $query = "INSERT INTO conseils (title, content, anecdote, author, location, status, social_link_1, social_link_2, social_link_3) VALUES (:title, :content, :anecdote, :author, :location, :status, :social_link_1, :social_link_2, :social_link_3)";
    $stmt = $conn->prepare($query);

    // Liaison des paramètres
    $stmt->bindParam(':title', $data->title);
    $stmt->bindParam(':content', $data->content);
    $stmt->bindParam(':anecdote', $data->anecdote);
    $stmt->bindParam(':author', $data->author);
    $stmt->bindParam(':location', $data->location);
    $stmt->bindParam(':status', $data->status);
    $stmt->bindParam(':social_link_1', $data->social_link_1);
    $stmt->bindParam(':social_link_2', $data->social_link_2);
    $stmt->bindParam(':social_link_3', $data->social_link_3);


    if ($stmt->execute()) {
        $lastId = $conn->lastInsertId();
        
        // Fetch the newly created conseil to return it
        $query = "SELECT id, title, content, anecdote, author, location, status, social_link_1, social_link_2, social_link_3, created_at, updated_at FROM conseils WHERE id = :id";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':id', $lastId);
        $stmt->execute();
        $newConseil = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($newConseil) {
            sendResponse($newConseil, 201);
        } else {
            // This case should ideally not happen if the insert was successful
            sendResponse(['message' => 'Conseil created but could not be retrieved.', 'id' => $lastId], 207);
        }

    } else {
        sendError('Failed to create conseil.', 503);
    }
} else {
    sendError('Method not allowed.', 405);
}
?>