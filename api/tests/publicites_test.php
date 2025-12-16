<?php
// api/tests/publicites_test.php

// Ce fichier contient des exemples de requêtes que vous pouvez utiliser
// avec des outils comme `curl` ou Postman pour tester l'API des publicités.

// --- CONFIGURATION DE BASE ---
// Remplacez cette URL par l'adresse de votre API
$baseUrl = 'http://localhost/conseildash/api/publicites/';

// --- TESTS POUR /api/publicites/index.php ---

echo "<h2>Tests pour /api/publicites/index.php</h2>";

// 1. GET: Lister toutes les publicités (sans paramètres)
echo "<h3>GET: Lister toutes les publicités</h3>";
echo "curl -X GET " . $baseUrl . "index.php\n\n";

// 2. GET: Lister les publicités avec pagination, tri et filtres
echo "<h3>GET: Lister les publicités (pagination, tri, filtres)</h3>";
echo "curl -X GET \"" . $baseUrl . "index.php?page=1&limit=2&sort_by=title&order=ASC&is_active=1&search=publicite\"\n\n";

// 3. POST: Créer une nouvelle publicité (JSON)
echo "<h3>POST: Créer une nouvelle publicité (JSON)</h3>";
echo "curl -X POST -H \"Content-Type: application/json\" -d '{\n    \"title\": \"Ma Nouvelle Publicité\",\n    \"content\": \"Le contenu de ma publicité très efficace.\",\n    \"image_url\": \"https://example.com/ad1.jpg\",\n    \"target_url\": \"https://example.com/landing-page\",\n    \"is_active\": 1,\n    \"start_date\": \"2025-01-01\",\n    \"end_date\": \"2025-12-31\"\n}' " . $baseUrl . "index.php\n\n";

// 4. POST: Créer une nouvelle publicité (Multipart/Form-Data avec fichier image)
echo "<h3>POST: Créer une nouvelle publicité (Multipart/Form-Data avec fichier)</h3>";
echo "curl -X POST -F \"title=Publicité avec image\" -F \"content=Publicité pour un nouveau produit.\" -F \"target_url=https://newproduct.com\" -F \"image=@/path/to/your/ad_image.png\" -F \"is_active=1\" " . $baseUrl . "index.php\n\n";
echo "Note: Remplacez `/path/to/your/ad_image.png` par le chemin réel de votre image.\n\n";


// --- TESTS POUR /api/publicites/read_single.php ---

echo "<h2>Tests pour /api/publicites/read_single.php</h2>";

// 1. GET: Récupérer une publicité par ID
echo "<h3>GET: Récupérer une publicité par ID</h3>";
echo "curl -X GET \"" . $baseUrl . "read_single.php?id=1\"\n\n"; // Remplacez 1 par un ID existant

// 2. GET: Récupérer une publicité inexistante
echo "<h3>GET: Récupérer une publicité inexistante</h3>";
echo "curl -X GET \"" . $baseUrl . "read_single.php?id=99999\"\n\n";


// --- TESTS POUR /api/publicites/update.php ---

echo "<h2>Tests pour /api/publicites/update.php</h2>";

// 1. PUT: Mettre à jour une publicité (JSON)
echo "<h3>PUT: Mettre à jour une publicité (JSON)</h3>";
echo "curl -X PUT -H \"Content-Type: application/json\" -d '{ \"id\": \"1\", \"title\": \"Publicité mise à jour\", \"is_active\": 0, \"end_date\": \"2026-06-30\" }' " . $baseUrl . "update.php\n\n"; // Remplacez 1 par un ID existant

// 2. PUT: Mettre à jour une publicité (Multipart/Form-Data avec nouvelle image)
echo "<h3>PUT: Mettre à jour une publicité (Multipart/Form-Data avec nouvelle image)</h3>";
echo "curl -X POST -F \"id=1\" -F \"title=Publicité image à jour\" -F \"image=@/path/to/new_ad_image.jpg\" -X PUT " . $baseUrl . "update.php\n\n";
echo "Note: Pour les requêtes PUT avec multipart/form-data via curl, utilisez '-X PUT' avec '-F'.\n\n";


// --- TESTS POUR /api/publicites/delete.php ---

echo "<h2>Tests pour /api/publicites/delete.php</h2>";

// 1. DELETE: Supprimer une publicité
echo "<h3>DELETE: Supprimer une publicité</h3>";
echo "curl -X DELETE -H \"Content-Type: application/json\" -d '{\"id\": \"1\"}' " . $baseUrl . "delete.php\n\n"; // Remplacez 1 par un ID existant et non utilisé.

?>
