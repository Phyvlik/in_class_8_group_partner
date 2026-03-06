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

## Bonus Features

### Gallery Image Picker with Base64 Storage

When adding or editing a card, users can tap **"Pick Image from Gallery"** to select a photo from their device instead of typing a URL.

**Implementation approach:**
- Uses the `image_picker` package to open the device photo library
- The selected image is read as raw bytes and encoded to a Base64 string using `dart:convert`
- The Base64 string is stored directly in the `image_url` column of the SQLite `cards` table — no separate file or file path needed
- On display, the app checks whether `image_url` starts with `http`: if not, it decodes the Base64 back to bytes and renders with `Image.memory`; otherwise it renders with `Image.network`
- If both a gallery image and a URL are provided, the gallery image takes priority
- Required permissions added: `READ_MEDIA_IMAGES` (Android 13+), `READ_EXTERNAL_STORAGE` (Android ≤12), `NSPhotoLibraryUsageDescription` (iOS)

**Trade-offs:** Storing Base64 in SQLite keeps all data in one place with no file management, but increases database size. This is acceptable for a small card collection.

## Dependencies

- `sqflite` — SQLite database
- `path` / `path_provider` — Database file path resolution
- `image_picker` — (available for bonus image picking feature)
- `http` — (available for network requests)
