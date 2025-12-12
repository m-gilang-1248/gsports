# MODIFICATION IMPLEMENTATION PLAN: Fix Bugs & Implement Join UI

This plan covers the critical fixes for booking serialization and navigation, and the implementation of the Join Booking feature.

## Phase 1: Fix BookingModel Serialization
**Goal:** Ensure `BookingModel.toJson()` produces a `List<Map>` for `participants`, preventing Firestore errors.

- [ ] Run tests to confirm current state (expecting serialization failure if tested).
- [ ] Update `lib/features/booking/data/models/booking_model.dart` to override `toJson` and manually convert `participants`.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs` (just in case, though the manual override might bypass the need for regen if done in the class).
- [ ] Verify with a manual test or unit test that serialization works correctly.

## Phase 2: Fix Navigation
**Goal:** Ensure back button works correctly from `BookingDetailPage`.

- [ ] Update `lib/features/booking/presentation/pages/booking_history_page.dart`.
- [ ] Change `context.go` to `context.push` in `BookingHistoryCard` onTap.

## Phase 3: Implement Join Feature (Bloc & UI)
**Goal:** Allow users to join a booking via code.

- [ ] Update `lib/features/booking/presentation/bloc/history/history_event.dart`:
    - Add `JoinBookingRequested(String splitCode)`.
- [ ] Update `lib/features/booking/presentation/bloc/history/history_state.dart`:
    - Add `JoinSuccess()` and `JoinFailure(String message)` states (or handle via side effects). *Decision: Let's keep `HistoryState` for the list, and maybe use a separate Bloc or just handle it within HistoryBloc and emit a specialized state that the UI listens to, then re-emits Loaded.*
    - **Better Approach:** Add `JoinBookingStatus` to `HistoryLoaded` or use a mixin.
    - **Simplest Approach for MVP:** Let `HistoryBloc` emit `HistoryLoading` -> (Join Logic) -> `HistoryLoaded` (refreshed). If error, emit `HistoryError`.
    - Let's stick to: `HistoryBloc` handles it.
- [ ] Update `lib/features/booking/presentation/bloc/history/history_bloc.dart`:
    - Inject `JoinBooking` use case.
    - Implement `_onJoinBookingRequested`.
        - Call `JoinBooking`.
        - If success: Add `FetchBookingHistory`.
        - If fail: Emit `HistoryError` (or a specific error state if we don't want to replace the list).
- [ ] Update `lib/features/booking/presentation/pages/booking_history_page.dart`:
    - Add `FloatingActionButton`.
    - Implement `_showJoinDialog`.
    - Listen for `HistoryError` (to show snackbar) and `HistoryLoaded` (to show success if previously loading).
- [ ] Register updated `HistoryBloc` in `injection_container.dart` (ensure `JoinBooking` is passed).
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`.
- [ ] Run `dart_fix` and `dart_format`.
- [ ] Run tests.
- [ ] Commit changes.

## Phase 4: Finalize
- [ ] Update `GEMINI.md`.
- [ ] Ask user for final review.

## Journal
*   (To be updated)