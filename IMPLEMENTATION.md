# Implementation Plan - Gsports

## Strategy: Agile Iterative & Incremental
This project follows an Agile approach. Completed modules (e.g., Auth, Venue) will be revisited and refined in later sprints to accommodate new requirements like Google Sign-In, Owner Roles, and UI Polish.

## Journal
*   **Sprint 10 Completed:** Owner Foundation & Stability.
    *   **Architecture:** Implemented dedicated `partner` feature module with `dashboard` and `venue_management`.
    *   **Dashboard:** Owner Dashboard with real-time stats (Revenue, Bookings) and "My Venues" quick access.
    *   **Venue CRUD:** Full Add/Edit/Delete flow for Venues.
    *   **Court CRUD:** Full Add/Edit/Delete flow for Courts within a Venue, including hourly price setting.
    *   **Location Intelligence:** Integrated **API-based Location Picker** (EMSifa) for accurate Indonesia-wide address selection (Province -> City -> District).
    *   **Automation:** Auto-calculation of `minPrice` for Venues based on Court prices.
    *   **Stability:** Fixed ANR/Crashes during court addition by refactoring Router Bloc Scoping. Implemented strict Role-Based Redirection (Splash Screen) and Route Guards.
    *   **UI/UX:** Added facility icons and auto-refresh logic for smoother management experience.
*   **Sprint 9 Phase 3 Completed:** Profile, Stats & Settings.
    *   **Architecture:** Created dedicated `features/profile` module.
    *   **Stats:** Client-side aggregation logic for Matches Played, Won, and Win Rate.
    *   **Edit Profile:** Profile editing with image upload to Cloudinary and sync with Auth.
    *   **UI:** Redesigned Profile page with Gamification Card and Settings menu.
*   **Sprint 9 Phase 2 Completed:** Scoreboard Feature.
    *   **Logic:** Implemented ScoreboardBloc with BWF rules (21 pts, Deuce, Max 30, Best of 3).
    *   **UI:** Digital scoreboard with high contrast, Orbitron font, and wakelock integration.
    *   **Persistence:** Saving match results to Firestore.
*   **Sprint 9 Phase 1 Completed:** My Bookings UI & Schema Polish.
    *   **Card Redesign:** Implemented color-coded strips (Orange/Green/Red) and prominent sport icons.
    *   **Information Density:** Denormalized `venueName`, `courtName`, and `venueLocation` into Booking documents.
*   **Sprint 8 Polish & Stability:**
    *   **Payment Stability:** Fixed false-positive success states, implemented robust Midtrans status syncing.
    *   **Auto-Refresh:** Implemented automatic data refreshing for Booking History.
*   **Sprint 6 Completed:** UI Foundation, Auth Revolution, and Guest Mode.
*   **Sprint 5 Completed:** Foundation, Basic Auth, Venue Discovery, Booking System, Payment (Midtrans), and Split Bill.

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
- [x] **Scoreboard**

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
- [x] **Content:** Overlapping Body, Sticky Title, Facilities Chips (with Icons).
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
- [x] **Logic:** Create `ScoreboardBloc` (In-memory counter). Support Badminton rules (21 points, Deuce, Best of 3).
- [x] **UI:** Create `ScoreboardPage` (Digital Clock Font, High Contrast, Wakelock).
- [x] **Duration:** Track match duration in real-time.
- [x] **History:** Display match history in `BookingDetailPage` and `ProfilePage`.
- [x] **Integration:** Add "Open Scoreboard" button in `BookingDetail` (Only if Paid & Today).

### Phase 3: Profile & Stats
- [x] **Gamification:** Display "Strike" (Relationship frequency) and Win/Loss stats.
- [x] **Settings:** Add "Edit Profile" and "App Settings" menu.
- [x] **Module:** Created standalone `profile` feature.

---

## Sprint 10: Owner Foundation (Owner Side) - COMPLETED
*Goal: Allow partners to manage their business.*

### Phase 1: Owner Dashboard
- [x] **Routing:** Create protected route `/owner-dashboard`.
- [x] **UI:** Create Dashboard Shell (Stats Overview: Income, Total Booking).
- [x] **Logic:** Fetch stats from Firestore (Aggregation of bookings).

### Phase 2: Venue Management (CRUD)
- [x] **Backend:** Create `VenueManagementBloc`. Implement Add/Update/Delete Venue logic in Firestore.
- [x] **UI:** Create "My Venues" list for Owner.
- [x] **Location:** Implement API-based Location Picker (Province -> City -> District).
- [x] **Images:** Implement Cloudinary upload for Venue images.

### Phase 3: Court Management (CRUD)
- [x] **Backend:** Implement `CourtManagementBloc`. Add/Update/Delete Courts in sub-collection.
- [x] **Logic:** Auto-update Venue `minPrice` based on cheapest court.
- [x] **UI:** "Venue Courts" page with list and Add/Edit form.

### Phase 4: Stability & Polish
- [x] **Route Guards:** Strict role checking on Splash and Router to prevent unauthorized access.
- [x] **Crash Fixes:** Resolve ANR in Add Court by fixing Bloc Scoping in GoRouter.
- [x] **UX:** Auto-refresh lists after edits.

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