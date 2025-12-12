# MODIFICATION IMPLEMENTATION PLAN: Fix Bugs & Implement Join UI

This plan covers the critical fixes for booking serialization and navigation, and the implementation of the Join Booking feature.

## Phase 1: Fix BookingModel Serialization
**Goal:** Ensure `BookingModel.toJson()` produces a `List<Map>` for `participants`, preventing Firestore errors.

- [x] Run tests to confirm current state (expecting serialization failure if tested).
- [x] Update `lib/features/booking/data/models/booking_model.dart` to override `toJson` and manually convert `participants`.
- [x] Run `dart run build_runner build --delete-conflicting-outputs` (just in case, though the manual override might bypass the need for regen if done in the class).
- [x] Verify with a manual test or unit test that serialization works correctly.
- [x] Run `dart_fix` and `dart_format`.
- [x] Run tests.
- [x] Commit changes.

## Phase 2: Fix Navigation
**Goal:** Ensure back button works correctly from `BookingDetailPage`.

- [x] Update `lib/features/booking/presentation/pages/booking_history_page.dart`.
- [x] Change `context.go` to `context.push` in `BookingHistoryCard` onTap.
- [x] Run `dart_fix` and `dart_format`.
- [x] Run tests.
- [x] Commit changes.

## Phase 3: Implement Join Feature (Bloc & UI)
**Goal:** Allow users to join a booking via code.

- [x] Update `lib/features/booking/presentation/bloc/history/history_event.dart`:
    - Add `JoinBookingRequested(String splitCode)`.
- [x] Update `lib/features/booking/presentation/bloc/history/history_bloc.dart`:
    - Inject `JoinBooking` use case.
    - Implement `_onJoinBookingRequested`.
        - Call `JoinBooking`.
        - If success: Add `FetchBookingHistory`.
        - If fail: Emit `HistoryError` (or a specific error state if we don't want to replace the list).
- [x] Register updated `HistoryBloc` in `injection_container.dart` (ensure `JoinBooking` is passed).
- [x] Run `dart run build_runner build --delete-conflicting-outputs`.
- [x] Run `dart_fix` and `dart_format`.
- [x] Run tests.
- [ ] Update `lib/features/booking/presentation/pages/booking_history_page.dart`:
    - Add `FloatingActionButton`.
    - Implement `_showJoinDialog`.
    - Listen for `HistoryError` (to show snackbar) and `HistoryLoaded` (to show success if previously loading).
- [ ] Commit changes.

## Phase 4: Finalize
- [ ] Update `GEMINI.md`.
- [ ] Ask user for final review.

## Journal
*   Phase 1: Fixed BookingModel `toJson` serialization for participants. Confirmed with `analyze_files` and `flutter test`. Committed changes.
*   Phase 2: Changed navigation from `context.go` to `context.push` in `BookingHistoryCard`. Confirmed with `analyze_files` and `flutter test`. Committed changes.
*   Phase 3: Updated `history_event.dart` with `JoinBookingRequested`. Updated `history_bloc.dart` to inject `JoinBooking` use case and handle the `JoinBookingRequested` event, including error handling and refreshing the booking list. Ran `build_runner` to update DI. Fixed a test error in `history_bloc_test.dart` related to `FirebaseAuth` mocking. All tests passed.