# Implementation Plan - Gsports

## Strategy: Agile Iterative & Incremental
This project follows an Agile approach. Completed modules (e.g., Auth, Venue) will be revisited and refined in later sprints to accommodate new requirements like Google Sign-In, Owner Roles, and UI Polish.

## Journal
*   **Sprint 3 Completed:** Venue Discovery (Supply Side) has been implemented. Domain, Data, and Presentation layers are complete. `VenueSeeder` added for dummy data.
*   **Sprint 2 Completed:** Authentication and User Profile (Domain, Data, Presentation, and DI) have been fully implemented.
*   **Phase 1 (Foundation):** Project created, dependencies added. Folder structure set up. Core config (Theme, Router, DI) implemented. Encountered `CardTheme` analysis error (type mismatch with `CardThemeData?`), temporarily commented out `cardTheme` in `AppTheme`. `build_runner` run but no injectables yet. Firebase setup for Android successfully completed, including `firebase_options.dart` generation and `main.dart` update.
*   **Sprint 4 Completed:** Midtrans integration with Re-query logic & Zombie Booking prevention is implemented.
*   **Sprint 5 Completed:** Foundation, Basic Auth, Venue Discovery, Booking System, Payment (Midtrans), and Split Bill are functional (MVP level).
*   **Sprint 6 Completed:** UI Foundation, Auth Revolution, and Guest Mode.
    *   **Design System:** Implemented v2.1 Design Tokens (Colors, Typography) and Core Widgets (`CustomButton`, `CustomTextField`).
    *   **Auth Revamp:** Added Google Sign-In (Credential Manager), Multi-Role Registration (Player vs Owner), and Role-Based Navigation.
    *   **Guest Mode:** Implemented Router Whitelisting to allow unauthenticated exploration of Home and Venue Details. Guests are redirected to Login only when attempting to book.
*   **Sprint 8 Completed:** Discovery & Booking Experience Polish (UI/UX v2.2).
    *   **Home Revamp:** Dynamic Header (User/Guest), Search Bar, and Category Rail.
    *   **Venue Detail:** Overlapping "Stack" layout, Collapsing Image Header, Sticky Title, and Facilities Chips.
    *   **Search Page:** Dedicated search screen with filtering logic.
    *   **Calendar:** Improved date picker with full calendar access and immediate availability refresh.
    *   **Visuals:** Full migration to "Modern Blue" (#1565C0) theme and rounded aesthetics.
*   **Sprint 8 Polish & Stability:**
    *   **Payment Stability:** Fixed false-positive success states, implemented robust Midtrans status syncing (`pending`, `not_found`), and fixed booking cancellation logic.
    *   **Auto-Refresh:** Implemented automatic data refreshing for Booking History when switching tabs or returning from a detail page.
    *   **Bug Fixes:** Resolved UI crashes in Booking Detail and optimized navigation flows.
*   **Sprint 9 Phase 1 Completed:** My Bookings UI & Schema Polish.
    *   **Card Redesign:** Implemented color-coded strips (Orange/Green/Red) and prominent sport icons.
    *   **Information Density:** Denormalized `venueName`, `courtName`, and `venueLocation` into Booking documents for instant display without extra queries.
    *   **Visual Hierarchy:** Highlighted booking time (Bold/Primary Color) in both History Card and Detail Page.
    *   **Tab Logic:** Refined "Berlangsung" (Active) vs "Riwayat" (History) filtering using `endTime` to correctly handle ongoing matches.

## Phase 1: Foundation & Setup
- [x] Create Flutter project `gsports` using `create_project`.
- [x] Clean up default boilerplate.
- [x] Update `pubspec.yaml` with dependencies.
- [x] Run `flutter pub get`.
- [x] Setup **Clean Architecture** Folder Structure.
- [x] Implement **Core Config**.
- [x] Initialize **Firebase**.

## Phase 2: Authentication & User Profile
- [x] **Domain Layer (Auth)**
- [x] **Data Layer (Auth)**
- [x] **Presentation Layer (Auth)**
- [x] **Profile Management**
- [x] **Dependency Injection**

## Phase 3: Venue Discovery (Supply Side)
- [x] **Domain Layer (Venue)**
- [x] **Data Layer (Venue)**
- [x] **Presentation Layer (Venue)**
- [x] **Seeding**

## Phase 4: Core Booking & Payment
- [x] **Domain Layer (Booking)**
- [x] **Data Layer (Booking)**
- [x] **Presentation Layer (Booking)**
- [x] **Midtrans Integration**

## Phase 5: Unique Features
- [x] **Split Bill** (MVP)
- [ ] **Scoreboard**

## Sprint 6: UI Foundation & Auth Revolution (The Face Lift)
- [x] **Design System & Assets:** Implemented v2.1 Design Tokens & Core Widgets.
- [x] **Auth Logic Upgrade:** Google Auth & Role Logic.
- [x] **Auth UI Revamp:** Login/Register Pages with new design & Guest Mode.

## Sprint 8: Discovery & Booking Experience (User Side)
*Goal: Make finding and booking venues seamless and visually appealing.*

### Phase 1: Home Revamp
- [x] **Header:** Dynamic Greeting & Notification Icon.
- [x] **Search:** `SearchBar` widget & Search Page logic.
- [x] **Categories:** Horizontal Scroll List with Sport Icons.
- [x] **Venue List:** New `VenueCard` (16:10 aspect ratio, overlay tags).

### Phase 2: Venue Detail Polish
- [x] **Header:** Collapsing Image Carousel with Gradient.
- [x] **Content:** Overlapping Body, Sticky Title, Facilities Chips.
- [x] **Interactions:** Favorite Button & Share.
- [x] **Booking:** Sticky Bottom Bar & Full Calendar Picker.

### Phase 3: Booking Logic Upgrade
- [x] **Multiple Selection:** Refactor `BookingBloc` to allow selecting multiple consecutive slots.
- [x] **Timer:** Add 15-minute countdown/deadline logic for payment.

### Phase 4: Stability & Polish
- [x] **Payment Sync:** Implement `SyncBookingStatus` and auto-refresh logic.
- [x] **History Auto-Refresh:** Refresh list on tab switch and return.
- [x] **Crash Fixes:** Resolve context issues in `BookingDetailPage`.

---

## Sprint 9: Core Engagement (User Side)
*Goal: Gamification and retention features.*

### Phase 1: My Bookings UI Polish
- [x] **Card Redesign:** Use Color Coding (Yellow/Green/Red) strips. Show Sport Type as main title. Highlight Venue/Court/Time info.
- [x] **Tabs:** Separate "Active" vs "History" bookings using `endTime` logic.
- [x] **Schema Polish:** Denormalize Venue/Court names for performance.

### Phase 2: Scoreboard Feature (New)
- [ ] **Logic:** Create `ScoreboardBloc` (In-memory counter). Support Badminton rules (21 points).
- [ ] **UI:** Create `ScoreboardPage` (Digital Clock Font, High Contrast).
- [ ] **Integration:** Add "Open Scoreboard" button in `BookingDetail` (Only if Paid & Today).

### Phase 3: Profile & Stats
- [ ] **Gamification:** Display "Strike" (Relationship frequency) and Win/Loss stats.
- [ ] **Settings:** Add "Edit Profile" and "App Settings" menu.

---

## Sprint 10: Owner Foundation (Owner Side)
*Goal: Allow partners to manage their business.*

### Phase 1: Owner Dashboard
- [ ] **Routing:** Create protected route `/owner-dashboard`.
- [ ] **UI:** Create Dashboard Shell (Stats Overview: Income, Total Booking).

### Phase 2: Venue Management (CRUD) - Part 1
- [ ] **Backend:** Create `VenueManagementBloc`. Implement Add/Update/Delete Venue logic in Firestore.
- [ ] **UI:** Create "My Venues" list for Owner.

### Phase 3: Venue Management (CRUD) - Part 2 (Images)
- [ ] **Logic:** Implement Image Upload to Firebase Storage.
- [ ] **UI:** Create "Add Venue Form" with Image Picker integration.

---

## Sprint 11: Order Management (Owner Side)
*Goal: Manage incoming bookings.*

### Phase 1: Incoming Orders
- [ ] **Backend:** Query bookings where `venue.ownerId == currentUserId`.
- [ ] **UI:** List of incoming bookings with "Approve/Reject" (if manual) or "View" (if auto).

### Phase 2: Schedule View
- [ ] **UI:** Implement Calendar View to see daily occupancy.

---

## Sprint 12: Finalization
*Goal: Prepare for release.*

### Phase 1: Monetization (Deferred)
- [ ] Implement AdMob (Banner).
- [ ] Implement Premium Subscription Logic.

### Phase 2: Pre-Launch
- [ ] Final Bug Fixes.
- [ ] Performance Profiling.
- [ ] Play Store Assets.

## Final Steps
- [ ] Create `README.md` (Comprehensive).
- [ ] Create `GEMINI.md` (Project context).
- [ ] User final review.
