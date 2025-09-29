# IPTV Client Management App Blueprint

## Overview

This document outlines the plan and features for a Flutter application designed to manage IPTV clients. The app will use a local SQLite database to store client information securely on the device, providing a complete CRUD (Create, Read, Update, Delete) solution.

## Core Features

*   **Client Management:** Add, edit, delete, and view client information.
*   **Local Database:** All data will be stored locally using `sqflite`.
*   **Modern UI:** A clean, user-friendly interface built with Material Design 3 components, `google_fonts`, and a theme that supports both light and dark modes.
*   **State Management:** The `provider` package will be used for efficient state management, particularly for theme switching.

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
|   `-- database_helper.dart
|-- providers/
|   |-- client_provider.dart
|   `-- theme_provider.dart
|-- screens/
|   |-- client_list_screen.dart
|   `-- add_edit_client_screen.dart
`-- main.dart
```

## Current Action Plan

1.  **DONE** - Create `blueprint.md`.
2.  **DOING** - Add dependencies to `pubspec.yaml`.
3.  **TODO** - Create the `Client` data model.
4.  **TODO** - Implement the `DatabaseHelper` for database operations.
5.  **TODO** - Create a `ClientProvider` to manage the client list state.
6.  **TODO** - Implement the main `ClientListScreen` to display clients.
7.  **TODO** - Implememnt the `AddEditClientScreen` for creating and updating clients.
8.  **TODO** - Set up the main application entry point with themes and providers.
