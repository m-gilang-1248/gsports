# Implementation Plan: Navigation Shell

## Journal
- **Phase 1 Start:** Planning to implement `MainPage`, refactor routing, and move `VenueBloc`. User approved design with notes: Use `VenueFetchListRequested` and place `ProfilePage` in `auth` feature.
- **Phase 1 Completed:** Implemented `MainPage` with `BottomNavigationBar` and `IndexedStack`. Moved `VenueBloc` provider to `MainPage` and removed it from `main.dart`. Removed redundant fetch event from `HomePage`. Created placeholder pages for Bookings and Profile. Added widget tests for `MainPage`.

## Phase 1: Setup & Main Page Implementation
- [x] Run all tests to ensure the project is in a good state.
- [x] Create `lib/core/presentation/pages/main_page.dart`.
    - [x] Implement `StatefulWidget` with `BottomNavigationBar` and `IndexedStack`.
    - [x] Ensure `VenueBloc` is provided here using `BlocProvider`.
    - [x] **Note:** Use `VenueFetchListRequested` event.
- [x] Create placeholder pages:
    - [x] `lib/features/booking/presentation/pages/my_bookings_page.dart` (Scaffold with "My Bookings - Coming Soon").
    - [x] `lib/features/auth/presentation/pages/profile_page.dart` (Scaffold with "Profile - Coming Soon").
- [x] Update `lib/core/config/router.dart`.
    - [x] Change `/home` route to point to `MainPage`.
    - [x] Ensure sub-routes or IndexedStack logic works as intended (since we are using IndexedStack, `MainPage` manages the view, not sub-routes in GoRouter for these tabs).
- [x] Remove `VenueBloc` provider from `lib/main.dart` (since it is now in `MainPage`).
- [x] Update `HomePage` to remove any `BlocProvider` or event triggering that might conflict (if any), though `HomePage` likely just consumes it.
    - [x] Check `HomePage` `initState` or `build` for event triggering. The `MainPage` provider should trigger the initial fetch.
- [x] Create/modify unit tests for `MainPage` (widget test to ensure tabs switch).
- [x] Run `dart_fix`.
- [x] Run `analyze_files`.
- [x] Run tests.
- [x] Run `dart_format`.
- [x] Verify changes with `git diff`.
- [ ] Commit changes: `feat: implement main page navigation shell and move venue bloc`.
- [ ] Hot Reload.

## Phase 2: Finalization
- [ ] Update `README.md` (if navigation instructions change).
- [ ] Update `GEMINI.md` context.
- [ ] User Review.