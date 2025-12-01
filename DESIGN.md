# Design Document - Gsports

## 1. Overview
**Gsports** is a realtime sports venue booking application designed to connect sports enthusiasts with venue owners (Mitra). The application focuses on ease of booking, community management via a "Split Bill" feature, and gamification through a digital scoreboard.

### Key Value Proposition
- **For Users:** Real-time booking, split bill management, gamified match history.
- **For Partners (Mitra):** Digital schedule management, financial dashboard.

## 2. Architecture
The application follows **Clean Architecture** principles, organized by **Feature-First** structure.

### 2.1 Layers
1.  **Presentation Layer:** Flutter Widgets, BLoC/Cubit for state management.
2.  **Domain Layer:** Pure Dart entities, UseCases, Repository Interfaces.
3.  **Data Layer:** DTOs (Models), Data Sources (Remote/Local), Repository Implementations.

### 2.2 Tech Stack
-   **Framework:** Flutter (Latest Stable)
-   **State Management:** `flutter_bloc`
-   **Navigation:** `go_router`
-   **DI:** `get_it`, `injectable`
-   **Backend:** Firebase (Auth, Firestore, Storage, Functions)
-   **Payment:** Midtrans (WebView/Snap)
-   **Design System:** Material 3 (Minimalist Black & White)

## 3. Detailed Design

### 3.1 Folder Structure
```text
lib/
├── core/                   # Shared kernel
│   ├── config/             # Router, Theme, Env
│   ├── constants/          # Colors, Assets, Strings
│   ├── error/              # Failure definitions
│   └── usecases/           # Base UseCase
├── features/
│   ├── auth/               # Login, Register, Forgot Password
│   ├── home/               # Venue Feed, Search, Banner
│   ├── venue/              # Venue Detail, Slot Selection
│   ├── booking/            # Cart, Payment (Midtrans), Split Bill
│   ├── scoreboard/         # Digital Scoreboard logic
│   └── partner/            # Partner Dashboard (Revenue, Schedule)
├── main.dart
└── injection_container.dart
```

### 3.2 Features & Logic

#### A. Authentication (`features/auth`)
-   **Logic:** Uses `firebase_auth`.
-   **Flow:** Splash -> Login/Register -> Home.
-   **Roles:** User (`free`/`premium`), Mitra (`owner`). Stored in Firestore `users` collection.

#### B. Venue Discovery (`features/home` & `features/venue`)
-   **Data Source:** Firestore `venues` collection.
-   **Logic:** Filter by City, Sport Type (Chips).
-   **UI:** `VenueCard` (Image, Name, Price, Location).
-   **Detail:** Show facilities, fetch sub-collection `courts`.

#### C. Booking System (`features/booking`)
-   **Logic:**
    1.  Select Date & Time (Check availability via Firestore query).
    2.  Create `bookings` document with status `waiting_payment`.
    3.  Trigger Cloud Function/API to get Midtrans Snap Token.
    4.  Open WebView.
    5.  Listen for status change (`paid`).
-   **Split Bill:** Generate a unique 6-char code. Other users join via code. Host pays upfront.

#### D. Scoreboard (`features/scoreboard`)
-   **State:** In-memory BLoC for fast updates.
-   **Modes:** Badminton (21 pts), Futsal (Timer), Tennis.
-   **Action:** "Save Match" writes to `matches` collection in Firestore.

#### E. Partner Dashboard (`features/partner`)
-   **Guard:** Only accessible if `user.role == 'mitra'`.
-   **Data:** Aggregated views of `bookings` and `transactions`.

### 3.3 Data Schema (Firestore)

| Collection | Doc ID | Description |
| :--- | :--- | :--- |
| `users` | `uid` | Profile, Role, Tier. Sub-col: `stats`. |
| `venues` | `auto` | Venue info. Sub-col: `courts`. |
| `bookings` | `auto` | Transcation data, Status, Participants. |
| `transactions`| `auto` | Financial log for payout. |
| `matches` | `auto` | History of games played. |

## 4. UI/UX Strategy
-   **Theme:** Functional Minimalism.
-   **Colors:** Primary Black (`#212121`), Accent Electric Blue (`#2962FF`), Surface White.
-   **Components:**
    -   `OutlinedCard` (No shadow, thin border).
    -   `FilledButton` (Black bg).
    -   `Shimmer` for loading states.

## 5. Security & Privacy
-   **Auth:** Firebase Auth enforced.
-   **Firestore Rules:**
    -   `venues`: Public Read, Owner Write.
    -   `bookings`: Owner/Mitra Read.
    -   `transactions`: No client write.

## 6. References
-   [Flutter Clean Architecture](https://github.com/ResoCoder/flutter-clean-architecture-proposal)
-   [Bloc Library](https://bloclibrary.dev)
-   [Material 3 Design](https://m3.material.io)
