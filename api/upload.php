<?php
include_once __DIR__ . '/../config.php';
include_once __DIR__ . '/../utils.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Vérifier si un fichier a été uploadé
    if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
        sendError('No image uploaded or upload error.', 400);
    }

    $file = $_FILES['image'];

    // Répertoire de destination pour les uploads
    $uploadDir = __DIR__ . '/../publicites/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    // Validation du type de fichier
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (!in_array($file['type'], $allowedTypes)) {
        sendError('Invalid file type. Only JPEG, PNG, GIF are allowed.', 400);
    }

    // Validation de la taille du fichier (max 5MB)
    $maxFileSize = 5 * 1024 * 1024; // 5 MB
    if ($file['size'] > $maxFileSize) {
        sendError('File size exceeds the maximum limit of 5MB.', 400);
    }

    // Générer un nom de fichier unique
    $fileExtension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $fileName = uniqid() . '.' . $fileExtension;
    $filePath = $uploadDir . $fileName;

    // Déplacer le fichier temporaire vers le répertoire de destination
    if (move_uploaded_file($file['tmp_name'], $filePath)) {
        // Retourner l'URL complète de l'image (à adapter selon votre configuration de serveur)
        // Pour l'exemple, nous retournons un chemin relatif au dossier racine de l'application
        $imageUrl = 'publicites/' . $fileName; // Assurez-vous que le dossier 'uploads' est accessible via HTTP
        sendResponse(['message' => 'Image uploaded successfully.', 'image_url' => $imageUrl], 201);
    } else {
        sendError('Failed to move uploaded file.', 500);
    }

} else {
    sendError('Method not allowed.', 405);
}
?>