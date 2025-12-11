# Implementation Plan: Fix Venue Provider Scope & History Interactions

## Journal
- **Phase 1 Start:** Fixing `ProviderNotFoundException` by hoisting `VenueBloc`. Adding interactions to `BookingHistoryPage`.

## Phase 1: Refactoring & UI Updates
- [ ] Run all tests to ensure the project is in a good state.
- [ ] **Refactor Providers:**
    - [ ] Update `lib/main.dart`: Add `BlocProvider<VenueBloc>` to `MultiBlocProvider`.
    - [ ] Update `lib/core/presentation/pages/main_page.dart`: Remove `BlocProvider<VenueBloc>` wrapper.
- [ ] **Update Booking UI:**
    - [ ] Update `lib/features/booking/presentation/pages/booking_history_page.dart`: Add `onTap` logic to `BookingHistoryCard` showing SnackBar.
- [ ] **Verification:**
    - [ ] Update/Run `test/core/presentation/pages/main_page_test.dart` (ensure it still passes, might need mock updates if `MainPage` structure changes, but since `VenueBloc` is now global, `MainPage` widget test might need to wrap `MainPage` in `BlocProvider` *inside the test* which it already does via mocks/pumpWidget setup).
        - *Correction:* `main_page_test.dart` currently mocks `VenueBloc` and provides it locally in `setUp`? No, it uses `pumpWidget` with `MaterialApp`. It might need `BlocProvider` in the test setup if `MainPage` no longer provides it itself but *consumes* it (if it consumes it). `MainPage` doesn't strictly consume `VenueBloc`, but `HomePage` (which is a child) does.
        - The test currently injects *dummy pages* so `VenueBloc` dependency inside `HomePage` is bypassed. So the test should pass without changes.
- [ ] Run `dart_fix`.
- [ ] Run `analyze_files`.
- [ ] Run tests.
- [ ] Run `dart_format`.
- [ ] Update `MODIFICATION_IMPLEMENTATION.md` (Journal & Checkboxes).
- [ ] Verify changes with `git diff`.
- [ ] Commit changes: `fix: move venue bloc provider to main and add history interactions`.
- [ ] Hot Reload.

## Phase 2: Finalization
- [ ] Update `GEMINI.md` context.
- [ ] User Review.
