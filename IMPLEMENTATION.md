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
*   **Pivot Point:** Moving away from immediate Monetization in sprint 6. Focusing on "Twin Tower" strategy (User & Owner Apps) and High-Fidelity UI/UX.

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
*Goal: Move away from 'Basic UI'. Implement professional Design System & complete Authentication features.*

### Phase 1: Design System & Assets
- [x] **Dependencies:** Added `google_fonts`, `flutter_svg`, `carousel_slider`, `google_sign_in`, `image_picker`.
- [x] **Assets:** Setup folder structure.
- [x] **Global Widgets:** Created `AppColors`, `AppTheme` (v2.1), `CustomButton`, `CustomTextField`.

### Phase 2: Auth Logic Upgrade
- [x] **Google Auth:** Implemented `SignInWithGoogle` in `AuthRemoteDataSource` & Bloc (using Credential Manager).
- [x] **Role Logic:** Updated `UserEntity` to support 'user' or 'mitra'. Implemented Role-Based Navigation.

### Phase 3: Auth UI Revamp
- [x] **Login Page:** Rebuilt using Design System v2.1. Added Google Sign-In and Guest Mode entry.
- [x] **Register Page:** Added Role Selection (Player vs Venue Owner) and Google Sign-Up support.
- [x] **Guest Mode:** Implemented strict router whitelist for public access (Home/Venue) and redirect logic for protected actions.

---

## Sprint 8: Discovery & Booking Experience (User Side)
*Goal: Make finding and booking venues seamless and visually appealing.*

### Phase 1: Home Revamp
- [ ] **Header:** Implement Greeting ("Hello, [Name]") & Notification Icon (replacing Seeder).
- [ ] **Search:** Create `SearchBar` widget (UI only, navigating to SearchPage).
- [ ] **Categories:** Create Horizontal Scroll List with Sport Icons.
- [ ] **Venue List:** Update `VenueCard` to use new Design System (No overflow, better typography).

### Phase 2: Venue Detail Polish
- [ ] **Header:** Replace static image with `CarouselSlider` (Multiple photos).
- [ ] **Content:** Implement Grid Layout for Facilities.
- [ ] **Interactions:** Add "Like/Favorite" button logic (Backend & UI).

### Phase 3: Booking Logic Upgrade
- [ ] **Multiple Selection:** Refactor `BookingBloc` to allow selecting multiple consecutive slots.
- [ ] **Timer:** Add 60-minute countdown/deadline logic for payment.

---

## Sprint 9: Core Engagement (User Side)
*Goal: Gamification and retention features.*

### Phase 1: My Bookings UI Polish
- [ ] **Card Redesign:** Use Color Coding (Yellow/Green/Red) strips. Show Sport Type as main title.
- [ ] **Tabs:** Separate "Active" vs "History" bookings.

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

## Standard Checks (Perform after EACH Phase)
- [ ] Create/modify unit tests for testing the code added or modified in this phase.
- [ ] Run `dart_fix` to clean up the code.
- [ ] Run `analyze_files` and fix any issues.
- [ ] Run tests to ensure they pass.
- [ ] Run `dart_format`.
- [ ] Update `IMPLEMENTATION.md` (Journal & Checkboxes).
- [ ] Verify changes with `git diff`.
- [ ] Commit changes with a clear message (User Approval Required).
- [ ] Hot Reload/Restart app if running.

## Final Steps
- [ ] Create `README.md` (Comprehensive).
- [ ] Create `GEMINI.md` (Project context).
- [ ] User final review.