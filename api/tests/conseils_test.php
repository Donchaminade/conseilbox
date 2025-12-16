<?php
// api/tests/conseils_test.php

// Ce fichier contient des exemples de requêtes que vous pouvez utiliser
// avec des outils comme `curl` ou Postman pour tester l'API des conseils.

// --- CONFIGURATION DE BASE ---
// Remplacez cette URL par l'adresse de votre API
$baseUrl = 'http://localhost/conseildash/api/conseils/';

// --- TESTS POUR /api/conseils/index.php ---

echo "<h2>Tests pour /api/conseils/index.php</h2>";

// 1. GET: Lister tous les conseils (sans paramètres)
echo "<h3>GET: Lister tous les conseils</h3>";
echo "curl -X GET " . $baseUrl . "index.php\n\n";

// 2. GET: Lister les conseils avec pagination et tri
echo "<h3>GET: Lister les conseils (pagination, tri, filtre)</h3>";
echo "curl -X GET \"" . $baseUrl . "index.php?page=1&limit=2&sort_by=title&order=ASC&status=published&search=optimiser\"\n\n";

// 3. POST: Créer un nouveau conseil (JSON)
echo "<h3>POST: Créer un nouveau conseil (JSON)</h3>";
echo "curl -X POST -H \"Content-Type: application/json\" -d '{ 
    \"title\": \"Mon Nouveau Conseil\",
    \"content\": \"Ceci est le contenu de mon super conseil.\",
    \"anecdote\": \"Une petite histoire amusante.\",
    \"author\": \"Test User\",
    \"location\": \"Paris\",
    \"status\": \"pending\",
    \"social_link_1\": \"https://facebook.com/test\",
    \"image\": null
}' " . $baseUrl . "index.php\n\n";

// 4. POST: Créer un nouveau conseil (Multipart/Form-Data avec fichier image)
echo "<h3>POST: Créer un nouveau conseil (Multipart/Form-Data avec fichier)</h3>";
echo "curl -X POST -F \"title=Conseil avec image\" -F \"content=Le contenu avec une belle image.\" -F \"author=Image Uploader\" -F \"image=@/path/to/your/image.jpg\" " . $baseUrl . "index.php\n\n";
echo "Note: Remplacez `/path/to/your/image.jpg` par le chemin réel de votre image.\n\n";


// --- TESTS POUR /api/conseils/read_single.php ---

echo "<h2>Tests pour /api/conseils/read_single.php</h2>";

// 1. GET: Récupérer un conseil par ID
echo "<h3>GET: Récupérer un conseil par ID</h3>";
echo "curl -X GET \"" . $baseUrl . "read_single.php?id=1\"\n\n"; // Remplacez 1 par un ID existant

// 2. GET: Récupérer un conseil inexistant
echo "<h3>GET: Récupérer un conseil inexistant</h3>";
echo "curl -X GET \"" . $baseUrl . "read_single.php?id=99999\"\n\n";


// --- TESTS POUR /api/conseils/update.php ---

echo "<h2>Tests pour /api/conseils/update.php</h2>";

// 1. PUT: Mettre à jour un conseil (JSON)
echo "<h3>PUT: Mettre à jour un conseil (JSON)</h3>";
echo "curl -X PUT -H \"Content-Type: application/json\" -d '{ 
    \"id\": \"1\",
    \"title\": \"Conseil mis à jour via API\",
    \"status\": \"published\",
    \"location\": \"Marseille\" 
}' " . $baseUrl . "update.php\n\n"; // Remplacez 1 par un ID existant

// 2. PUT: Mettre à jour un conseil (Multipart/Form-Data avec nouvelle image)
echo "<h3>PUT: Mettre à jour un conseil (Multipart/Form-Data avec nouvelle image)</h3>";
echo "curl -X POST -F \"id=1\" -F \"title=Conseil avec image à jour\" -F \"image=@/path/to/new_image.png\" -X PUT " . $baseUrl . "update.php\n\n";
echo "Note: Pour les requêtes PUT avec multipart/form-data via curl, utilisez '-X PUT' avec '-F'.\n\n";


// --- TESTS POUR /api/conseils/delete.php ---

echo "<h2>Tests pour /api/conseils/delete.php</h2>";

// 1. DELETE: Supprimer un conseil
echo "<h3>DELETE: Supprimer un conseil</h3>";
echo "curl -X DELETE -H \"Content-Type: application/json\" -d '{\"id\": \"1\"}' " . $baseUrl . "delete.php\n\n"; // Remplacez 1 par un ID existant et non utilisé.


?>
