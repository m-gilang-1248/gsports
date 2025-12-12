# MODIFICATION IMPLEMENTATION PLAN: Fix Copy Button & Join Navigation

This plan covers the implementation of the copy-to-clipboard feature and the refactoring of the Join Booking flow for automatic navigation.

## Phase 1: Backend Refactor (Return Booking ID)
**Goal:** Modify `JoinBooking` to return the `bookingId` of the joined booking.

- [ ] Update `lib/features/booking/data/datasources/booking_remote_data_source.dart`:
    - Change `joinBooking` return type to `Future<String>`.
    - Return `bookingDocRef.id` after successful update.
- [ ] Update `lib/features/booking/domain/repositories/booking_repository.dart`:
    - Change `joinBooking` return type to `Future<Either<Failure, String>>`.
- [ ] Update `lib/features/booking/data/repositories/booking_repository_impl.dart`:
    - Update `joinBooking` implementation to match new signature and return `Right(bookingId)`.
- [ ] Update `lib/features/booking/domain/usecases/join_booking.dart`:
    - Change return type to `Future<Either<Failure, String>>`.
- [ ] Update tests in `test/features/booking/domain/usecases/split_bill_usecases_test.dart` to match new return types.
- [ ] Run `dart_fix` and `dart_format`.
- [ ] Run tests.
- [ ] Update `MODIFICATION_IMPLEMENTATION.md` (Journal & Checkboxes).
- [ ] Commit changes.

## Phase 2: State Management Update (HistoryBloc)
**Goal:** Emit a state with `bookingId` upon successful join.

- [ ] Update `lib/features/booking/presentation/bloc/history/history_state.dart`:
    - Add `HistoryJoinSuccess` state with `final String bookingId`.
- [ ] Update `lib/features/booking/presentation/bloc/history/history_bloc.dart`:
    - Update `_onJoinBookingRequested`:
        - Await result from `_joinBooking`.
        - If success (Right(bookingId)), emit `HistoryJoinSuccess(bookingId)`.
        - Then emit `HistoryLoading` (or maintain loading) and trigger `FetchBookingHistory` to refresh the list. *Wait, if we emit Fetch, it might overwrite JoinSuccess too fast. Let's emit JoinSuccess, then the UI Listener handles navigation, and WE ALSO add the Fetch event.*
- [ ] Update `test/features/booking/presentation/bloc/history/history_bloc_test.dart`.
- [ ] Run tests.
- [ ] Update `MODIFICATION_IMPLEMENTATION.md` (Journal & Checkboxes).
- [ ] Commit changes.

## Phase 3: UI Implementation
**Goal:** Implement Copy Button and Join Navigation.

- [ ] Update `lib/features/booking/presentation/pages/booking_detail_page.dart`:
    - Implement `onPressed` for Copy Icon.
    - Use `Clipboard.setData`.
    - Show SnackBar.
- [ ] Update `lib/features/booking/presentation/pages/booking_history_page.dart`:
    - Update `BlocListener` to handle `HistoryJoinSuccess`.
    - Navigate to `'/booking-detail/$bookingId'` using `context.push`.
- [ ] Run `dart_fix` and `dart_format`.
- [ ] Update `MODIFICATION_IMPLEMENTATION.md` (Journal & Checkboxes).
- [ ] Manual verification.
- [ ] Commit changes.

## Phase 4: Finalize
- [ ] Update `MODIFICATION_IMPLEMENTATION.md` (Journal & Checkboxes).
- [ ] Update `GEMINI.md`.
- [ ] Ask user for final review.

## Journal
*   (To be updated)