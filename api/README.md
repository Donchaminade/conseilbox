# API Documentation

This document provides an overview of the available API endpoints for managing `conseils` (advice) and `publicites` (advertisements).

**Base URL:** `https://grosbit.com/conseilbox/api/` (replace `your-domain.com` with your actual domain or IP address)

---

## General Information

*   **Authentication:** Not yet implemented (open access for now).
*   **Response Format:** All responses are in JSON format.
*   **Error Handling:**
    *   `400 Bad Request`: Missing or invalid parameters.
    *   `404 Not Found`: Resource not found.
    *   `405 Method Not Allowed`: HTTP method not supported for the endpoint.
    *   `429 Too Many Requests`: Rate limit exceeded.
    *   `500 Internal Server Error`: Generic server error.
    *   `503 Service Unavailable`: Database or other service error.
*   **Rate Limiting:** 60 requests per minute per IP address. `X-RateLimit-*` headers are provided in responses.

---

## 1. Conseils Endpoints

### 1.1. List all Conseils / Create a new Conseil

*   **Endpoint:** `/api/conseils/index.php`
*   **Methods:** `GET`, `POST`

#### `GET /api/conseils/index.php` - List Conseils

*   **Description:** Retrieves a list of conseils with optional pagination, filtering, and sorting.
*   **Query Parameters:**
    *   `page` (optional, integer, default: `1`): The page number for pagination.
    *   `limit` (optional, integer, default: `10`): The number of conseils per page.
    *   `sort_by` (optional, string, default: `created_at`): Column to sort by. Allowed values: `id`, `title`, `author`, `location`, `status`, `created_at`.
    *   `order` (optional, string, default: `DESC`): Sort order. Allowed values: `ASC`, `DESC`.
    *   `status` (optional, string): Filter by status. Allowed values: `pending`, `published`, `rejected`.
    *   `search` (optional, string): Search by `title`, `content`, `author`, or `location`.
*   **Example Request:**
    ```
    GET /api/conseils/index.php?page=1&limit=5&sort_by=title&order=ASC&status=published&search=optimiser
    ```
*   **Example Response (Success 200):**
    ```json
    {
        "total": 2,
        "page": 1,
        "limit": 5,
        "conseils": [
            {
                "id": "2",
                "title": "Optimiser la visibilité de vos projets en ligne",
                "content": "...",
                "anecdote": "...",
                "author": "adc",
                "location": "lome",
                "status": "published",
                "social_link_1": null,
                "social_link_2": null,
                "social_link_3": null,
                "created_at": "2025-12-04 14:50:58"
            }
        ]
    }
    ```

#### `POST /api/conseils/index.php` - Create Conseil

*   **Description:** Creates a new conseil.
*   **Request Body (application/json):**
    ```json
    {
        "title": "Mon Nouveau Conseil",
        "content": "Ceci est le contenu de mon super conseil.",
        "anecdote": "Une petite histoire amusante.",
        "author": "Test User",
        "location": "Paris",
        "status": "pending", // Optional, default 'pending'. Allowed: 'pending', 'published', 'rejected'
        "social_link_1": "https://facebook.com/test", // Optional
        "social_link_2": null, // Optional
        "social_link_3": null // Optional
    }
    ```
*   **Example Response (Success 201):**
    ```json
    {
        "message": "Conseil created successfully.",
        "id": "4"
    }
    ```
*   **Validation Rules:**
    *   `title`: Required, 3-255 characters.
    *   `content`: Required, min 10 characters.
    *   `author`: Required, 2-255 characters.
    *   `status`: Allowed values: `pending`, `published`, `rejected`.
    *   `social_link_1/2/3`: Must be valid URLs if provided.

### 1.2. Get Single Conseil

*   **Endpoint:** `/api/conseils/read_single.php`
*   **Method:** `GET`
*   **Query Parameters:**
    *   `id` (required, integer): The ID of the conseil to retrieve.
*   **Example Request:**
    ```
    GET /api/conseils/read_single.php?id=2
    ```
*   **Example Response (Success 200):**
    ```json
    {
        "id": "2",
        "title": "Optimiser la visibilité de vos projets en ligne",
        "content": "...",
        "anecdote": "...",
        "author": "adc",
        "location": "lome",
        "status": "published",
        "social_link_1": null,
        "social_link_2": null,
        "social_link_3": null,
        "created_at": "2025-12-04 14:50:58"
    }
    ```
*   **Example Response (Error 404):**
    ```json
    {
        "message": "Conseil not found."
    }
    ```

### 1.3. Update Conseil

*   **Endpoint:** `/api/conseils/update.php`
*   **Method:** `PUT`
*   **Description:** Updates an existing conseil. Only provided fields will be updated.
*   **Request Body (application/json):**
    ```json
    {
        "id": "2",
        "title": "Titre du conseil mis à jour",
        "status": "published",
        "location": "Marseille"
    }
    ```
*   **Example Response (Success 200):**
    ```json
    {
        "message": "Conseil updated successfully."
    }
    ```
*   **Validation Rules:** Same as `POST` for `title`, `content`, `author`, `status`, `social_link_1/2/3`. `id` is required and must be numeric.

### 1.4. Delete Conseil

*   **Endpoint:** `/api/conseils/delete.php`
*   **Method:** `DELETE`
*   **Request Body (application/json):**
    ```json
    {
        "id": "2"
    }
    ```
*   **Example Response (Success 200):**
    ```json
    {
        "message": "Conseil deleted successfully."
    }
    ```
*   **Example Response (Error 404):**
    ```json
    {
        "message": "Conseil not found."
    }
    ```

---

## 2. Publicites Endpoints

### 2.1. List all Publicites / Create a new Publicite

*   **Endpoint:** `/api/publicites/index.php`
*   **Methods:** `GET`, `POST`

#### `GET /api/publicites/index.php` - List Publicites

*   **Description:** Retrieves a list of publicites with optional pagination, filtering, and sorting.
*   **Query Parameters:**
    *   `page` (optional, integer, default: `1`): The page number for pagination.
    *   `limit` (optional, integer, default: `10`): The number of publicites per page.
    *   `sort_by` (optional, string, default: `created_at`): Column to sort by. Allowed values: `id`, `title`, `is_active`, `start_date`, `end_date`, `created_at`.
    *   `order` (optional, string, default: `DESC`): Sort order. Allowed values: `ASC`, `DESC`.
    *   `is_active` (optional, integer): Filter by active status. Allowed values: `0` (inactive) or `1` (active).
    *   `start_date_min` (optional, date string): Filter for publicites starting on or after this date (format: YYYY-MM-DD).
    *   `end_date_max` (optional, date string): Filter for publicites ending on or before this date (format: YYYY-MM-DD).
    *   `search` (optional, string): Search by `title` or `content`.
*   **Example Request:**
    ```
    GET /api/publicites/index.php?page=1&limit=5&sort_by=title&order=ASC&is_active=1&search=optimiser
    ```
*   **Example Response (Success 200):**
    ```json
    {
        "total": 1,
        "page": 1,
        "limit": 5,
        "publicites": [
            {
                "id": "2",
                "title": "Optimiser la visibilité de vos projets en ligne",
                "content": "...",
                "image_url": "publicites/01KBPYF0HNM7A5MV5XN8QC5YK5.png",
                "target_url": "https://www.linkedin.com",
                "is_active": "1",
                "start_date": null,
                "end_date": null,
                "created_at": "2025-12-05 09:46:03"
            }
        ]
    }
    ```

#### `POST /api/publicites/index.php` - Create Publicite

*   **Description:** Creates a new publicite. Supports `application/json` or `multipart/form-data` for image upload.
*   **Request Body (application/json):**
    ```json
    {
        "title": "Nouvelle Publicité",
        "content": "Le contenu de la publicité...",
        "image_url": "uploads/ad_image.png", // Optional: Path to an image uploaded via /api/upload.php or an external URL
        "target_url": "http://example.com/ad_landing_page", // Optional
        "is_active": 1, // Optional, default 0. Allowed: 0 or 1
        "start_date": "2025-01-01", // Optional, format YYYY-MM-DD
        "end_date": "2025-12-31" // Optional, format YYYY-MM-DD
    }
    ```
*   **Request Body (multipart/form-data):**
    *   Fields: `title`, `content`, `target_url` (optional), `is_active` (optional), `start_date` (optional), `end_date` (optional).
    *   File: `image` (optional, file type: JPEG, PNG, GIF, max 5MB). If provided, this will be uploaded and its path will be used for `image_url`.
*   **Example Response (Success 201):**
    ```json
    {
        "message": "Publicite created successfully.",
        "id": "3"
    }
    ```
*   **Validation Rules:**
    *   `title`: Required, 3-255 characters.
    *   `content`: Required, min 10 characters.
    *   `image_url`: Must be a valid URL if provided, or a path to an uploaded image.
    *   `target_url`: Must be a valid URL if provided.
    *   `is_active`: Allowed values: `0`, `1`.
    *   `start_date`, `end_date`: Must be valid date formats (YYYY-MM-DD). `start_date` cannot be after `end_date`.
    *   `image`: If uploaded via `multipart/form-data`, must be JPEG, PNG, GIF, max 5MB.

### 2.2. Get Single Publicite

*   **Endpoint:** `/api/publicites/read_single.php`
*   **Method:** `GET`
*   **Query Parameters:**
    *   `id` (required, integer): The ID of the publicite to retrieve.
*   **Example Request:**
    ```
    GET /api/publicites/read_single.php?id=2
    ```
*   **Example Response (Success 200):**
    ```json
    {
        "id": "2",
        "title": "Optimiser la visibilité de vos projets en ligne",
        "content": "...",
        "image_url": "publicites/01KBPYF0HNM7A5MV5XN8QC5YK5.png",
        "target_url": "https://www.linkedin.com",
        "is_active": "1",
        "start_date": null,
        "end_date": null,
        "created_at": "2025-12-05 09:46:03"
    }
    ```

### 2.3. Update Publicite

*   **Endpoint:** `/api/publicites/update.php`
*   **Method:** `PUT`
*   **Description:** Updates an existing publicite. Only provided fields will be updated. Supports `application/json` or `multipart/form-data` for image upload.
*   **Request Body (application/json):**
    ```json
    {
        "id": "2",
        "title": "Titre Publicité mis à jour",
        "is_active": 0,
        "image_url": "uploads/new_ad_image.jpg" // Optional: new path to uploaded image or new external URL, or null to remove
    }
    ```
*   **Request Body (multipart/form-data):**
    *   Fields: `id` (required), plus any updatable fields like `title`, `content`, etc.
    *   File: `image` (optional, file type: JPEG, PNG, GIF, max 5MB). If provided, this will be uploaded and its path will be used for `image_url`.
*   **Example Response (Success 200):**
    ```json
    {
        "message": "Publicite updated successfully."
    }
    ```
*   **Validation Rules:** Same as `POST` for `title`, `content`, `image_url`, `target_url`, `is_active`, `start_date`, `end_date`, `image`. `id` is required and must be numeric.

### 2.4. Delete Publicite

*   **Endpoint:** `/api/publicites/delete.php`
*   **Method:** `DELETE`
*   **Request Body (application/json):**
    ```json
    {
        "id": "2"
    }
    ```
*   **Example Response (Success 200):**
    ```json
    {
        "message": "Publicite deleted successfully."
    }
    ```
*   **Example Response (Error 404):**
    ```json
    {
        "message": "Publicite not found."
    }
    ```

---

## 3. File Upload Endpoint

### 3.1. Upload Image

*   **Endpoint:** `/api/upload.php`
*   **Method:** `POST`
*   **Description:** Uploads an image file to the server. Use this endpoint to get an `image_url` if you want to store a local image path.
*   **Request Body (multipart/form-data):**
    *   File: `image` (required, file type: JPEG, PNG, GIF, max 5MB).
*   **Example Request:**
    ```bash
    curl -X POST -F "image=@/path/to/your/image.jpg" http://your-domain.com/api/upload.php
    ```
*   **Example Response (Success 201):**
    ```json
    {
        "message": "Image uploaded successfully.",
        "image_url": "uploads/unique_filename.jpg"
    }
    ```
*   **Validation Rules:**
    *   `image`: Required, must be JPEG, PNG, GIF, max 5MB.

---