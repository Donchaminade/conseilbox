<?php
// api/tests/upload_test.php

// Ce fichier contient des exemples de requêtes que vous pouvez utiliser
// avec des outils comme `curl` ou Postman pour tester l'endpoint d'upload.

// --- CONFIGURATION DE BASE ---
// Remplacez cette URL par l'adresse de votre API
$baseUrl = 'http://localhost/conseildash/api/upload.php';

echo "<h2>Tests pour /api/upload.php</h2>";

// 1. POST: Uploader un fichier image valide
echo "<h3>POST: Uploader une image JPEG valide</h3>";
echo "curl -X POST -F \"image=@/path/to/your/image.jpg\" " . $baseUrl . "\n\n";
echo "Note: Remplacez `/path/to/your/image.jpg` par le chemin réel d'une image JPEG sur votre système.\n\n";

echo "<h3>POST: Uploader une image PNG valide</h3>";
echo "curl -X POST -F \"image=@/path/to/your/image.png\" " . $baseUrl . "\n\n";
echo "Note: Remplacez `/path/to/your/image.png` par le chemin réel d'une image PNG sur votre système.\n\n";

// 2. POST: Tenter d'uploader un fichier non-image
echo "<h3>POST: Tenter d'uploader un fichier non-image (ex: texte)</h3>";
echo "curl -X POST -F \"image=@/path/to/your/document.txt\" " . $baseUrl . "\n\n";
echo "Note: Remplacez `/path/to/your/document.txt` par le chemin réel d'un fichier texte ou autre non-image.\n\n";

// 3. POST: Tenter d'uploader un fichier trop grand (si vous avez un fichier > 5MB)
echo "<h3>POST: Tenter d'uploader un fichier trop grand</h3>";
echo "curl -X POST -F \"image=@/path/to/your/large_image.jpg\" " . $baseUrl . "\n\n";
echo "Note: Remplacez `/path/to/your/large_image.jpg` par le chemin réel d'une image de plus de 5MB.\n\n";

// 4. GET: Tenter d'accéder à l'endpoint avec une méthode non autorisée
echo "<h3>GET: Tenter d'accéder avec GET (méthode non autorisée)</h3>";
echo "curl -X GET " . $baseUrl . "\n\n";

?>