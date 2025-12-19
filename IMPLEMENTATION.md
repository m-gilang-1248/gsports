# Implementation Plan - Gsports

## Strategy: Agile Iterative & Incremental
This project follows an Agile approach. Completed modules (e.g., Auth, Venue) will be revisited and refined in later sprints to accommodate new requirements like Google Sign-In, Owner Roles, and UI Polish.

## Journal
*   **Sprint 3 Completed:** Venue Discovery (Supply Side) has been implemented. Domain, Data, and Presentation layers are complete. `VenueSeeder` added for dummy data.
*   **Sprint 2 Completed:** Authentication and User Profile (Domain, Data, Presentation, and DI) have been fully implemented.
*   **Phase 1 (Foundation):** Project created, dependencies added. Folder structure set up. Core config (Theme, Router, DI) implemented. Encountered `CardTheme` analysis error (type mismatch with `CardThemeData?`), temporarily commented out `cardTheme` in `AppTheme`. `build_runner` run but no injectables yet. Firebase setup for Android successfully completed, including `firebase_options.dart` generation and `main.dart` update.
*   **Sprint 4 Completed:** Midtrans integration with Re-query logic & Zombie Booking prevention is implemented.
*   **Sprint 5 Completed:** Foundation, Basic Auth, Venue Discovery, Booking System, Payment (Midtrans), and Split Bill are functional (MVP level).
*   **Pivot Point:** Moving away from immediate Monetization in sprint 6. Focusing on "Twin Tower" strategy (User & Owner Apps) and High-Fidelity UI/UX.

## Phase 1: Foundation & Setup
- [x] Create Flutter project `gsports` using `create_project`.
    - Target directory: `.` (Current directory `gsports`).
    - Platform: `android`, `ios` (default).
    - Type: `flutter`, Template: `app`, Empty: `true`.
- [x] Clean up default boilerplate (remove `flutter_test` folder if generic, main.dart comments).
- [x] Update `pubspec.yaml` with dependencies:
    - `flutter_bloc`, `equatable`, `get_it`, `injectable`, `go_router`, `flutter_dotenv`
    - `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`
    - `json_annotation`, `google_fonts`, `cached_network_image`, `shimmer`, `intl`
    - `webview_flutter` (for Midtrans)
    - Dev: `build_runner`, `json_serializable`, `mocktail`, `very_good_analysis` (or `flutter_lints`).
- [x] Run `flutter pub get`.
- [x] Setup **Clean Architecture** Folder Structure:
    - `lib/core/{config, constants, error, network, usecases, utils}`
    - `lib/features/`
- [x] Implement **Core Config**:
    - `ThemeData` (Material 3, Black/White/Electric Blue).
    - `GoRouter` configuration (basic shell).
    - `InjectionContainer` (GetIt) setup.
- [x] Initialize **Firebase**:
    - Setup `firebase_options.dart` (assuming user has CLI or provide instructions/placeholder).
    - Call `Firebase.initializeApp()` in `main.dart`.

## Phase 2: Authentication & User Profile
- [x] **Domain Layer (Auth):**
    - Entities: `UserEntity`.
    - UseCases: `LoginUser`, `RegisterUser`, `LogoutUser`, `CheckAuthStatus`.
    - Repository Interface: `AuthRepository`.
- [x] **Data Layer (Auth):**
    - Models: `UserModel` (fromJson/toJson).
    - Datasource: `AuthRemoteDataSource` (Firebase Auth wrapper).
    - Repository Impl: `AuthRepositoryImpl`.
- [x] **Presentation Layer (Auth):**
    - BLoC: `AuthBloc` (Events: Started, LoginRequested, LogoutRequested).
    - UI: `LoginPage` & `RegisterPage` (Material 3 Outlined Inputs).
- [x] **Profile Management:**
    - Create `users` collection in Firestore upon registration.
    - `ProfilePage` to view/edit data.
- [x] **Dependency Injection:** Register Auth feature dependencies.

## Phase 3: Venue Discovery (Supply Side)
- [x] **Domain Layer (Venue):**
    - Entities: `Venue`, `Court`.
    - UseCases: `GetVenues`, `GetVenueDetail`.
    - Repository Interface: `VenueRepository`.
- [x] **Data Layer (Venue):**
    - Models: `VenueModel`, `CourtModel`.
    - Datasource: `VenueRemoteDataSource` (Firestore).
    - Repository Impl: `VenueRepositoryImpl`.
- [x] **Presentation Layer (Venue):**
    - BLoC: `VenueBloc`.
    - UI: `HomePage` (Venue List with `VenueCard` & `FilterChips`).
    - UI: `VenueDetailPage` (SliverAppBar, Facilities, Court List).
- [x] **Seeding:** Create a temporary script or manual entry to add 1-2 dummy venues in Firestore for testing.

## Phase 4: Core Booking & Payment
- [x] **Domain Layer (Booking):**
    - Entities: `Booking`.
    - UseCases: `CreateBooking`.
- [x] **Data Layer (Booking):**
    - Datasource: `BookingRemoteDataSource` (Firestore write + Cloud Function Trigger stub).
    - Repository Impl: `BookingRepositoryImpl`.
- [x] **Presentation Layer (Booking):**
    - UI: `BookingBottomSheet` or Page.
    - Logic: Date/Time Picker -> Check Availability.
- [x] **Midtrans Integration:**
    - [x] Create `PaymentService` (Backend Logic: Domain & Data layers for Snap Token).
    - [x] UI: `WebView` wrapper to display Midtrans Snap.
    - [x] Handle Callback/Return URL.

## Phase 5: Unique Features
- [x] **Split Bill:**
    - [x] Domain: Created `PaymentParticipant` entity.
    - [x] Data: Created `PaymentParticipantModel`.
    - [x] Data: Updated `Booking` entity to use `List<PaymentParticipant>`.
    - [x] Data: Updated `BookingModel` to handle `PaymentParticipantModel` serialization.
    - [x] Backend: Implemented `GenerateSplitCode` use case.
    - [x] Backend: Implemented `JoinBooking` use case (returns `bookingId`).
    - [x] Backend: Implemented `GetBookingDetail` use case.
    - [x] Backend: Updated `BookingRepository` and `BookingRemoteDataSource` for new use cases.
    - [x] Bloc: Created `BookingDetailBloc` (events, states, bloc) for `BookingDetailPage`.
    - [x] UI: Created `BookingDetailPage` with split code display, participant list, and generate code button.
    - [x] Navigation: Added `/booking-detail/:id` route.
    - [x] Navigation: Updated `BookingHistoryCard` to push to `BookingDetailPage`.
    - [x] Fix: Corrected `BookingModel.toJson` to serialize `participants` correctly.
    - [x] Fix: Changed `context.go` to `context.push` in `BookingHistoryCard`.
    - [x] UI: Added `FloatingActionButton` and `Join Booking` dialog to `BookingHistoryPage`.
    - [x] Bloc: Updated `HistoryBloc` to handle `JoinBookingRequested` and emit `HistoryJoinSuccess(bookingId)`.
    - [x] UI: Implemented Copy to Clipboard for `splitCode` in `BookingDetailPage`.
    - [x] UI: Updated `BookingHistoryPage` listener to navigate to `BookingDetailPage` on `HistoryJoinSuccess`.
- [ ] **Scoreboard:**
    - BLoC: `ScoreboardBloc` (In-memory logic for Badminton/Futsal).
    - UI: `ScoreboardPage` (Big numbers, increment/decrement).
    - Logic: "Save Match" -> Write to `matches` collection.

## Sprint 6: UI Foundation & Auth Revolution (The Face Lift)
*Goal: Move away from 'Basic UI'. Implement professional Design System & complete Authentication features.*

### Phase 1: Design System & Assets
- [ ] **Dependencies:** Add `google_fonts`, `flutter_svg`, `carousel_slider`, `google_sign_in`, `image_picker`.
- [ ] **Assets:** Setup folder structure for SVG icons (Google logo, Sport icons).
- [ ] **Global Widgets:** Create `AppColors`, `CustomButton`, `CustomTextField` (with built-in obscure toggle), `StatusChip`.

### Phase 2: Auth Logic Upgrade
- [ ] **Google Auth:** Implement `SignInWithGoogle` in `AuthRemoteDataSource` & Bloc.
- [ ] **Role Logic:** Update `UserEntity` to strictly support 'user' or 'owner'. Update Firestore logic to save this role.

### Phase 3: Auth UI Revamp
- [ ] **Login Page:** Rebuild using `CustomTextField` (Hide/Show Pass) and `GoogleSignInButton`.
- [ ] **Register Page:** Add "Role Selection" (Player vs Venue Owner) and Confirm Password field.
- [ ] **Guest Mode:** Update `router.dart` logic to allow access to Home/Detail without login.

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
