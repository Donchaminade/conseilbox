<?php
include_once __DIR__ . '/../config.php';
include_once __DIR__ . '/../utils.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Pagination
    $page = isset($_GET['page']) && is_numeric($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
    $limit = isset($_GET['limit']) && is_numeric($_GET['limit']) ? max(1, (int)$_GET['limit']) : 10;
    $offset = ($page - 1) * $limit;

    // Sorting
    $allowedSortBy = ['id', 'title', 'is_active', 'start_date', 'end_date', 'created_at'];
    $sortBy = isset($_GET['sort_by']) && in_array($_GET['sort_by'], $allowedSortBy) ? $_GET['sort_by'] : 'created_at';
    $order = isset($_GET['order']) && in_array(strtoupper($_GET['order']), ['ASC', 'DESC']) ? strtoupper($_GET['order']) : 'DESC';

    // Filtering
    $whereClauses = [];
    $bindParams = [];

    if (isset($_GET['is_active'])) {
        $isActive = (int)$_GET['is_active'];
        if ($isActive === 0 || $isActive === 1) {
            $whereClauses[] = 'is_active = :is_active';
            $bindParams[':is_active'] = $isActive;
        } else {
            sendError('Invalid is_active filter. Must be 0 or 1.', 400);
        }
    }

    if (isset($_GET['start_date_min']) && !empty($_GET['start_date_min'])) {
        $whereClauses[] = 'start_date >= :start_date_min';
        $bindParams[':start_date_min'] = $_GET['start_date_min'];
    }
    if (isset($_GET['end_date_max']) && !empty($_GET['end_date_max'])) {
        $whereClauses[] = 'end_date <= :end_date_max';
        $bindParams[':end_date_max'] = $_GET['end_date_max'];
    }
    
    if (isset($_GET['search']) && !empty($_GET['search'])) {
        $searchTerm = '%' . $_GET['search'] . '%';
        $whereClauses[] = '(title LIKE :search OR content LIKE :search)';
        $bindParams[':search'] = $searchTerm;
    }


    // Construire la requête
    $query = "SELECT id, title, content, image_url, target_url, is_active, start_date, end_date, created_at FROM publicites";

    if (!empty($whereClauses)) {
        $query .= " WHERE " . implode(' AND ', $whereClauses);
    }

    $query .= " ORDER BY " . $sortBy . " " . $order . " LIMIT :limit OFFSET :offset";

    $stmt = $conn->prepare($query);

    // Lier les paramètres
    foreach ($bindParams as $param => $value) {
        $stmt->bindValue($param, $value);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);

    $stmt->execute();
    $publicites = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Obtenir le nombre total de publicités pour la pagination
    $countQuery = "SELECT COUNT(*) FROM publicites";
    if (!empty($whereClauses)) {
        $countQuery .= " WHERE " . implode(' AND ', $whereClauses);
    }
    $countStmt = $conn->prepare($countQuery);
    foreach ($bindParams as $param => $value) {
        if ($param === ':is_active') {
             $countStmt->bindValue($param, $value, PDO::PARAM_INT);
        } else {
            $countStmt->bindValue($param, $value);
        }
    }
    $countStmt->execute();
    $totalPublicites = $countStmt->fetchColumn();


    sendResponse([
        'total' => $totalPublicites,
        'page' => $page,
        'limit' => $limit,
        'publicites' => $publicites
    ]);

} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Gérer les données et le fichier uploadé
    $data = (object)[];
    $image_url_from_upload = null;

    // Si le type de contenu est multipart/form-data (pour les uploads de fichiers)
    if (str_starts_with($_SERVER['CONTENT_TYPE'], 'multipart/form-data')) {
        $data = (object)$_POST;
        if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
            $file = $_FILES['image'];

            $uploadDir = __DIR__ . '/../publicites/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0777, true);
            }

            $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
            if (!in_array($file['type'], $allowedTypes)) {
                sendError('Invalid file type. Only JPEG, PNG, GIF are allowed.', 400);
            }

            $maxFileSize = 5 * 1024 * 1024; // 5 MB
            if ($file['size'] > $maxFileSize) {
                sendError('File size exceeds the maximum limit of 5MB.', 400);
            }

            $fileExtension = pathinfo($file['name'], PATHINFO_EXTENSION);
            $fileName = uniqid() . '.' . $fileExtension;
            $filePath = $uploadDir . $fileName;

            if (move_uploaded_file($file['tmp_name'], $filePath)) {
                $image_url_from_upload = 'uploads/' . $fileName;
            } else {
                sendError('Failed to move uploaded file.', 500);
            }
        }
    } else {
        // Si le type de contenu est application/json
        $data = json_decode(file_get_contents("php://input"));
    }

    if (!isset($data->title) || !isset($data->content)) {
        sendError('Missing required parameters: title, content', 400);
    }

    // Nettoyer les données
    $data->title = htmlspecialchars(strip_tags($data->title));
    $data->content = htmlspecialchars(strip_tags($data->content));
    $data->image_url = $image_url_from_upload !== null ? $image_url_from_upload : (isset($data->image_url) ? htmlspecialchars(strip_tags($data->image_url)) : null);
    $data->target_url = isset($data->target_url) ? htmlspecialchars(strip_tags($data->target_url)) : null;
    $data->is_active = isset($data->is_active) ? (int)$data->is_active : 0; // Cast to int for tinyint
    $data->start_date = isset($data->start_date) ? $data->start_date : null;
    $data->end_date = isset($data->end_date) ? $data->end_date : null;

    // Validation des données
    if (empty($data->title) || strlen($data->title) < 3 || strlen($data->title) > 255) {
        sendError('Title is required and must be between 3 and 255 characters.', 400);
    }
    if (empty($data->content) || strlen($data->content) < 10) {
        sendError('Content is required and must be at least 10 characters long.', 400);
    }

    if ($data->image_url && !filter_var($data->image_url, FILTER_VALIDATE_URL)) {
        sendError('Image URL is not a valid URL.', 400);
    }
    if ($data->target_url && !filter_var($data->target_url, FILTER_VALIDATE_URL)) {
        sendError('Target URL is not a valid URL.', 400);
    }

    // Basic date validation (could be more robust)
    if ($data->start_date && !strtotime($data->start_date)) {
        sendError('Invalid start_date format.', 400);
    }
    if ($data->end_date && !strtotime($data->end_date)) {
        sendError('Invalid end_date format.', 400);
    }
    if ($data->start_date && $data->end_date && (strtotime($data->start_date) > strtotime($data->end_date))) {
        sendError('start_date cannot be after end_date.', 400);
    }


    $query = "INSERT INTO publicites (title, content, image_url, target_url, is_active, start_date, end_date) VALUES (:title, :content, :image_url, :target_url, :is_active, :start_date, :end_date)";
    $stmt = $conn->prepare($query);

    // Liaison des paramètres
    $stmt->bindParam(':title', $data->title);
    $stmt->bindParam(':content', $data->content);
    $stmt->bindParam(':image_url', $data->image_url);
    $stmt->bindParam(':target_url', $data->target_url);
    $stmt->bindParam(':is_active', $data->is_active, PDO::PARAM_INT);
    $stmt->bindParam(':start_date', $data->start_date);
    $stmt->bindParam(':end_date', $data->end_date);

    if ($stmt->execute()) {
        sendResponse(['message' => 'Publicite created successfully.', 'id' => $conn->lastInsertId()], 201);
    } else {
        sendError('Failed to create publicite.', 503);
    }
} else {
    sendError('Method not allowed.', 405);
}
?>