# Design Document - Gsports

## 1. Overview
**Gsports** is a realtime sports venue booking application designed to connect sports enthusiasts with venue owners (Mitra). The application focuses on ease of booking, community management via a "Split Bill" feature, and gamification through a digital scoreboard.

### Key Value Proposition
- **For Users:** Real-time booking, seamless "Split Bill" payment management, gamified match history (Streaks & Stats).
- **For Partners (Mitra):** Digital schedule management, financial dashboard, and direct booking management.

## 2. Architecture
The application follows **Clean Architecture** principles, organized by **Feature-First** structure.

### 2.1 Layers
1.  **Presentation Layer:** Flutter Widgets, BLoC/Cubit for state management.
2.  **Domain Layer:** Pure Dart entities, UseCases, Repository Interfaces.
3.  **Data Layer:** DTOs (Models), Data Sources (Remote/Local), Repository Implementations.

### 2.2 Tech Stack
-   **Framework:** Flutter (Latest Stable)
-   **State Management:** `flutter_bloc`
-   **Navigation:** `go_router` (Supports Deep Linking & Auth Redirects)
-   **DI:** `get_it`, `injectable`
-   **Backend:** Firebase (Auth, Firestore, Storage, Functions)
-   **Payment:** Midtrans (WebView/Snap)
-   **Design System:** Material 3 (Custom "Functional Minimalism" v2.0)

## 3. Detailed Design

### 3.1 Folder Structure
```text
lib/
├── core/                   # Shared kernel
│   ├── config/             # Router, Theme, Env
│   ├── constants/          # Colors, Assets, Strings
│   ├── error/              # Failure definitions
│   ├── presentation/       # Global Widgets (Buttons, Inputs)
│   └── usecases/           # Base UseCase
├── features/
│   ├── auth/               # Login (Google/Email), Register, Role Selection
│   ├── home/               # Venue Feed, Search, Banner
│   ├── venue/              # Venue Detail, Slot Selection, Reviews
│   ├── booking/            # Booking Flow, Payment (Midtrans), Split Bill Logic
│   ├── scoreboard/         # Digital Scoreboard logic
│   └── partner/            # Partner Dashboard (Revenue, Schedule, Venue CRUD)
├── main.dart
└── injection_container.dart
```

### 3.2 Features & Logic

#### A. Authentication (`features/auth`)
-   **Logic:** Uses `firebase_auth` (Email/Password & Google Sign-In).
-   **Flow:** Splash -> Login/Register (Guest Mode available) -> Role Check -> Home/Owner Dashboard.
-   **Roles:** User (`free`/`premium`), Mitra (`owner`).
-   **Guest Mode:** Allows browsing venues without logging in; strictly redirects to Login for Booking/Profile actions.

#### B. Venue Discovery (`features/home` & `features/venue`)
-   **Data Source:** Firestore `venues` collection.
-   **Logic:** Filter by City, Sport Type.
-   **UI:** `VenueCard` (v2.0 Design), Carousel Slider for banners.
-   **Detail:** Facilities grid, Operating Hours, Reviews, Favorite toggle.

#### C. Booking System (`features/booking`)
-   **Logic:**
    1.  Select Date & Time (Real-time availability check).
    2.  Create `bookings` document (Status: `waiting_payment`).
    3.  **Split Bill:** Host generates 6-char code. Guests join via code. Host pays upfront (or platform handles split - *future iteration*).
    4.  **Payment:** Trigger Midtrans Snap.
    5.  **Completion:** Status updates to `paid`, notification sent.

#### D. Gamification & Social (`features/profile` & `features/scoreboard`)
-   **Stats:** Track Matches Won/Lost.
-   **Streaks:** "Relationships" sub-collection tracks consecutive play frequency with friends.
-   **Scoreboard:** In-memory BLoC for fast scoring (Badminton/Futsal), saves match result to Firestore `matches`.

#### E. Partner Dashboard (`features/partner`)
-   **Guard:** Strictly `user.role == 'mitra'`.
-   **Features:**
    -   **Dashboard:** Income summary, Active Bookings.
    -   **Venue Management:** CRUD Venues (Upload Photos, Set Hours/Prices).
    -   **Schedule:** Calendar view of occupancy.

### 3.3 Data Schema (Firestore) - *See `softwaredesign/SCHEMA.md` for full details*

| Collection | Doc ID | Description |
| :--- | :--- | :--- |
| `users` | `uid` | Profile, Role, FCM Token. Sub-cols: `relationships`, `favorites`, `stats`. |
| `venues` | `auto` | Venue details, Operating Hours. Sub-col: `courts`. |
| `bookings` | `auto` | Transaction data, Status, Participants list (Split Bill). |
| `transactions`| `auto` | Financial log for payouts/admin fees. |
| `matches` | `auto` | History of games played (Scoreboard results). |
| `notifications`| `auto` | User notifications (Booking updates, Split Bill alerts). |

## 4. UI/UX Strategy - *See `softwaredesign/UIUX.md` v2.0*
-   **Theme:** "Functional Minimalism" v2.0 (High Contrast, Clean Lines).
-   **Colors:**
    -   Primary: Deep Black (`#121212`)
    -   Secondary: Pure White (`#FFFFFF`)
    -   Accent: Electric Blue (`#2962FF`) for primary actions.
    -   Status: Success Green, Warning Orange, Error Red.
-   **Typography:** Google Fonts (Inter/Roboto) with strict scale (H1-H4, Body, Caption).
-   **Core Components:**
    -   `CustomButton`: Solid/Outlined variants with defined heights/radius.
    -   `CustomTextField`: Unified input style with validation & password toggle.
    -   `VenueCard`: Modern card with image aspect ratio enforcement.

## 5. Security & Privacy
-   **Auth:** Firebase Auth enforced. Role-based Routing Guards.
-   **Firestore Rules:**
    -   `venues`: Public Read, Owner Write (verified ownership).
    -   `bookings`: Participant/Owner Read. Create restricted to Auth users.
    -   `users`: Public Read (Basic Info), Private Write (Self).

## 6. References
-   **Detailed Schema:** `softwaredesign/SCHEMA.md`
-   **Technical Specs:** `softwaredesign/TECH_SPEC.md`
-   **UI/UX Specs:** `softwaredesign/UIUX.md`