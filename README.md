# Card Organizer App

A Flutter application that organizes a standard 52-card deck into 4 suit folders (Hearts, Diamonds, Clubs, Spades) using SQLite for local storage.

## Features

- **4 Suit Folders** — Hearts, Diamonds, Clubs, Spades, each pre-populated with 13 cards
- **Card Images** — Loaded from the Deck of Cards API (network images with fallback icon)
- **Full CRUD** — Create, read, update, and delete cards and folders
- **Cascade Delete** — Deleting a folder removes all its cards (SQLite foreign key `ON DELETE CASCADE`)
- **Delete Confirmations** — Non-dismissible dialogs warn before any destructive action
- **Add/Edit Cards** — Form with card name, suit dropdown, and image URL input

## Project Structure

```
lib/
├── main.dart
├── database/
│   └── database_helper.dart      # SQLite setup, schema, prepopulation
├── models/
│   ├── folder.dart               # Folder model with toMap/fromMap
│   └── playing_card.dart         # PlayingCard model with toMap/fromMap
├── repositories/
│   ├── folder_repository.dart    # CRUD operations for folders
│   └── card_repository.dart      # CRUD operations for cards
└── screens/
    ├── folders_screen.dart       # Grid of suit folders with card counts
    ├── cards_screen.dart         # List of cards with images, edit/delete
    └── add_edit_card_screen.dart # Form to add or edit a card
```

## Database Schema

**folders table**

| Column      | Type    | Description              |
|-------------|---------|--------------------------|
| id          | INTEGER | Primary key (autoincrement) |
| folder_name | TEXT    | Suit name (Hearts, etc.) |
| timestamp   | TEXT    | Creation date/time       |

**cards table**

| Column    | Type    | Description                        |
|-----------|---------|------------------------------------|
| id        | INTEGER | Primary key (autoincrement)        |
| card_name | TEXT    | Card name (Ace, 2, King, etc.)     |
| suit      | TEXT    | Card suit                          |
| image_url | TEXT    | Image URL (Deck of Cards API)      |
| folder_id | INTEGER | Foreign key → folders(id) CASCADE  |

## Running the App

> **Note:** SQLite (`sqflite`) requires Android or iOS — it does not work on Flutter web.

```bash
# Install dependencies
flutter pub get

# Run on Android device/emulator
flutter run -d android
```

## Dependencies

- `sqflite` — SQLite database
- `path` / `path_provider` — Database file path resolution
- `image_picker` — (available for bonus image picking feature)
- `http` — (available for network requests)
