<?php
include_once __DIR__ . '/../config.php';
include_once __DIR__ . '/../utils.php';

if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Gérer les données et le fichier uploadé
    $data = (object)[];
    $image_url_from_upload = null;

    // Détecter si la requête est multipart/form-data (pour les uploads de fichiers)
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
                $image_url_from_upload = 'publicites/' . $fileName;
            } else {
                sendError('Failed to move uploaded file.', 500);
            }
        }
    } else {
        // Si le type de contenu est application/json
        $data = json_decode(file_get_contents("php://input"));
    }

    // Valider l'ID
    if (!isset($data->id) || !is_numeric($data->id)) {
        sendError('Invalid or missing ID parameter.', 400);
    }

    // Nettoyer les données. Utiliser null pour les champs non fournis afin de les ignorer dans la mise à jour.
    $data->id = htmlspecialchars(strip_tags($data->id));
    $data->title = isset($data->title) ? htmlspecialchars(strip_tags($data->title)) : null;
    $data->content = isset($data->content) ? htmlspecialchars(strip_tags($data->content)) : null;
    // Si une image a été uploadée, utiliser son URL. Sinon, utiliser l'image potentiellement fournie dans le JSON, ou null.
    $data->image_url = $image_url_from_upload !== null ? $image_url_from_upload : (isset($data->image_url) ? htmlspecialchars(strip_tags($data->image_url)) : null);
    $data->target_url = isset($data->target_url) ? htmlspecialchars(strip_tags($data->target_url)) : null;
    $data->is_active = isset($data->is_active) ? (int)$data->is_active : null; // Cast to int for tinyint
    $data->start_date = isset($data->start_date) ? $data->start_date : null;
    $data->end_date = isset($data->end_date) ? $data->end_date : null;

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

    if ($data->image_url && !filter_var($data->image_url, FILTER_VALIDATE_URL)) {
        sendError('Image URL is not a valid URL.', 400);
    }
    if ($data->target_url && !filter_var($data->target_url, FILTER_VALIDATE_URL)) {
        sendError('Target URL is not a valid URL.', 400);
    }

    if ($data->is_active !== null && !in_array($data->is_active, [0, 1])) {
        sendError('Is_active must be 0 or 1.', 400);
    }

    // Basic date validation (could be more robust)
    if ($data->start_date && !strtotime($data->start_date)) {
        sendError('Invalid start_date format.', 400);
    }
    if ($data->end_date && !strtotime($data->end_date)) {
        sendError('Invalid end_date format.', 400);
    }
    // Only compare if both are provided and valid
    if ($data->start_date && $data->end_date && strtotime($data->start_date) && strtotime($data->end_date) && (strtotime($data->start_date) > strtotime($data->end_date))) {
        sendError('start_date cannot be after end_date.', 400);
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
    if ($data->image_url !== null) {
        $setClauses[] = 'image_url = :image_url';
        $bindParams[':image_url'] = $data->image_url;
    }
    if ($data->target_url !== null) {
        $setClauses[] = 'target_url = :target_url';
        $bindParams[':target_url'] = $data->target_url;
    }
    if ($data->is_active !== null) {
        $setClauses[] = 'is_active = :is_active';
        $bindParams[':is_active'] = $data->is_active;
    }
    if ($data->start_date !== null) {
        $setClauses[] = 'start_date = :start_date';
        $bindParams[':start_date'] = $data->start_date;
    }
    if ($data->end_date !== null) {
        $setClauses[] = 'end_date = :end_date';
        $bindParams[':end_date'] = $data->end_date;
    }

    // Toujours mettre à jour updated_at si des champs ont été modifiés
    if (!empty($setClauses)) {
        $setClauses[] = 'updated_at = NOW()';
    } else {
        // Si aucun champ n'est fourni pour la mise à jour, renvoyer une réponse et terminer
        sendResponse(['message' => 'No fields provided for update, no changes made.'], 200);
    }


    $query = "UPDATE publicites SET " . implode(', ', $setClauses) . " WHERE id = :id";
    $stmt = $conn->prepare($query);

    foreach ($bindParams as $param => $value) {
        // Déterminer le type PDO si nécessaire, en particulier pour PDO::PARAM_INT
        // Pour is_active, nous savons déjà que c'est un int
        if ($param === ':is_active') {
            $stmt->bindValue($param, $value, PDO::PARAM_INT);
        } else {
            $stmt->bindValue($param, $value);
        }
    }

    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendResponse(['message' => 'Publicite updated successfully.']);
        } else {
            sendError('Publicite not found or no data changed.', 404);
        }
    } else {
        sendError('Failed to update publicite.', 503);
    }
} else {
    sendError('Method not allowed.', 405);
}
?>