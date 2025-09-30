# IPTV Client Management App Blueprint

## Overview

This document outlines the plan and features for a Flutter application designed to manage IPTV clients. The app will use a local SQLite database to store client information securely on the device, providing a complete CRUD (Create, Read, Update, Delete) solution.

## Core Features

*   **Client Management:** Add, edit, delete, and view client information.
*   **Local Database:** All data will be stored locally using `sqflite`.
*   **Modern UI:** A clean, user-friendly interface built with Material Design 3 components, `google_fonts`, and a theme that supports both light and dark modes.
*   **State Management:** The `provider` package will be used for efficient state management.
*   **Expiration Notifications:** The app will schedule local notifications to remind the user about client subscriptions that are about to expire.
*   **Client Import/Export:** Functionality to import clients in bulk from CSV and to export all clients to a CSV file.

## Data Model

The `Client` model will have the following attributes:

*   `id`: Integer (Primary Key)
*   `name`: TEXT
*   `lastName`: TEXT
*   `username`: TEXT
*   `password`: TEXT
*   `phone`: TEXT
*   `startDate`: TEXT (ISO 8601 format)
*   `endDate`: TEXT (ISO 8601 format)
*   `months`: INTEGER
*   `price`: REAL

## Project Structure

```
lib/
|-- models/
|   `-- client_model.dart
|-- helpers/
|   |-- database_helper.dart
|   `-- notification_helper.dart
|-- providers/
|   |-- client_provider.dart
|   `-- theme_provider.dart
|-- screens/
|   |-- client_list_screen.dart
|   `-- add_edit_client_screen.dart
`-- main.dart
```

## Current Action Plan: Export Clients to File

1.  **DONE** - Update `blueprint.md` with the new export feature plan.
2.  **DOING** - Add dependencies (`share_plus`, `path_provider`) to `pubspec.yaml`.
3.  **TODO** - Add an "Export" button to the `ClientListScreen`.
4.  **TODO** - Implement the CSV generation and sharing logic in `ClientProvider`.
5.  **TODO** - Provide user feedback during and after the export process.
