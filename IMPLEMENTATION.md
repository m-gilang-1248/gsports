# Implementation Plan - Gsports

## Journal
*   **Sprint 3 Completed:** Venue Discovery (Supply Side) has been implemented. Domain, Data, and Presentation layers are complete. `VenueSeeder` added for dummy data.
*   **Sprint 2 Completed:** Authentication and User Profile (Domain, Data, Presentation, and DI) have been fully implemented.
*   **Phase 1 (Foundation):** Project created, dependencies added. Folder structure set up. Core config (Theme, Router, DI) implemented. Encountered `CardTheme` analysis error (type mismatch with `CardThemeData?`), temporarily commented out `cardTheme` in `AppTheme`. `build_runner` run but no injectables yet. Firebase setup for Android successfully completed, including `firebase_options.dart` generation and `main.dart` update.
*   **Sprint 4 Completed:** Midtrans integration with Re-query logic & Zombie Booking prevention is implemented.

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

## Phase 6: Finalization
- [ ] **Monetization Guard:**
    - Check `user.tier` before allowing premium venue booking.
    - Add placeholder `BannerAd` widget (Google Mobile Ads) for free users.
- [ ] **Security Rules:**
    - Deploy (or save file) `firestore.rules`.
- [ ] **Polishing:**
    - Verify Shimmer loading effects.
    - Error handling (Snackbars).
    - Final "Clean" UI check (Spacing, Fonts).

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
